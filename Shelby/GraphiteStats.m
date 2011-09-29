//
//  GraphiteStats.m
//  Shelby
//
//  Created by Mark Johnson on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphiteStats.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@interface GraphiteStats ()

// forward declarations

- (void)_stopHostResolution;
- (void)_stopWithError:(NSError *)error;
- (void)_stopWithStreamError:(CFStreamError)streamError;
- (void)startConnectedToHostName:(NSString *)hostName port:(NSUInteger)port;
- (void)stop;

@end

@implementation GraphiteStats

- (id)init
{
    self = [super init];
    if (self != nil) {
        [self startConnectedToHostName:@"50.56.19.195" port:(NSUInteger)8125];
    }
    return self;
}

- (void)dealloc
{
    [self stop];
    [super dealloc];
}

- (void)_sendData:(NSData *)data toAddress:(NSData *)addr
    // Called by both -sendData: and the server echoing code to send data 
    // via the socket.  addr is nil in the client case, whereupon the 
    // data is automatically sent to the hostAddress by virtue of the fact 
    // that the socket is connected to that address.
{
    int                     err;
    int                     sock;
    ssize_t                 bytesWritten;
    const struct sockaddr * addrPtr;
    socklen_t               addrLen;

    assert(data != nil);
    assert( (addr == nil) || ([addr length] <= sizeof(struct sockaddr_storage)) );

    sock = CFSocketGetNative(self->_cfSocket);
    assert(sock >= 0);

    if (addr == nil) {
        addr = _hostAddress;
        assert(addr != nil);
        addrPtr = NULL;
        addrLen = 0;
    } else {
        addrPtr = [addr bytes];
        addrLen = (socklen_t) [addr length];
    }
    
    bytesWritten = sendto(sock, [data bytes], [data length], 0, addrPtr, addrLen);
    if (bytesWritten < 0) {
        err = errno;
    } else  if (bytesWritten == 0) {
        err = EPIPE;                    
    } else {
        // We ignore any short writes, which shouldn't happen for UDP anyway.
        assert( (NSUInteger) bytesWritten == [data length] );
        err = 0;
    }
}

- (void)_readData
// Called by the CFSocket read callback to actually read and process data 
// from the socket.
{
    int                     err;
    int                     sock;
    struct sockaddr_storage addr;
    socklen_t               addrLen;
    uint8_t                 buffer[65536];
    ssize_t                 bytesRead;
    
    sock = CFSocketGetNative(self->_cfSocket);
    assert(sock >= 0);
    
    addrLen = sizeof(addr);
    bytesRead = recvfrom(sock, buffer, sizeof(buffer), 0, (struct sockaddr *) &addr, &addrLen);
    if (bytesRead < 0) {
        err = errno;
    } else if (bytesRead == 0) {
        err = EPIPE;
    } else {
        NSData *    dataObj;
        NSData *    addrObj;
        
        err = 0;
        
        dataObj = [NSData dataWithBytes:buffer length:bytesRead];
        assert(dataObj != nil);
        addrObj = [NSData dataWithBytes:&addr  length:addrLen  ];
        assert(addrObj != nil);
    }
}


static void SocketReadCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
    // This C routine is called by CFSocket when there's data waiting on our 
    // UDP socket.  It just redirects the call to Objective-C code.
{
    GraphiteStats *       obj;
    
    obj = (GraphiteStats *) info;
    assert([obj isKindOfClass:[GraphiteStats class]]);
    
    #pragma unused(s)
    assert(s == obj->_cfSocket);
    #pragma unused(type)
    assert(type == kCFSocketReadCallBack);
    #pragma unused(address)
    assert(address == nil);
    #pragma unused(data)
    assert(data == nil);
    
    [obj _readData];
}

- (BOOL)_setupSocketConnectedToAddress:(NSData *)address port:(NSUInteger)port error:(NSError **)errorPtr
// Sets up the CFSocket in either client or server mode.  In client mode, 
// address contains the address that the socket should be connected to. 
// The address contains zero port number, so the port parameter is used instead. 
// In server mode, address is nil and the socket is bound to the wildcard 
// address on the specified port.
{
    int                     err;
    int                     junk;
    int                     sock;
    const CFSocketContext   context = { 0, self, NULL, NULL, NULL };
    CFRunLoopSourceRef      rls;
    
    assert( (address == nil) || ([address length] <= sizeof(struct sockaddr_storage)) );
    assert(port < 65536);
    
    assert(self->_cfSocket == NULL);
    
    // Create the UDP socket itself.
    
    err = 0;
    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        err = errno;
    }
    
    // Bind or connect the socket, depending on whether we're in server or client mode.
    
    if (err == 0) {
        struct sockaddr_in      addr;
        
        memset(&addr, 0, sizeof(addr));
        
        // Client mode.  Set up the address on the caller-supplied address and port 
        // number.
        if ([address length] > sizeof(addr)) {
            assert(NO);         // very weird
            [address getBytes:&addr length:sizeof(addr)];
        } else {
            [address getBytes:&addr length:[address length]];
        }
        assert(addr.sin_family == AF_INET);
        addr.sin_port = htons(port);
        err = connect(sock, (const struct sockaddr *) &addr, sizeof(addr));
        if (err < 0) {
            err = errno;
        }
    }
    
    // From now on we want the socket in non-blocking mode to prevent any unexpected 
    // blocking of the main thread.  None of the above should block for any meaningful 
    // amount of time.
    
//    if (err == 0) {
//        int flags;
//        
//        flags = fcntl(sock, F_GETFL);
//        err = fcntl(sock, F_SETFL, flags | O_NONBLOCK);
//        if (err < 0) {
//            err = errno;
//        }
//    }
    
    // Wrap the socket in a CFSocket that's scheduled on the runloop.
    
    if (err == 0) {
        self->_cfSocket = CFSocketCreateWithNative(NULL, sock, kCFSocketReadCallBack, SocketReadCallback, &context);
        
        // The socket will now take care of cleaning up our file descriptor.
        
        assert( CFSocketGetSocketFlags(self->_cfSocket) & kCFSocketCloseOnInvalidate );
        sock = -1;
        
        rls = CFSocketCreateRunLoopSource(NULL, self->_cfSocket, 0);
        assert(rls != NULL);
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
        
        CFRelease(rls);
    }
    
    // Handle any errors.
    
    if (sock != -1) {
        junk = close(sock);
        assert(junk == 0);
    }
    assert( (err == 0) == (self->_cfSocket != NULL) );
    if ( (self->_cfSocket == NULL) && (errorPtr != NULL) ) {
        *errorPtr = [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil];
    }
    
    return (err == 0);
}

- (void)_hostResolutionDone
// Called by our CFHost resolution callback (HostResolveCallback) when host 
// resolution is complete.  We find the best IP address and create a socket 
// connected to that.
{
    NSError *           error;
    Boolean             resolved;
    NSArray *           resolvedAddresses;
    
    assert(_port != 0);
    assert(self->_cfHost != NULL);
    assert(self->_cfSocket == NULL);
    assert(_hostAddress == nil);
    
    error = nil;
    
    // Walk through the resolved addresses looking for one that we can work with.
    
    resolvedAddresses = (NSArray *) CFHostGetAddressing(self->_cfHost, &resolved);
    if ( resolved && (resolvedAddresses != nil) ) {
        for (NSData * address in resolvedAddresses) {
            BOOL                    success;
            const struct sockaddr * addrPtr;
            NSUInteger              addrLen;
            
            addrPtr = (const struct sockaddr *) [address bytes];
            addrLen = [address length];
            assert(addrLen >= sizeof(struct sockaddr));
            
            // Try to create a connected CFSocket for this address.  If that fails, 
            // we move along to the next address.  If it succeeds, we're done.
            
            success = NO;
            if ( 
                (addrPtr->sa_family == AF_INET) 
                ) {
                success = [self _setupSocketConnectedToAddress:address port:_port error:&error];
                if (success) {
                    CFDataRef   hostAddress;
                    
                    hostAddress = CFSocketCopyPeerAddress(self->_cfSocket);
                    assert(hostAddress != NULL);
                    
                    _hostAddress = (NSData *) hostAddress;
                    
                    CFRelease(hostAddress);
                }
            }
            if (success) {
                break;
            }
        }
    }
    
    // If we didn't get an address and didn't get an error, synthesise a host not found error.
    
    if ( (_hostAddress == nil) && (error == nil) ) {
        error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorHostNotFound userInfo:nil];
    }
    
    if (error == nil) {
        // We're done resolving, so shut that down.
        [self _stopHostResolution];
    } else {
        [self _stopWithError:error];
    }
}

static void HostResolveCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
    // This C routine is called by CFHost when the host resolution is complete. 
    // It just redirects the call to the appropriate Objective-C method.
{
    GraphiteStats *    obj;
    
    obj = (GraphiteStats *) info;
    assert([obj isKindOfClass:[GraphiteStats class]]);
    
    #pragma unused(theHost)
    assert(theHost == obj->_cfHost);
    #pragma unused(typeInfo)
    assert(typeInfo == kCFHostAddresses);
    
    if ( (error != NULL) && (error->domain != 0) ) {
        [obj _stopWithStreamError:*error];
    } else {
        [obj _hostResolutionDone];
    }
}

- (void)startConnectedToHostName:(NSString *)hostName port:(NSUInteger)port
    // See comment in header.
{
    assert(hostName != nil);
    assert( (port > 0) && (port < 65536) );
    
    assert(_port == 0);     // don't try and start a started object
    if (_port == 0) {
        Boolean             success;
        CFHostClientContext context = {0, self, NULL, NULL, NULL};
        CFStreamError       streamError;

        assert(self->_cfHost == NULL);

        self->_cfHost = CFHostCreateWithName(NULL, (CFStringRef) hostName);
        assert(self->_cfHost != NULL);
        
        CFHostSetClient(self->_cfHost, HostResolveCallback, &context);
        
        CFHostScheduleWithRunLoop(self->_cfHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        success = CFHostStartInfoResolution(self->_cfHost, kCFHostAddresses, &streamError);
        if (success) {
            _hostName = hostName;
            _port = port;
            // ... continue in HostResolveCallback
        } else {
            [self _stopWithStreamError:streamError];
        }
    }
}

- (void)sendData:(NSData *)data
    // See comment in header.
{
    // If you call -sendData: on an object in client mode 
    // that's not fully set up (hostAddress is nil), we just ignore you.
    if (_hostAddress == nil) {
        assert(NO);
    } else {
        [self _sendData:data toAddress:nil];
    }
}

- (void)_stopHostResolution
    // Called to stop the CFHost part of the object, if it's still running.
{
    if (self->_cfHost != NULL) {
        CFHostSetClient(self->_cfHost, NULL, NULL);
        CFHostCancelInfoResolution(self->_cfHost, kCFHostAddresses);
        CFHostUnscheduleFromRunLoop(self->_cfHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(self->_cfHost);
        self->_cfHost = NULL;
    }
}

- (void)stop
    // See comment in header.
{
    _hostName = nil;
    _hostAddress = nil;
    _port = 0;
    [self _stopHostResolution];
    if (self->_cfSocket != NULL) {
        CFSocketInvalidate(self->_cfSocket);
        CFRelease(self->_cfSocket);
        self->_cfSocket = NULL;
    }
}

- (void)_stopWithError:(NSError *)error
    // Stops the object, reporting the supplied error to the delegate.
{
    assert(error != nil);
    [self stop];
}

- (void)_stopWithStreamError:(CFStreamError)streamError
    // Stops the object, reporting the supplied error to the delegate.
{
    NSDictionary *  userInfo;
    NSError *       error;

    if (streamError.domain == kCFStreamErrorDomainNetDB) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInteger:streamError.error], kCFGetAddrInfoFailureKey,
            nil
        ];
    } else {
        userInfo = nil;
    }
    error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorUnknown userInfo:userInfo];
    assert(error != nil);
    
    [self _stopWithError:error];
}

- (void)incrementCounter:(NSString *)counterName
{
    NSString *device = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        device = @"iphone";
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        device = @"ipad";
    } else {
        device = @"other";
    }
    
    NSString *command = [NSString stringWithFormat:@"ios.%@.%@:1|c", device, counterName];
    [self sendData:[command dataUsingEncoding:NSUTF8StringEncoding]];
}

@end

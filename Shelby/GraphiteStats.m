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
#include <arpa/inet.h>

@implementation GraphiteStats

+ (void)sendData:(NSData *)data
{   
    // Create the UDP socket
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        return;
    }
    
    // This tells the system: don't generate an exception when we can't write to a socket...
    int on = 1;
    setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, (void *)&on, sizeof(int));
    
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    
    addr.sin_family = AF_INET;
    addr.sin_port = htons(8125);
    inet_pton(AF_INET, "50.56.19.195", &addr.sin_addr);

    int bytesWritten = sendto(sock, [data bytes], [data length], 0, (const struct sockaddr *)&addr, sizeof(addr));
    if (bytesWritten > 0)
    {
        // Short writeswhich shouldn't happen for UDP anyway... In release builds it's okay to ignore. Just stats.
        NSAssert((NSUInteger)bytesWritten == [data length], @"Stats data sent over UDP was incomplete!");
    }
        
    close(sock);
}

+ (void)incrementCounter:(NSString *)counterName
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
    [GraphiteStats sendData:[command dataUsingEncoding:NSUTF8StringEncoding]];
}

@end

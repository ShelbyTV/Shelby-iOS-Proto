//
//  GraphiteStats.h
//  Shelby
//
//  Created by Mark Johnson on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@interface GraphiteStats : NSObject
{
    NSString *              _hostName;
    NSData *                _hostAddress;
    NSUInteger              _port;
    CFHostRef               _cfHost;
    CFSocketRef             _cfSocket;
}

- (void)sendData:(NSData *)data;

@property (nonatomic, copy,   readonly ) NSString *             hostName;       // valid in client mode
@property (nonatomic, copy,   readonly ) NSData *               hostAddress;    // valid in client mode after successful start
@property (nonatomic, assign, readonly ) NSUInteger             port;           // valid in client and server mode

@end
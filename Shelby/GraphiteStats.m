//
//  GraphiteStats.m
//  Shelby
//
//  Created by Mark Johnson on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphiteStats.h"
#import "ShelbyApp.h"
#import "UserSessionHelper.h"
#import "User.h"

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
        // Short writes which shouldn't happen for UDP anyway... In release builds it's okay to ignore. Just stats.
        assert((NSUInteger)bytesWritten == [data length]);
    }
        
    close(sock);
}

+ (void)incrementCounter:(NSString *)counterName
              withAction:(NSString *)actionName
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
    NSString *command;
    
    NSString *client;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        client = @"ios_iphone";
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        client = @"ios_ipad";
    } else {
        client = @"ios_other";
    }
    
    NSString *statName = [NSString stringWithFormat:@"app.%@.%@/?", client, counterName];
    NSString *actionParam = [NSString stringWithFormat:@"action=%@_%@", client, actionName];
    
    if (NOT_NULL([ShelbyApp sharedApp].userSessionHelper.currentUser) && 
        NOT_NULL([ShelbyApp sharedApp].userSessionHelper.currentUser.shelbyId))
    {
        command = [NSString stringWithFormat:@"%@uid=%@&%@:1|c", statName, [ShelbyApp sharedApp].userSessionHelper.currentUser.shelbyId, actionParam];
    } else {
        command = [NSString stringWithFormat:@"%@%@:1|c", statName, actionParam];
    }
      
    [GraphiteStats sendData:[command dataUsingEncoding:NSUTF8StringEncoding]];
}

@end

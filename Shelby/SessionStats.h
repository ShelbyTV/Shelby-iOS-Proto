//
//  SessionStats.h
//  Shelby
//
//  Created by Mark Johnson on 12/13/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionStats : NSObject {
    int heartbeatCount;
    NSTimer *sessionStatsTimer;
    NSDateFormatter *dateFormatter;
    NSString *clientString;
}

+ (void)startSessionReportingTimer;
+ (void)endSessionReportingTimer;
+ (void)resetHeartbeatCount;

@end

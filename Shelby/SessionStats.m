//
//  SessionStats.m
//  Shelby
//
//  Created by Mark Johnson on 12/13/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import "SessionStats.h"
#import "ShelbyApp.h"
#import "UserSessionHelper.h"
#import "User.h"
#import "NavigationViewController.h"
#import "NSURLConnection+AsyncBlock.h"

@interface SessionStats ()
- (void)initVariables;
@end

@implementation SessionStats

static SessionStats *singletonSessionStats = nil;

+ (SessionStats *)singleton
{
    if (singletonSessionStats == nil) {
        singletonSessionStats = [[super allocWithZone:NULL] init];
        [singletonSessionStats initVariables];
    }
    return singletonSessionStats;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self singleton] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


- (void)initVariables
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    clientString = [[NSString stringWithFormat:@"ios%@", [infoDictionary objectForKey:@"CFBundleVersion"]] retain];
}

- (void)startSessionReportingTimerInt
{
    if (sessionStatsTimer == nil) {
        sessionStatsTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 
                                                             target:self 
                                                           selector:@selector(sendStats:) 
                                                           userInfo:nil 
                                                            repeats:YES];
    }
}

- (void)endSessionReportingTimerInt
{
    [sessionStatsTimer invalidate];
    sessionStatsTimer = nil;
}

- (void)resetHeartbeatCountInt
{
    heartbeatCount = 0;
}

+ (void)startSessionReportingTimer
{
    [[SessionStats singleton] startSessionReportingTimerInt];
}

+ (void)endSessionReportingTimer
{
    [[SessionStats singleton] endSessionReportingTimerInt];
}

+ (void)resetHeartbeatCount
{
    [[SessionStats singleton] resetHeartbeatCountInt];
}

- (void)sendStats:(NSTimer *)timer
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
    if (NOT_NULL([ShelbyApp sharedApp].userSessionHelper.currentUser.shelbyId))
    {
        BOOL wasTouched = [ShelbyApp sharedApp].navigationViewController.touched;
        [ShelbyApp sharedApp].navigationViewController.touched = FALSE;
        
        BOOL isVideoPlaying = [[ShelbyApp sharedApp].navigationViewController isVideoPlaying];
        
        NSString *heartbeatCountString = [NSString stringWithFormat:@"%d", heartbeatCount];
        NSString *timeString = [dateFormatter stringFromDate:[NSDate date]];
        
//        NSLog(@"=========== Session Stats ===========");
//        NSLog(@"   user_id: %@", [ShelbyApp sharedApp].userSessionHelper.user.shelbyId);
//        NSLog(@"   time: %@", timeString);
//        NSLog(@"   heartbeat_count: %d", heartbeatCount);
//        NSLog(@"   focus: true");
//        NSLog(@"   activity: %@", wasTouched ? @"TRUE" : @"FALSE");
//        NSLog(@"   playing: %@", isVideoPlaying ? @"TRUE" : @"FALSE");
//        NSLog(@"   client: %@", clientString);
//        NSLog(@"=====================================");

        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [ShelbyApp sharedApp].userSessionHelper.currentUser.shelbyId , @"user_id",
                                timeString                                      , @"time",
                                heartbeatCountString                            , @"heartbeat_count",
                                @"true"                                         , @"focus",
                                wasTouched ? @"true" : @"false"                 , @"activity",
                                isVideoPlaying ? @"true" : @"false"             , @"playing",
                                clientString                                    , @"client",
                                nil];

        NSString *formString = nil;
        for (NSString *key in [params allKeys]) {
            NSString *pair = [NSString stringWithFormat:@"%@=%@", key, [params objectForKey: key]];
            if (!formString) {
                formString = pair;
            } else {
                formString = [NSString stringWithFormat:@"%@&%@", formString, pair];
            }
        }
              
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[[NSURL alloc] initWithString:@"http://cobra.shelby.tv/v1/sessions"] autorelease]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[formString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsyncRequest:request delegate:self completionSelector:@selector(receivedResponse:data:error:forRequest:)];
        
        heartbeatCount++;
    }
}

- (void)receivedResponse:(NSURLResponse *)resp
                    data:(NSData *)data
                   error:(NSError *)error
              forRequest:(NSURLRequest *)request
{
    if (NOT_NULL(error)) {
        LOG(@"SessionStats error: %@", error);
    } else {
        // LOG(@"SessionStats success");
    }
}

@end

//
//  VideoDataPoller.h
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoDataPoller : NSObject
{
    int lastPollIntervalSeconds;
    NSTimer *pollingTimer;
}

@end

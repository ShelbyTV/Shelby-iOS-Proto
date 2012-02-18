//
//  VideoDataPoller.h
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDataProcessor.h"

@interface VideoDataPoller : NSObject <VideoDataProcessorDelegate>
{
    int lastApiPollIntervalSeconds;
    
    BOOL newPlayableBroadcasts;
    
    VideoDataProcessor *dataProcessor;
}

- (void)recalculateImmediately;
- (void)clearPendingOperations;

@end
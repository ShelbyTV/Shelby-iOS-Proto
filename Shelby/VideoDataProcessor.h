//
//  VideoDataProcessor.h
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video;

@protocol VideoDataProcessorDelegate

- (void)newPlayableVideoAvailable:(Video *)video;
- (void)updateVideoTableCell:(Video *)video;

@end

@interface VideoDataProcessor : NSObject
{
    NSOperationQueue *operationQueue;
}

@property (assign) id <VideoDataProcessorDelegate> delegate;

- (void)scheduleCheckPlayable:(Video *)video;
- (void)scheduleImageAcquisition:(Video *)video;

- (void)suspendOperations;
- (void)resumeOperations;

@end

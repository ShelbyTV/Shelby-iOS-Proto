//
//  VideoData.h
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDataProcessor.h"

@class Video;
@class VideoDataPoller;
@class VideoDataProcessor;

@protocol VideoDataDelegate

- (void)newPlayableVideoAvailable:(Video *)video;
- (void)updateVideoTableCell:(Video *)video;

@end

@interface VideoData : NSObject <VideoDataProcessorDelegate>
{
    NSMutableDictionary *videoDupeDict;
    NSMutableArray *uniqueVideoKeys;
    
    VideoDataProcessor *dataProcessor;
    
    NSMutableArray *videoDataDelegates;
    
    VideoDataPoller *videoDataPoller;
}

- (NSURL *)getVideoContentURL:(Video *)video;

- (NSArray *)videoDupesForVideo:(Video *)video;
- (NSArray *)videoDupesForKey:(NSString *)videoKey;

- (NSArray *)uniqueVideoKeys;

- (void)loadInitialVideosFromAPI;
- (void)loadInitialVideosFromCoreData;

- (void)newPlayableVideoAvailable:(Video *)video;
- (void)updateVideoTableCell:(Video *)video;

- (void)addDelegate:(id<VideoDataDelegate>)consumer;

@end

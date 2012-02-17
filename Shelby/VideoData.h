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

- (void)videoTableNeedsUpdate;
- (void)updateVideoTableCell:(Video *)video;
- (void)updateTableVideos;
- (void)clearVideoTableData;

@end

@interface VideoData : NSObject <VideoDataProcessorDelegate>
{
    NSMutableDictionary *videoDupeDict;
    NSMutableArray *videoDupeArraysSorted;
    
    NSMutableDictionary *knownShelbyIds;
    
    VideoDataProcessor *dataProcessor;
    
    NSMutableArray *videoDataDelegates;
    
    VideoDataPoller *videoDataPoller;
    
    BOOL _isLoading;
}

@property (nonatomic, retain) NSDate *lastFetchBroadcasts;

- (BOOL)isLoading;

- (NSURL *)getVideoContentURL:(Video *)video;

- (NSArray *)videoDupesForVideo:(Video *)video;
- (NSArray *)videoDupesForKey:(NSString *)videoKey;

- (NSArray *)videoDupeArraysSorted;

- (void)loadInitialVideosFromAPI;
- (void)loadInitialVideosFromCoreData;

- (void)videoTableNeedsUpdate;
- (void)updateVideoTableCell:(Video *)video;

- (void)addDelegate:(id<VideoDataDelegate>)consumer;

- (BOOL)isKnownVideoKey:(NSString *)key;
- (BOOL)isKnownShelbyId:(NSString *)shelbyId;

- (void)loadAdditionalVideosFromCoreData;

- (void)reloadTableVideos;

@end

//
//  VideoTableData.h
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkObject.h"
#import "VideoData.h"

@class VideoTableData;
@class Video;

@protocol VideoTableDataDelegate

- (void)videoTableDataDidFinishRefresh:(VideoTableData *)videoTableData;

@end

@interface VideoTableData : NSObject <NetworkObject, VideoDataDelegate>
{
    UITableView *tableView;
    NSMutableArray *tableVideos;
    NSMutableDictionary *playableVideoKeys;
    NSOperationQueue *operationQueue;
    NSTimer *updateTimer;
    BOOL videoTableNeedsUpdate;
}

@property (unsafe_unretained) id <VideoTableDataDelegate> delegate;
@property (readonly) NSInteger networkCounter;
@property (readonly) NSUInteger numItemsInserted;

- (id)initWithUITableView:(UITableView *)linkedTableView;

- (NSUInteger)numItemsInserted;
- (NSURL *)videoContentURLAtIndex:(NSUInteger)index;
- (Video *)videoAtIndex:(NSUInteger)index;

- (void)updateTableVideosNoAnimation;
- (void)updateTableVideos;
- (void)updateVideoTableCell:(Video *)video;
- (BOOL)shouldIncludeVideo:(NSArray *)dupeArray;

- (void)videosAvailable;

- (void)videoTableNeedsUpdate;
- (void)reset;

@end

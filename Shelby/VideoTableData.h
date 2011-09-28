//
//  VideoTableData.h
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STVNetworkObject.h"

@class VideoTableData;

@protocol VideoTableDataDelegate

//- (void)videoTableDataDidBeginRefresh:(VideoTableData *)videoTableData;
- (void)videoTableDataDidFinishRefresh:(VideoTableData *)videoTableData;

@end

@interface VideoTableData : NSObject <STVNetworkObject>
{
    NSOperationQueue *operationQueue;
    UITableView *tableView;
    NSMutableArray *videoDataArray;
    NSUInteger currentArrayGeneration;
    NSUInteger lastInserted;
    NSTimer *updateTimer;
}
@property (assign) id <VideoTableDataDelegate> delegate;
@property (readwrite) NSInteger networkCounter;
@property (readwrite) BOOL likedOnly;

- (id)initWithUITableView:(UITableView *)linkedTableView;

- (BOOL)isLoading;
- (NSUInteger)numItemsInserted;
- (NSUInteger)numItems;
- (NSString *)videoShelbyIdAtIndex:(NSUInteger)index;
- (NSDate *)videoCreatedAtIndex:(NSUInteger)index;
- (NSString *)videoSourceAtIndex:(NSUInteger)index;
- (NSString *)videoTitleAtIndex:(NSUInteger)index;
- (NSString *)videoSharerAtIndex:(NSUInteger)index;
- (UIImage *)videoSharerImageAtIndex:(NSUInteger)index;
- (NSString *)videoSharerCommentAtIndex:(NSUInteger)index;
- (UIImage *)videoThumbnailAtIndex:(NSUInteger)index;
- (NSURL *)videoContentURLAtIndex:(NSUInteger)index;
- (BOOL)videoLikedAtIndex:(NSUInteger)index;
- (BOOL)videoWatchedAtIndex:(NSUInteger)index;
- (void)clearVideos;
#ifdef OFFLINE_MODE
- (void)loadVideos;
#endif

- (void)retrieveAndStoreYouTubeVideoData:(id)youTubeURL;
- (void)updateTableView;

- (void)gotNewCoreDataBroadcasts;

+ (NSString *)createYouTubeVideoInfoURLWithVideo:(NSString *)video;

@end

//
//  VideoTableData.h
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoTableData;

@protocol VideoTableDataDelegate

- (void)videoTableDataDidFinishRefresh:(VideoTableData *)videoTableData;

@end

@interface VideoTableData : NSObject
{
    NSOperationQueue *operationQueue;
    UITableView *tableView;
    NSMutableArray *videoDataArray;
    NSUInteger lastInserted;
    NSTimer *updateTimer;
}
@property (assign) id <VideoTableDataDelegate> delegate;

- (id)initWithUITableView:(UITableView *)linkedTableView;

- (NSUInteger)numItems;
- (NSString *)videoTitleAtIndex:(NSUInteger)index;
- (NSString *)videoSharerAtIndex:(NSUInteger)index;
- (UIImage *)videoSharerImageAtIndex:(NSUInteger)index;
- (NSString *)videoSharerCommentAtIndex:(NSUInteger)index;
- (UIImage *)videoThumbnailAtIndex:(NSUInteger)index;
- (NSURL *)videoContentURLAtIndex:(NSUInteger)index;
- (void)loadVideos;

- (void)retrieveAndStoreYouTubeVideoData:(id)youTubeURL;
- (void)updateTableView;

+ (NSString *)createYouTubeVideoInfoURLWithVideo:(NSString *)video;

@end

//
//  VideoTableData.h
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoTableData : NSObject
{
    NSOperationQueue *operationQueue;
    UITableView *tableView;
    NSMutableArray *videoDataArray;
    NSUInteger lastInserted;
    NSTimer *updateTimer;
}

- (id)initWithUITableView:(UITableView *)linkedTableView;

- (NSUInteger)numItems;
- (NSString *)videoTitleAtIndex:(NSUInteger)index;
- (NSString *)videoSharerAtIndex:(NSUInteger)index;
- (UIImage *)videoThumbnailAtIndex:(NSUInteger)index;
- (NSURL *)videoContentURLAtIndex:(NSUInteger)index;
- (void)loadVideos;

- (void)retrieveYouTubeThumbnailAndStoreVideoData:(id)youTubeURL;
- (void)updateTableView;

+ (NSString *)createYouTubeVideoInfoURLWithVideo:(NSString *)video;

@end

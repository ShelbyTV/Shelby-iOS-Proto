//
//  VideoTableData.h
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkObject.h"

@class VideoTableData;
@class Video;

@protocol VideoTableDataDelegate

- (void)videoTableDataDidFinishRefresh:(VideoTableData *)videoTableData;

@end

@interface VideoTableData : NSObject <NetworkObject>
{
    UITableView *tableView;
    NSMutableArray *tableVideos;
    NSMutableDictionary *playableVideoKeys;
    NSOperationQueue *operationQueue;
    NSTimer *updateTimer;
    BOOL videoTableNeedsUpdate;
}

@property (assign) id <VideoTableDataDelegate> delegate;
@property (readonly) NSInteger networkCounter;
@property (readwrite) BOOL likedOnly;
@property (readwrite) BOOL watchLaterOnly;
@property (readwrite) BOOL searchOnly;
@property (readonly) NSUInteger numItemsInserted;
@property (nonatomic, retain) NSString *searchString;

- (id)initWithUITableView:(UITableView *)linkedTableView;

- (NSUInteger)numItemsInserted;
- (NSURL *)videoContentURLAtIndex:(NSUInteger)index;
- (Video *)videoAtIndex:(NSUInteger)index;

- (void)clearVideoTableData;
- (void)reloadTableVideos;
- (void)updateVideoTableCell:(Video *)video;


@end

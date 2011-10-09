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
@class Video;

@protocol VideoTableDataDelegate

//- (void)videoTableDataDidBeginRefresh:(VideoTableData *)videoTableData;
- (void)videoTableDataDidFinishRefresh:(VideoTableData *)videoTableData;

@end

@interface VideoTableData : NSObject <STVNetworkObject>
{
    NSOperationQueue *operationQueue;
    UITableView *tableView;
    NSMutableArray *tableVideos;
    NSMutableArray *uniqueVideoKeys;
    NSMutableDictionary *videoDupeDict;
    NSUInteger lastInserted;
}

@property (assign) id <VideoTableDataDelegate> delegate;
@property (readonly) NSInteger networkCounter;
@property (readwrite) BOOL likedOnly;
@property (readwrite) BOOL watchLaterOnly;

- (id)initWithUITableView:(UITableView *)linkedTableView;

- (BOOL)isLoading;
- (NSUInteger)numItemsInserted;
- (NSUInteger)numItems;
- (NSURL *)videoContentURLAtIndex:(NSUInteger)index;
- (int)videoDupeCount:(Video *)video;
- (Video *)videoAtIndex:(NSUInteger)index;
- (NSArray *)videoDupes:(Video *)video;

- (void)clearVideoTableData;
- (void)reloadTableVideos;

@end

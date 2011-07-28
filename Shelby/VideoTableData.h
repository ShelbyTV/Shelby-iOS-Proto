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
}

@property (nonatomic, readonly) NSUInteger numItems;

- (id)initWithUITableView:(UITableView *)linkedTableView;

- (NSString *)videoTitleAtIndex:(NSUInteger)index;
- (NSString *)videoSharerAtIndex:(NSUInteger)index;
- (UIImage *)videoThumbnailAtIndex:(NSUInteger)index;
- (NSURL *)videoContentURLAtIndex:(NSUInteger)index;

- (void)retrieveVideoThumbnail:(id)thumbnailURL;
- (void)retrieveYouTubeVideoContentURL:(id)youTubeURL;

@end

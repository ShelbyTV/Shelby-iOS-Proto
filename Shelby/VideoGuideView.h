//
//  VideoGuideView.h
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoTableViewController.h"

@class VideoTableViewController;
@class VideoTableData;
@class Video;

@interface VideoGuideView : UIView
{
    id<VideoTableViewControllerDelegate> _delegate;
    VideoTableViewController *_videoTableViewController;
    VideoTableData *_videoTableData;
}

- (id)initWithVideoTableViewControllerDelegate:(id<VideoTableViewControllerDelegate>)delegate;

- (Video *)getNextVideo;
- (Video *)getPreviousVideo;
- (Video *)getFirstVideo;

- (void)updateVideoTableCell:(Video *)video;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (void)setHidden:(BOOL)hidden;

@end

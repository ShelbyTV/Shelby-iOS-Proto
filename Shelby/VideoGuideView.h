//
//  VideoGuideView.h
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoTableViewController;
@class VideoTableViewControllerDelegate;
@class VideoTableData;
@class Video;

@interface VideoGuideView : UIView
{
    VideoTableViewControllerDelegate *_delegate;
    VideoTableViewController *_videoTableViewController;
    VideoTableData *_videoTableData;
}

- (id)initWithVideoTableViewControllerDelegate:(VideoTableViewControllerDelegate *)delegate;

- (Video *)getNextVideo;
- (Video *)getPreviousVideo;
- (void)updateVideoTableCell:(Video *)video;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end

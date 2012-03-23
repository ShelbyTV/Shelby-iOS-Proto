//
//  VideoGuideView.m
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoGuideView.h"
#import "VideoTableViewController.h"

@implementation VideoGuideView

- (id)initWithFrame:(CGRect)frame withDelegate:(id<VideoTableViewControllerDelegate>)delegate;
{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
        _originalFrame = frame;
    }
    return self;
}

- (Video *)getNextVideo
{
    return [_videoTableViewController getNextVideo];
}

- (Video *)getPreviousVideo
{
    return [_videoTableViewController getPreviousVideo];
}

- (Video *)getFirstVideo
{
    return [_videoTableViewController getFirstVideo];
}

- (void)updateVideoTableCell:(Video *)video
{
    [_videoTableData updateVideoTableCell:video];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_videoTableViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_videoTableViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)setHidden:(BOOL)hidden
{
    if (!hidden) {
        [_videoTableData updateTableVideosNoAnimation];
    }
    
    [super setHidden:hidden];
}

- (void)reset
{
    [_videoTableData reset];
}

@end

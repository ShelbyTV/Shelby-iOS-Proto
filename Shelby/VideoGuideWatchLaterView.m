//
//  VideoGuideWatchLaterView.m
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoGuideWatchLaterView.h"
#import "VideoTableWatchLaterData.h"
#import "VideoTableViewController.h"

@implementation VideoGuideWatchLaterView

- (id)initWithFrame:(CGRect)frame withDelegate:(id<VideoTableViewControllerDelegate>)delegate;
{
    self = [super initWithFrame:frame withDelegate:delegate];
    if (self) {
        
        _videoTableViewController = [[VideoTableViewController alloc] init];
        _videoTableViewController.delegate = delegate;
        _videoTableData = _videoTableWatchLaterData =  [[VideoTableWatchLaterData alloc] initWithUITableView:_videoTableViewController.tableView];
        _videoTableViewController.videoTableData = _videoTableData;
        _videoTableData.delegate = _videoTableViewController;
        
        [_videoTableViewController.tableView setBackgroundColor:[UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.0]];
        [_videoTableViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        _videoTableViewController.tableView.frame = self.bounds;
        _videoTableViewController.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _videoTableViewController.tableView.frame = self.bounds;
        [self addSubview:_videoTableViewController.tableView];
    }
    return self;
}

@end

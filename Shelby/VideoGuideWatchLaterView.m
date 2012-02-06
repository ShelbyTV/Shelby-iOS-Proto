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

- (id)initWithVideoTableViewControllerDelegate:(VideoTableViewControllerDelegate *)delegate
{
    self = [super initWithVideoTableViewControllerDelegate:delegate];
    if (self) {
        
        _videoTableViewController = [[VideoTableViewController alloc] init];
        _videoTableData = _videoTableWatchLaterData =  [[VideoTableWatchLaterData alloc] initWithUITableView:_videoTableViewController.tableView];
        _videoTableViewController.videoTableData = _videoTableData;
        _videoTableData.delegate = _videoTableViewController;
        
        [_videoTableViewController.tableView setBackgroundColor:[UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.0]];
        [_videoTableViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return self;
}


@end

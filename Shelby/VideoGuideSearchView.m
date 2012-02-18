//
//  VideoGuideSearchView.m
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoGuideSearchView.h"
#import "VideoTableSearchData.h"
#import "VideoTableViewController.h"

@implementation VideoGuideSearchView

- (id)initWithVideoTableViewControllerDelegate:(id<VideoTableViewControllerDelegate>)delegate
{
    self = [super initWithVideoTableViewControllerDelegate:delegate];
    if (self) {
        
        _videoTableViewController = [[VideoTableViewController alloc] init];
        _videoTableViewController.delegate = delegate;
        _videoTableData = _videoTableSearchData =  [[VideoTableSearchData alloc] initWithUITableView:_videoTableViewController.tableView];
        _videoTableViewController.videoTableData = _videoTableData;
        _videoTableData.delegate = _videoTableViewController;
        
        [_videoTableViewController.tableView setBackgroundColor:[UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.0]];
        [_videoTableViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        _videoTableViewController.tableView.frame = self.bounds;
        [self addSubview:_videoTableViewController.tableView];
    }
    return self;
}

- (void)performSearch:(NSString *)searchText
{
    _videoTableSearchData.searchString = searchText;
    [_videoTableData clearVideoTableData];
    [_videoTableData updateTableVideos];
}

- (void)reset
{
    _videoTableSearchData.searchString = @"";
    [super reset];
}

@end

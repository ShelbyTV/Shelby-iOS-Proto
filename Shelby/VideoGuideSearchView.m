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

#import "ShelbyApp.h"

@implementation VideoGuideSearchView

- (id)initWithFrame:(CGRect)frame withDelegate:(id<VideoTableViewControllerDelegate>)delegate;
{
    self = [super initWithFrame:frame withDelegate:delegate];
    if (self) {
        
        _videoTableViewController = [[VideoTableViewController alloc] init];
        _videoTableViewController.delegate = delegate;
        _videoTableData = _videoTableSearchData =  [[VideoTableSearchData alloc] initWithUITableView:_videoTableViewController.tableView];
        _videoTableViewController.videoTableData = _videoTableData;
        _videoTableData.delegate = _videoTableViewController;
        
        [_videoTableViewController.tableView setBackgroundColor:[UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.0]];
        [_videoTableViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = TRUE;
        
        _videoTableViewController.tableView.frame = self.bounds;
        _videoTableViewController.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_videoTableViewController.tableView];
    }
    return self;
}

- (void)updateVideoTable:(NSTimer*)timer
{
    [_videoTableData performSelectorOnMainThread:@selector(updateTableVideos) withObject:nil waitUntilDone:NO];
}

- (void)performSearch:(NSString *)searchText
{
    _videoTableSearchData.searchString = searchText;
    
    [_videoTableData clearVideoTableData];
    
    //hack to execute outside of this run loop instance... prevents weird scrollview bug
    [NSTimer scheduledTimerWithTimeInterval:0 
                                     target:self
                                   selector:@selector(updateVideoTable:) 
                                   userInfo:nil 
                                    repeats:NO];
}

- (void)reset
{
    _videoTableSearchData.searchString = @"";
    [super reset];
}

@end

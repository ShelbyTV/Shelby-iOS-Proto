//
//  VideoTableViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoTableViewController.h"
#import "VideoTableData.h"
#import "Video.h"
#import "ShelbyApp.h"
#import "LoginHelper.h"
#import "GraphiteStats.h"
#import "VideoTableViewCell.h"
#import "User.h"
#import "VideoTableViewCellConstants.h"

@implementation VideoTableViewController

@synthesize videoCell;
@synthesize delegate;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style
     callbackObject:(id)object
   callbackSelector:(SEL)selector
{
    self = [super initWithStyle:style];
    
    if (self) {
        videoTableData = [[VideoTableData alloc] initWithUITableView:self.tableView];
        videoTableData.delegate = self;

        [[ShelbyApp sharedApp] addNetworkObject: videoTableData];

        callbackObject = object;
        callbackSelector = selector;
        _currentVideoIndex = 0;
    }
    
    return self;
}

#pragma mark - Video Mode

// Alternate between favorites and timeline.

- (void)changeVideoMode:(NSInteger)mode
{
    if (mode == videoMode) {
        return;
    }

    //LOG(@"changeVideoMode %d", mode);
    if (mode == 0) {
        videoTableData.searchOnly = NO;
        videoTableData.likedOnly = NO;
        videoTableData.watchLaterOnly = NO;
    } else if (mode == 1) {
        videoTableData.searchOnly = NO;
        videoTableData.likedOnly = YES;
        videoTableData.watchLaterOnly = NO;
    } else if (mode == 2) {
        videoTableData.searchOnly = NO;
        videoTableData.likedOnly = NO;
        videoTableData.watchLaterOnly = YES;
    } else if (mode == 3) {
        videoTableData.searchOnly = YES;
        videoTableData.likedOnly = NO;
        videoTableData.watchLaterOnly = NO;
    }
    
    // Change the channel.
    videoMode = mode;
    [videoTableData reloadTableVideos];
}

- (void)performSearch:(NSString *)searchText
{
    videoTableData.searchString = searchText;
    [videoTableData reloadTableVideos];
}

#pragma mark - Data Refresh

- (void)clearVideoTableData
{
    // Clear out the table.
    [videoTableData clearVideoTableData];
    _currentVideoIndex = 0;
}

- (void)loadVideos
{
    [[ShelbyApp sharedApp].loginHelper fetchBroadcasts];
}

- (void)doneLoadingTableViewData
{
	// Tell the UI.
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];

    // Tell the world?
    if (self.delegate) {
        [self.delegate videoTableViewControllerFinishedRefresh: self];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName: @"VideoTableViewControllerFinishedRefresh"
                                                        object: self
                                                        ];
}

- (void)updateVideoTableCell:(Video *)video
{
    [videoTableData updateVideoTableCell:video];
}

#pragma mark - Next/Previous Videos

- (Video *)videoAtTableDataIndex:(NSUInteger)index
{
    // make sure we initiate getting the content URL
    [videoTableData videoContentURLAtIndex:index];

    return [videoTableData videoAtIndex:index];
}

- (Video *)getFirstVideo
{
    return [self videoAtTableDataIndex:0];
}

- (Video *)getNextVideo
{
    _currentVideoIndex++;
    if (_currentVideoIndex >= [videoTableData numItemsInserted]) {
        // Set to first index.
        _currentVideoIndex = 0;
    }

    // Return the next video.
    Video *video = [self videoAtTableDataIndex:_currentVideoIndex];

    if (NOT_NULL(video)) {
        // Scroll to the next table cell.
        [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: _currentVideoIndex inSection: 0]
                              atScrollPosition: UITableViewScrollPositionMiddle
                                      animated: YES];

        return video;
    } else {
        return nil;
    }
}

- (Video *)getPreviousVideo
{
    _currentVideoIndex--;
    if (_currentVideoIndex < 0) {
        // Set to last index.
        _currentVideoIndex = [videoTableData numItemsInserted] - 1;
    }

    // Return the previous video.
    Video *video = [self videoAtTableDataIndex: _currentVideoIndex];

    if (NOT_NULL(video)) {
        // Scroll to the previous table cell.
        [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: _currentVideoIndex inSection: 0]
                              atScrollPosition: UITableViewScrollPositionMiddle
                                      animated: YES];

        return video;
    } else {
        return nil;
    }
}

#pragma mark - UI Callbacks

- (IBAction)toolbarButtonWasPressed:(id)sender
{
    LOG(@"toolbarButtonWasPressed %@", sender);
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (delegate)
    {
        [delegate videoTableWasTouched];
    }
    
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
	[self loadVideos];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [videoTableData isLoading]; // return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return IS_NULL([ShelbyApp sharedApp].loginHelper.lastFetchBroadcasts) ? [NSDate date] : 
              [ShelbyApp sharedApp].loginHelper.lastFetchBroadcasts; // should return date data source was last changed
}

#pragma mark - VideoTableDataDelegate Methods

- (void)videoTableDataDidFinishRefresh:(VideoTableData *)videoTableData
{
    [self doneLoadingTableViewData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Init the pull-to-refresh header.
    if (_refreshHeaderView == nil) {
      EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
      view.delegate = self;
      [self.tableView addSubview:view];
      _refreshHeaderView = view;
      [view release];
    }
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [videoTableData numItemsInserted];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *videoCellIdentifier = @"VideoTableViewCell";
    
    NSUInteger row = indexPath.row;
    VideoTableViewCell *dynVideoCell = (VideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
    
    if (dynVideoCell == nil) {
        dynVideoCell = [[[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier] autorelease];
    }
    
    dynVideoCell.videoTableData = videoTableData;
    [dynVideoCell setVideo:[videoTableData videoAtIndex:row]];
    dynVideoCell.viewController = self;
    [dynVideoCell setNeedsDisplay];
    
    return dynVideoCell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;

    Video *video = [videoTableData videoAtIndex:row];
    if (video.cellHeightCurrent != 0.0f) {
        return video.cellHeightCurrent;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return IPHONE_CELL_HEIGHT;
    } else {
        return IPAD_CELL_HEIGHT;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (delegate)
    {
        [delegate videoTableWasTouched];
    }
    
    [GraphiteStats incrementCounter:@"ui.table_video_click" withAction:@"table_video_click"];

    // Right now we can just bank on only having a single table, so no need to do anything fancy with the indexPath.
    NSUInteger row = indexPath.row;
    
    Video *video = [self videoAtTableDataIndex:row];
    _currentVideoIndex = row;

    [callbackObject performSelector:callbackSelector withObject:video];
}

#pragma mark - Cleanup

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)enableDemoMode
{
    [videoTableData enableDemoMode];
}

- (NSInteger)currentVideoMode
{
    return videoMode;
}


@end

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
#import "UserSessionHelper.h"
#import "GraphiteStats.h"
#import "VideoTableViewCell.h"
#import "User.h"
#import "VideoTableViewCellConstants.h"
#import "VideoData.h"
#import "Enums.h"

#import "DemoMode.h"

@implementation VideoTableViewController

@synthesize videoCell;
@synthesize delegate;
@synthesize videoTableData;

#pragma mark - Data Refresh

- (void)reset
{
    _currentVideoIndex = 0;
}

- (void)doneLoadingTableViewData
{
	// Tell the UI.
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];

    [[NSNotificationCenter defaultCenter] postNotificationName: @"VideoTableViewControllerFinishedRefresh"
                                                        object: self
                                                        ];
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
    
    [[ShelbyApp sharedApp].videoData loadAdditionalVideosFromCoreData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [[ShelbyApp sharedApp].videoData isLoading]; // return if data source model is reloading
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
    [dynVideoCell setVideo:[videoTableData videoAtIndex:row] andSizeFrames:YES];
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

    if (delegate)
    {
        NSLog(@"Calling VideoTableViewController delegate playVideo");
        [delegate playVideo:video];
    }
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
    [DemoMode enableDemoMode];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSArray *visibleCells = [[[NSArray alloc] initWithArray:self.tableView.visibleCells] autorelease];
    
    for (UITableViewCell *cell in visibleCells) {
        [(VideoTableViewCell *)cell didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

@end

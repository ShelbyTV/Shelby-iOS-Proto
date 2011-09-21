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
#import "NetworkManager.h"

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
        callbackObject = object;
        callbackSelector = selector;
    }
    return self;
}

#pragma mark - Video Mode

// Alternate between favorites and timeline.

- (void)changeVideoMode:(NSInteger)mode
{
    LOG(@"changeVideoMode %d", mode);
    // Clear out the table.
    [videoTableData clearVideos];

    // Change the channel.
    [[ShelbyApp sharedApp].networkManager changeChannel: mode];

    // Wait for new data.

}

#pragma mark - Data Refresh

- (void)clearVideos
{
    // Clear out the table.
    [videoTableData clearVideos];
}

- (void)loadVideos
{
#ifdef OFFLINE_MODE
    [videoTableData loadVideos];
#else
    [[ShelbyApp sharedApp].networkManager fetchBroadcasts];
#endif
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

#pragma mark - Next/Previous Videos

- (Video *)videoAtTableDataIndex:(NSUInteger)index
{
    Video *video = [[[Video alloc] init] autorelease];

    video.contentURL = [videoTableData videoContentURLAtIndex: index];

    video.thumbnailImage = [videoTableData videoThumbnailAtIndex: index];
    video.title = [videoTableData videoTitleAtIndex: index];

    video.sharer = [videoTableData videoSharerAtIndex: index];
    video.sharerImage = [videoTableData videoSharerImageAtIndex: index];
    video.sharerComment = [videoTableData videoSharerCommentAtIndex: index];
    video.contentURL = [videoTableData videoContentURLAtIndex: index];

    return video;
}

- (Video *)getCurrentVideo
{
    return [self videoAtTableDataIndex: _currentVideoIndex];
}

- (Video *)getNextVideo
{
    _currentVideoIndex++;
    if (_currentVideoIndex >= [videoTableData numItems]) {
        // Set to first index.
        _currentVideoIndex = 0;
    }

    // Scroll to the next table cell.
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: _currentVideoIndex inSection: 0]
                          atScrollPosition: UITableViewScrollPositionMiddle
                                  animated: YES];

    // Return the next video.
    return [self videoAtTableDataIndex: _currentVideoIndex];
}

- (Video *)getPreviousVideo
{
    _currentVideoIndex--;
    if (_currentVideoIndex < 0) {
        // Set to last index.
        _currentVideoIndex = [videoTableData numItems] - 1;
    }

    // Scroll to the previous table cell.
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: _currentVideoIndex inSection: 0]
                          atScrollPosition: UITableViewScrollPositionMiddle
                                  animated: YES];

    // Return the previous video.
    return [self videoAtTableDataIndex: _currentVideoIndex];
}

#pragma mark - UI Callbacks

- (IBAction)segmentAction:(UISegmentedControl *)sender
{
    LOG(@"segmentAction %@", sender);
    NSInteger index = sender.selectedSegmentIndex;
    [self changeVideoMode: index];

}

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
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self loadVideos];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [videoTableData isLoading]; // return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *imageItem = [[UIBarButtonItem alloc]
    //    initWithImage:[UIImage imageNamed: @"ButtonFavoritesNormal.png"]
    //            style:UIBarButtonItemStylePlain
    //           target:self
    //           action:@selector(toolbarButtonWasPressed:)];

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

    // Init the segmented control.
    UIImage *likeImageCropped = [UIImage imageNamed: @"ButtonFavoritesCropped"];
    UIImage *timeImageCropped = [UIImage imageNamed: @"ButtonTimeCropped"];

    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:
        likeImageCropped,
        timeImageCropped,
        nil]
        ];
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

    //segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segmentedControl.tintColor = [UIColor blackColor];

    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView: segmentedControl];
    [self.navigationItem setLeftBarButtonItem:customItem animated: NO];
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
    NSInteger count = [videoTableData numItems];
    if (count == 0) {
        // Show the table empty view.
    } else {

    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VideoCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [[NSBundle mainBundle] loadNibNamed:@"VideoCell_iPhone" owner:self options:nil];
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"VideoCell_iPad" owner:self options:nil];
        }
        cell = videoCell;

        // Set the gradient as the background
        UIImage *image = [UIImage imageNamed:@"CellGradient.png"];
        if (cell.backgroundView) {
            ((UIImageView *)cell.backgroundView).image = image;
        } else {
            cell.backgroundView = [[[UIImageView alloc] initWithImage: image] autorelease];
        }

        self.videoCell = nil;
    }

    // Configure the cell...
    NSUInteger row = indexPath.row;

    /*
     * This method of loading UITableViewCells from NIB/XIB files and setting the properties
     * via view tags is recommended by Apple here:
     *
     * http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/TableView_iPhone/TableViewCells/TableViewCells.html
     *
     * See the "Loading Custom Table-View Cells From Nib Files" section and sub-section
     * "The Technique for Dynamic Row Content"
     */

    // currently not correctly setting icon for watched/unwatched yet
    UIImageView *sourceTag = (UIImageView *)[cell viewWithTag:1];
    NSString *videoSource = [videoTableData videoSourceAtIndex:row];
    if ([videoSource isEqualToString:@"twitter"]) {
        sourceTag.image = [UIImage imageNamed:@"TwitterNew"];
    } else if ([videoSource isEqualToString:@"facebook"]) {
        sourceTag.image = [UIImage imageNamed:@"FacebookNew"];
    } else if ([videoSource isEqualToString:@"tumblr"]) {
        sourceTag.image = [UIImage imageNamed:@"TumblrNew"];
    }

    UIImageView *videoThumbnail = (UIImageView *)[cell viewWithTag:2];
    videoThumbnail.image = [videoTableData videoThumbnailAtIndex:row];

    UILabel *sharerComment = (UILabel *)[cell viewWithTag:3];
    sharerComment.text = [videoTableData videoSharerCommentAtIndex:row];

    UIImageView *sharerImage = (UIImageView *)[cell viewWithTag:4];
    sharerImage.image = [videoTableData videoSharerImageAtIndex:row];;

    UILabel *sharer = (UILabel *)[cell viewWithTag:5];
    sharer.text = [videoTableData videoSharerAtIndex:row];

    // tag 6 is time in minutes/hours ago -- not setting this yet

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
       <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */

    // Right now we can just bank on only having a single table, so no need to do anything fancy with the indexPath.
    NSUInteger row = indexPath.row;


    Video *video = [self videoAtTableDataIndex: row];

    //NSURL *contentURL = [videoTableData videoContentURLAtIndex: row];

    _currentVideoIndex = row;

    //[callbackObject performSelector:callbackSelector withObject:contentURL];
    [callbackObject performSelector:callbackSelector withObject:video];
}

#pragma mark - Cleanup

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


@end

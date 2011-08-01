//
//  VideoTableViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoTableViewController.h"
#import "VideoTableData.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation VideoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        videoTableData = [[VideoTableData alloc] initWithUITableView:self.tableView];
    }
    return self;
}

- (void)loadVideos
{
    [videoTableData loadVideos];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [videoTableData numItems];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSUInteger whichCell[2];
    [indexPath getIndexes:whichCell];
    
    /*
     * Right now, this is pretty bad UI. The table can initially show up without any thumbnail images.
     * See the comment at the top of VideoTableData.m about how we should really be loading data and properly
     * inserting new data / cells into the UITableView in a graceful, animated way.
     *
     * In the current ghetto UITableView display, you can get the thumbnails to display if they're blank by
     * dragging the list really far down and really far up.
     */
    cell.textLabel.text = [videoTableData videoTitleAtIndex:whichCell[1]];
    cell.detailTextLabel.text = [videoTableData videoSharerAtIndex:whichCell[1]];
    cell.imageView.image = [videoTableData videoThumbnailAtIndex:whichCell[1]];
    
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
    NSUInteger whichCell[2];
    [indexPath getIndexes:whichCell];
    
    NSURL *contentURL = [videoTableData videoContentURLAtIndex:whichCell[1]];
    
    /*
     * This is pretty ghetto, but it's a quick way to display a video. Eventually this should load the contentURL into
     * the custom Shelby movie view, etc. Not sure if moviePlayer will get properly cleaned up when user hits "Done" -- 
     * definitely bad that it randomly disappears on user hitting minimize.
     *
     * Plus, because of ways views are currently set up, MoviePlayer doesn't autorotate properly.
     */
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:contentURL];
    [[self view] addSubview:[moviePlayer view]];
    [moviePlayer setFullscreen:YES];
}

@end

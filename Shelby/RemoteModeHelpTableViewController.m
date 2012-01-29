//
//  RemoteModeHelpTableViewController.m
//  Shelby
//
//  Created by Mark Johnson on 1/28/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "RemoteModeHelpTableViewController.h"


@implementation RemoteModeHelpTableViewController

@synthesize helpCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
    return 12;
}

- (UIImage *)gestureImageForRow:(int)row
{
    switch (row) {
        case 0:
            return [UIImage imageNamed:@"oneFingerTap"];
            break;
            
        case 1:
            return [UIImage imageNamed:@"twoFingerTap"];
            break;
            
        case 2:
            return [UIImage imageNamed:@"oneFingerSwipeLeft"];
            break;
            
        case 3:
            return [UIImage imageNamed:@"oneFingerSwipeRight"];
            break;
            
        case 4:
            return [UIImage imageNamed:@"oneFingerSwipeDown"];
            break;
            
        case 5:
            return [UIImage imageNamed:@"oneFingerSwipeUp"];
            break;
            
        case 6:
            return [UIImage imageNamed:@"twoFingerSwipeLeft"];
            break;
            
        case 7:
            return [UIImage imageNamed:@"twoFingerSwipeRight"];
            break;
            
        case 8:
            return [UIImage imageNamed:@"twoFingerSwipeDown"];
            break;
            
        case 9:
            return [UIImage imageNamed:@"twoFingerSwipeUp"];
            break;
            
        case 10:
            return [UIImage imageNamed:@"spread"];
            break;
            
        case 11:
            return [UIImage imageNamed:@"pinch"];
            break;
            
        default:
            return nil;
            break;
    }
    
    return nil;
}

- (NSString *)gestureStringForRow:(int)row
{
    switch (row) {
        case 0:
            return @"ONE FINGER TAP";
            break;
            
        case 1:
            return @"TWO FINGER TAP";
            break;
            
        case 2:
            return @"ONE FINGER SWIPE LEFT";
            break;
            
        case 3:
            return @"ONE FINGER SWIPE RIGHT";
            break;
            
        case 4:
            return @"ONE FINGER SWIPE DOWN";
            break;
            
        case 5:
            return @"ONE FINGER SWIPE UP";
            break;
            
        case 6:
            return @"TWO FINGER SWIPE LEFT";
            break;
            
        case 7:
            return @"TWO FINGER SWIPE RIGHT";
            break;
            
        case 8:
            return @"TWO FINGER SWIPE DOWN";
            break;
            
        case 9:
            return @"TWO FINGER SWIPE UP";
            break;
            
        case 10:
            return @"TWO FINGER SPREAD";
            break;
            
        case 11:
            return @"TWO FINGER PINCH";
            break;
            
        default:
            return nil;
            break;
    }
    
    return nil;
}

- (NSString *)commandStringForRow:(int)row
{
    switch (row) {
        case 0:
            return @"SHOW/HIDE CONTEXT";
            break;
            
        case 1:
            return @"PLAY/PAUSE";
            break;
            
        case 2:
            return @"NEXT VIDEO";
            break;
            
        case 3:
            return @"PREVIOUS VIDEO";
            break;
            
        case 4:
            return @"TOGGLE WATCH LATER";
            break;
            
        case 5:
            return @"TOGGLE FAVORITE";
            break;
            
        case 6:
            return @"SCAN BACK";
            break;
            
        case 7:
            return @"SCAN AHEAD";
            break;
            
        case 8:
            return @"NEXT CHANNEL";
            break;
            
        case 9:
            return @"PREVIOUS CHANNEL";
            break;
            
        case 10:
            return @"SHARE VIDEO";
            break;
            
        case 11:
            return @"EXIT TOUCHPLAY";
            break;
            
        default:
            return nil;
            break;
    }
    
    return nil;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RemoteModeHelpCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"RemoteModeHelpCell" owner:self options:nil];
        cell = helpCell;
        self.helpCell = nil;
    }
    
    ((UILabel *)[cell viewWithTag:1]).text = [self gestureStringForRow:indexPath.row];
    ((UILabel *)[cell viewWithTag:2]).text = [self commandStringForRow:indexPath.row];
    ((UIImageView *)[cell viewWithTag:3]).image = [self gestureImageForRow:indexPath.row];
    
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
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
}

@end

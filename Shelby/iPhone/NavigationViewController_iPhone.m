//
//  NavigationViewController_iPhone.m
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 * Eventually there will be device-specific logic in these NavigationViewController subclasses,
 * since both devices have very different navigation.
 */

#import "NavigationViewController_iPhone.h"
#import "SettingsViewController.h"

@implementation NavigationViewController_iPhone

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Background.
    [header setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ForegroundStripes" ofType:@"png"]]]];
    
    // iPhone video player is always in fullscreen mode.
    [_videoPlayer setFullscreen:TRUE];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - 

//- (void)showSettings {
//    if (![_navigationController.topViewController isKindOfClass: [SettingsViewController class]]) {
//        // If we're not already showing settings, show settings.
//        SettingsViewController *vc = [SettingsViewController viewController];
//        vc.delegate = self;
//        
//        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:vc action:@selector(doneWasPressed:)
//                                       ] autorelease];
//        vc.navigationItem.leftBarButtonItem = doneButton;
//        
//        UINavigationController *navController =  [[[UINavigationController alloc] initWithRootViewController: vc] autorelease];
//        navController.navigationBar.barStyle = UIBarStyleBlack;
//        //[_navigationController pushViewController: vc animated: YES];
//        [self presentModalViewController: navController
//                                animated: YES
//                          ];
//    }
//}

#pragma mark - Sharing

- (void)showActionSheet
{
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share with Friends"
									delegate: self 
         cancelButtonTitle: @"Cancel" 
    destructiveButtonTitle: nil
         otherButtonTitles: @"Social", @"Email", nil];
  //actionSheet.delegate = self;
	//actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
  //actionSheet.destructiveButtonIndex = 1;	// make the second button red (destructive)

	[actionSheet showInView: self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
}

- (void)videoPlayerShareButtonWasPressed:(VideoPlayer *)videoPlayer {
  [self showActionSheet];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		NSLog(@"Social");

	} else if (buttonIndex == 1) {
		NSLog(@"Email");

  
	} else {

		NSLog(@"cancel");
  }
}

#pragma mark - SettingsViewControllerDelegate Methods

- (void)settingsViewControllerDone:(SettingsViewController *)settingsController
{
    [self dismissModalViewControllerAnimated: YES];
}

#pragma mark - User Button Methods

- (IBAction)userViewWasPressed:(id)sender
{
    //[self showSettings];
    [self showLogoutAlert];
}

- (void)hideVideoPlayer {
    _videoPlayer.hidden = YES;
    [_videoPlayer pause];
}

- (void)videoPlayerFullscreenButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerFullscreenButtonWasPressed]");
    [self hideVideoPlayer];
}

@end

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
#import "Video.h"
#import "STVEmailController.h"
#import "ShareTableViewController.h"

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
	//actionSheet.actionSheetStyle = UIActionSheetStyleDefault;

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

    ShareTableViewController *shareController = [[[ShareTableViewController alloc] init] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController: shareController] autorelease];
    [self presentModalViewController: navController animated:YES];

  } else if (buttonIndex == 1) {
    NSLog(@"Email");

    // Create a TTMessageController
    // TODO: Manage this reference

    STVEmailController *mailController = [[STVEmailController alloc] initWithParentViewController: self];
    //UIViewController *compose = [mailController composeTo: @"Al Simmons"];

    Video *video = [videoTable getCurrentVideo];

    mailController.video = video;

    NSString *comment = nil;
    if (video.shortPermalink) {
        comment = [NSString stringWithFormat: @"Check out this great video I'm watching on Shelby.tv: %@", video.shortPermalink];
    } else {
        // should always have a permalink, but this isn't too horrible of a fallback plan...
        comment = @"Check out this great video I'm watching on Shelby.tv!";
    }

    UIViewController *compose = [mailController composeWithSubject: @"Cool video on Shelby.tv"
                                                              body: comment
                                                              ];

    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController: compose] autorelease];
    [self presentModalViewController: navController animated:YES];

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

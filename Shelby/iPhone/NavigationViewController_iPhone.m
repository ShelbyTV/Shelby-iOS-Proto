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
#import "TableShareViewController.h"
#import "ShelbyApp.h"
#import "LoginHelper.h"
#import "BroadcastApi.h"

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

#pragma mark - TableShareViewDelegate

- (void)tableShareViewClosePressed:(TableShareViewController*)shareView {
  [self dismissModalViewControllerAnimated: YES];
}

- (void)tableShareView:(TableShareViewController*)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks andRecipients:(NSString *)recipients {

   [BroadcastApi share: shareView.video
               comment: message
              networks: networks
             recipient: nil];

   [self dismissModalViewControllerAnimated: YES];

}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  // the user clicked one of the OK/Cancel buttons
  if (buttonIndex == 0)
  {
#if 1
    NSLog(@"Social");
    Video *video = [videoTable getCurrentVideo];

    TableShareViewController *tableController = [[[TableShareViewController alloc] init] autorelease];
    tableController.video = video;
    [tableController updateAuthorizations: [ShelbyApp sharedApp].loginHelper.user];
    tableController.delegate = self;

    ShareViewController *shareViewController = [[[ShareViewController alloc] init] autorelease];
   
    UIViewController *rootController =  tableController ;
    //UIViewController *rootController =  shareTableController;
    //UIViewController *rootController =  postController      ;
    //UIViewController *rootController =  fullShareController ;
    //UIViewController *rootController =  shareViewController ;
    //UIViewController *rootController =  repurposedController ;

    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController: rootController] autorelease];

    //navController.navigationBarHidden = YES;

    //navController.navigationBar.tintColor = [UIColor blackColor];
    //navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self presentModalViewController: navController animated:YES];
    
    //[self presentModalViewController: rootController animated:YES];
#else

    [[TTNavigator navigator].URLMap from:@"tt://post"
                        toViewController:self selector:@selector(post:)];
    - (UIViewController*)post:(NSDictionary*)query {
  TTPostController* controller = [[[TTPostController alloc] initWithNavigatorURL:nil
                                                                           query:
                                      [NSDictionary dictionaryWithObjectsAndKeys:@"Default Text", @"text", nil]]
                                      autorelease];
  controller.originView = [query objectForKey:@"__target__"];
  return controller;
    }
#endif

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
    //navController.navigationBar.tintColor = [UIColor blackColor];
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;

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

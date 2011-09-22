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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - 

- (void)showSettings {
    if (![_navigationController.topViewController isKindOfClass: [SettingsViewController class]]) {
        // If we're not already showing settings, show settings.
        SettingsViewController *vc = [SettingsViewController viewController];
        vc.delegate = self;
        
        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:vc action:@selector(doneWasPressed:)
                                       ] autorelease];
        vc.navigationItem.leftBarButtonItem = doneButton;
        
        UINavigationController *navController =  [[[UINavigationController alloc] initWithRootViewController: vc] autorelease];
        navController.navigationBar.barStyle = UIBarStyleBlack;
        //[_navigationController pushViewController: vc animated: YES];
        [self presentModalViewController: navController
                                animated: YES
                          ];
    }
}

#pragma mark - SettingsViewControllerDelegate Methods

- (void)settingsViewControllerDone:(SettingsViewController *)settingsController
{
    [self dismissModalViewControllerAnimated: YES];
}

#pragma mark - STVUserViewDelegate Methods

- (void)userViewWasPressed:(STVUserView *)userView
{
    //[self showSettings];
    [self showLogoutAlert];
}

#pragma mark - 

- (void)playVideo:(Video *)video
{
    LOG(@"playVideo: %@", video);
    if (video == nil) {
        return;
    }

    // Make videoPlayer visible.
    _videoPlayer.hidden = NO;

    [_videoPlayer playVideo: video];
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

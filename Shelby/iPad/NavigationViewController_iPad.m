//
//  NavigationViewController_iPad.m
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 * Eventually there will be device-specific logic in these NavigationViewController subclasses,
 * since both devices have very different navigation.
 */

#import "NavigationViewController_iPad.h"
#import "SettingsViewController.h"
#import "ShelbyApp.h"

@implementation NavigationViewController_iPad

// This is the size of the right side panel.
static const float RIGHT_PANEL_WIDTH = 330.0f;
#define OFFSET RIGHT_PANEL_WIDTH
static const float ANIMATION_TIME = 0.5f;

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Listen for swipes on the Shelby logo.
    UIPanGestureRecognizer *panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(shelbyIconWasPanned:)] autorelease];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[_logoButton addGestureRecognizer:panRecognizer];
    
    //Background.
    [header setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iPadHeaderBackground" ofType:@"png"]]]];
    [header.layer setOpaque:NO];
    header.opaque = NO;
}


#pragma mark - View Animations

- (CGRect)toggleFrame:(CGRect)frame right:(BOOL)right {
    CGRect newFrame = frame;
    float offset = right ? -OFFSET : OFFSET;
    newFrame.origin.x += offset;
    return newFrame;
}

- (void)slideView:(UIView *)view right:(BOOL)right {
    view.frame = [self toggleFrame: view.frame right:right];
}

- (void)slideTray:(BOOL)right {
    // Slide the right tray.
    [self slideView: header right: right];
    [self slideView: videoTableHolder right: right];
    [self slideView: buttonsHolder right: right];

    // Animate the video player to grow to fill the remaining space.
    // NOTE: This appears to not be working. May have to use the VideoPlayer
    // object and not the holder.
    float offset = right ? -OFFSET : OFFSET;
    CGRect tempFrame = _videoPlayer.frame;
    tempFrame.size.width += offset;
    _videoPlayer.frame = tempFrame;

    // Make header transparent while tray is closing.
    if (!right) {
       header.alpha = 0.5;
    }
}

- (void)toggleTray {
    if (!_traySliding) {
        _traySliding = YES;
        if (_trayClosed) {
            // make header opaque immediately before sliding
            header.alpha = 1.0;
        }
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            [self slideTray: _trayClosed];
        }
        completion:^(BOOL finished){
            // NOP
            _traySliding = NO;
        }];
        _trayClosed = !_trayClosed;
    }
}

//- (void)showSettings {
//    if (![_navigationController.topViewController isKindOfClass: [SettingsViewController class]]) {
//        // If we're not already showing settings, show settings.
//        SettingsViewController *vc = [SettingsViewController viewController];
//        [_navigationController pushViewController: vc animated: YES];
//    }
//}

#pragma mark - UI Callbacks

- (IBAction)shelbyIconWasPanned:(id)sender {
    UIPanGestureRecognizer *gestureRecognizer = (UIPanGestureRecognizer *) sender;

    CGPoint velocity = [gestureRecognizer velocityInView: _logoButton];

    //if(abs(velocity.x) > abs(velocity.y)) {
    if(
            // Slide right when open
            (velocity.x > 0 && !_trayClosed) ||
            // Slide left when closed
            (velocity.x < 0 && _trayClosed)
    ) {
        LOG(@"horizontal gesture");
        [self toggleTray];
    }
}

- (IBAction)shelbyIconWasPressed:(id)sender {
    // Slide the tray in and out.
    [self toggleTray];
}

//- (IBAction)settingsButtonWasPressed:(id)sender {
//    // Open up the settings ViewController
//    LOG(@"[NavigationViewController_iPad settingsButtonWasPressed]");
//    [self showSettings];
//}

#pragma mark - VideoTableViewControllerDelegate Methods

- (void)videoTableViewControllerFinishedRefresh:(VideoTableViewController *)controller {
    // If our videoplayer isn't doesn't have a video cued (isn't playing or paused), let's play a video.
    if (_videoPlayer.isIdle) {
        Video *video = [videoTable getCurrentVideo];
        [_videoPlayer performSelectorOnMainThread:@selector(playVideo:) withObject:video waitUntilDone:YES];
    }
}

#pragma mark - STVUserViewDelegate Methods

- (void)userViewWasPressed:(STVUserView *)userView {
    //[self showSettings];
    [self showLogoutAlert];
}

#pragma mark - VideoPlayerDelegate Methods

- (void)videoPlayerFullscreenButtonWasPressed:(VideoPlayer *)videoPlayer {
   LOG(@"[NavigationViewController_iPad videoPlayerFullscreenButtonWasPressed]");

   [self toggleTray];
   _fullscreen = !_fullscreen;
}

#pragma mark - UINavigationControllerDelegate Methods

// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //if (viewController == [navigationController.viewControllers objectAtIndex: 0]) {
    //    // If we're dealing with the root view controller, set the bar to hidden.
    //    [navigationController setNavigationBarHidden: YES animated: YES];
    //}
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

}

@end

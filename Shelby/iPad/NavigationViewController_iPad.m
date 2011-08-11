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

@implementation NavigationViewController_iPad
    
// This is the size of the right side panel.
static const float OFFSET = 330.0f;
static const float ANIMATION_TIME = 0.5f;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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
    [self slideView: _trimView right: right];
    [self slideView: header right: right];
    [self slideView: videoTableHolder right: right];

    // Animate the video player to grow to fill the remaining space.
    // NOTE: This appears to not be working. May have to use the VideoPlayer 
    // object and not the holder.
    float offset = right ? -OFFSET : OFFSET;
    CGRect tempFrame = _videoPlayer.frame;
    tempFrame.size.width += offset;
    _videoPlayer.frame = tempFrame;
}

#pragma mark - UI Callbacks

- (IBAction)shelbyIconWasPressed:(id)sender {
    // Slide the tray in and out.

    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        [self slideTray: _trayClosed];
    }
    completion:^(BOOL finished){
        // NOP
    }];
    _trayClosed = !_trayClosed;
}

- (IBAction)settingsButtonWasPressed:(id)sender {
	// Open up the settings ViewController
    LOG(@"[NavigationViewController_iPad settingsButtonWasPressed]");

    SettingsViewController *vc = [SettingsViewController viewController];
    [_navigationController pushViewController: vc animated: YES];
}

#pragma mark - VideoPlayerDelegate Methods

- (void)videoPlayerFullscreenButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController_iPad videoPlayerFullscreenButtonWasPressed]");

    if (_fullscreen) {
        // Exit fullscreen.
        _videoPlayer.frame = _videoPlayerOriginal;
        [self.view sendSubviewToBack: _videoPlayer];
    } else {
        // Enter fullscreen.
        _videoPlayerOriginal = _videoPlayer.frame;
        _videoPlayer.frame = self.view.bounds;
        [self.view bringSubviewToFront: _videoPlayer];
    }
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

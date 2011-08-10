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

@implementation NavigationViewController_iPad
    
static const float OFFSET = 100.0f;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

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

- (IBAction)shelbyIconWasPressed:(id)sender {
    // Slide the tray in and out.

    [UIView animateWithDuration:0.25 animations:^{
        [self slideTray: _trayClosed];
    }
    completion:^(BOOL finished){
        // NOP
    }];
    _trayClosed = !_trayClosed;
}

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

@end

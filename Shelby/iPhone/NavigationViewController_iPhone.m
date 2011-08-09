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

@implementation NavigationViewController_iPhone

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)playContentURL:(NSURL *)url
{
    LOG(@"playContentURL: %@", url);
    if (url == nil) {
        return;
    }

    // Make videoPlayer visible.
    _videoPlayer.hidden = NO;

    [_videoPlayer playContentURL: url];
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

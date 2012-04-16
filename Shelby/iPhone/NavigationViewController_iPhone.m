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
#import "ShelbyApp.h"

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
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - User Button Methods

- (void)hideVideoPlayer
{
    [_videoPlayer pause];
    
    [self zoomOutToGuideWithCompletionBlock:(^(void){[_videoPlayer stop]; [_videoPlayer reset];})];
}

- (void)videoPlayerFullscreenButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerFullscreenButtonWasPressed]");
    [self hideVideoPlayer];
}

- (void)slideSettings:(BOOL)becomingVisible
{
    CGRect temp = settingsHolder.frame;
    if (becomingVisible) {
        temp.origin.x = 0;
        temp.origin.y = 0;
    } else {
        temp.origin.x = 0;
        temp.origin.y = 480;
    }
    settingsHolder.frame = temp;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [currentGuide willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [currentGuide didRotateFromInterfaceOrientation:fromInterfaceOrientation]; 
}

@end
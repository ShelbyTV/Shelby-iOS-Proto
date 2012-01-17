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

#pragma mark - User Button Methods

- (void)hideVideoPlayer {
    _videoPlayer.hidden = YES;
    [_videoPlayer pause];
}

- (void)videoPlayerFullscreenButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerFullscreenButtonWasPressed]");
    [self hideVideoPlayer];
}

- (void)slideSettings:(BOOL)becomingVisible
{
    CGRect temp = settingsView.frame;
    if (becomingVisible) {
        temp.origin.x = 0;
        temp.origin.y = 0;
    } else {
        temp.origin.x = 0;
        temp.origin.y = 480;
    }
    settingsView.frame = temp;
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        
        NSLog(@"Layout iPhone NavCont Landscape");
        
        CGRect temp = videoTableHolder.frame;
        
        temp.origin.x = 160;
        temp.origin.y = 0;
        temp.size.width = 320;
        temp.size.height = 320;
        
        videoTableHolder.frame = temp;

        
        temp = videoTableAndButtonsHolder.frame;
        
        temp.origin.x = 0;
        temp.origin.y = 50;
        temp.size.width = 160;
        temp.size.height = 46;
        
        videoTableAndButtonsHolder.frame = temp;
        
        
        temp = header.frame;
        
        temp.origin.x = 0;
        temp.origin.y = 0;
        temp.size.width = 160;
        temp.size.height = 320;
        
        header.frame = temp;
        
    } else {
        
        NSLog(@"Layout iPhone NavCont Portrait");
        
        CGRect temp = videoTableHolder.frame;
        
        temp.origin.x = 0;
        temp.origin.y = 96;
        temp.size.width = 320;
        temp.size.height = 384;
        
        videoTableHolder.frame = temp;

        
        temp = videoTableAndButtonsHolder.frame;
        
        temp.origin.x = 0;
        temp.origin.y = 50;
        temp.size.width = 320;
        temp.size.height = 46;
        
        videoTableAndButtonsHolder.frame = temp;
        
        
        temp = header.frame;
        
        temp.origin.x = 0;
        temp.origin.y = 0;
        temp.size.width = 320;
        temp.size.height = 50;
        
        header.frame = temp;
        
    }
}

@end

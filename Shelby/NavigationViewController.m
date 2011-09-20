//
//  NavigationViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NavigationViewController.h"
#import "VideoTableViewController.h"
#import "VideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "User.h"
#import "ShelbyApp.h"
#import "STVUserView.h"
#import "NetworkManager.h"

@class Video;

@implementation NavigationViewController

@synthesize userView = _userView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        videoTable = [[VideoTableViewController alloc] initWithStyle:UITableViewStylePlain
                                                      //callbackObject:self callbackSelector:@selector(playContentURL:)];
                                                      callbackObject:self callbackSelector:@selector(playVideo:)];
        // This is a dirty hack, because for some reason, the NIB variables aren't bound immediately, so the following code doesn't work alone:
        // _videoPlayer.delegate = self;
        // So instead, we pull the view out via its tag.
        _videoPlayer = (VideoPlayer *) [self.view viewWithTag: 1];
        _videoPlayer.delegate = self;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedOut:)
                                                     name:@"NetworkManagerLoggedOut"
                                                   object:nil];

    }
    return self;
}

- (void)playVideo:(Video *)video {
    LOG(@"playVideo: %@", video);
    if (video == nil) {
        return;
    }
    [_videoPlayer playVideo: video];
}

- (void)loadUserData
{
    User *user = [ShelbyApp sharedApp].networkManager.user;
    // Draw user image & name.
    //self.userView.name.text = user.name;
    self.userView.name.text = user.nickname;
    if (user.image) {
        _userView.image.image = [UIImage imageWithData: user.image];
    } else {
        _userView.image.image = [UIImage imageNamed: @"PlaceholderFace"];
    }

    // Refresh Video list.
    [videoTable loadVideos];
}

#pragma mark - STVUserViewDelegate Methods

- (void)userViewWasPressed:(STVUserView *)userView {
    // Override in subclass.
}

#pragma mark - VideoPlayerDelegate Methods

- (void)videoPlayerPlayButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerPlayButtonWasPressed]");

}

- (void)videoPlayerFullscreenButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerFullscreenButtonWasPressed]");

}

- (void)videoPlayerNextButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerNextButtonWasPressed]");
    // Tell player to pause playing.
    [_videoPlayer pause];
    // Fetch the video next in queue.
    Video *url = [videoTable getNextVideo];
    // Tell player to start playing new video.
    [_videoPlayer playVideo: url];
}

- (void)videoPlayerPrevButtonWasPressed:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerPrevButtonWasPressed]");
    // Tell player to pause playing.
    [_videoPlayer pause];
    // Fetch the video next in queue.
    Video *url = [videoTable getPreviousVideo];
    // Tell player to start playing new video.
    [_videoPlayer playVideo: url];
}

- (void)videoPlayerVideoDidFinish:(VideoPlayer *)videoPlayer {
    LOG(@"[NavigationViewController videoPlayerVideoDidFinish]");

    // Fetch the video next in queue.
    Video *url = [videoTable getNextVideo];
    // Tell player to start playing new video.
    [_videoPlayer playVideo: url];
}


#pragma mark - Touch Handling

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    LOG(@"NavigationViewController handleSingleTap: %@", recognizer);
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];

    //Do stuff here...
}


#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    //DEBUG ONLY
    //UITapGestureRecognizer *singleFingerTap =
    //    [[UITapGestureRecognizer alloc] initWithTarget:self
    //                                            action:@selector(handleSingleTap:)];
    //[_videoPlayer.moviePlayer.view addGestureRecognizer:singleFingerTap];

    self.userView.delegate = self;

    //Background.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackgroundStripes" ofType:@"png"]]]];
    [header setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ForegroundStripes" ofType:@"png"]]]];

    //VideoTable.
    videoTable.tableView.frame = videoTableHolder.bounds;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        videoTable.tableView.rowHeight = 118;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        videoTable.tableView.rowHeight = 232;
    }
    [videoTable.tableView setBackgroundColor:[UIColor lightGrayColor]];

    [videoTable.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    _navigationController = [[UINavigationController alloc] initWithRootViewController: videoTable];
    _navigationController.view.frame = videoTableHolder.bounds;
    _navigationController.delegate = self;

    UINavigationBar *bar = _navigationController.navigationBar;
    //bar.barStyle = UIBarStyleBlackTranslucent;
    bar.barStyle = UIBarStyleBlackOpaque;

    [videoTableHolder addSubview:[_navigationController view]];
}

#pragma mark - Notification Handlers

- (void)userLoggedOut:(NSNotification*)aNotification
{
    // Stop video playback.
    [_videoPlayer stop];
    
    // Clear out the video table
    [videoTable clearVideos];
}


#pragma mark - Cleanup

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    [_videoPlayer release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

@end

//
//  NavigationViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "ConnectivityViewController.h"
#import "VideoTableViewController.h"
#import "FullscreenWebViewController.h"
#import "RemoteModeViewController.h"
#import "ShareView.h"
#import "UserAccountView.h"

@class VideoTableViewController;
@class VideoPlayer;

@interface NavigationViewController : ConnectivityViewController <VideoPlayerDelegate, VideoTableViewControllerDelegate, ShareViewDelegate, NetworkObject, FullscreenWebViewControllerDelegate, RemoteModeDelegate, UITabBarDelegate, UserAccountViewDelegate>
{
    IBOutlet UIView *header;
    IBOutlet UIView *buttonsHolder;
    IBOutlet UIView *activityHolder;
    IBOutlet UIView *videoTableHolder; // this view just tells us where in device .xib file to show the video table
    VideoTableViewController *videoTable;
    
    IBOutlet VideoPlayer *_videoPlayer; // main navigation view for iPhone, view off to the side for iPad

    IBOutlet UITabBarItem *timelineTabBarItem;
    IBOutlet UITabBarItem *favoritesTabBarItem;
    IBOutlet UITabBarItem *watchLaterTabBarItem;
    IBOutlet UITabBarItem *searchTabBarItem;
    IBOutlet UITabBar *tabBar;
    
    IBOutlet UIImageView *userImage;
    IBOutlet UILabel     *userName;
    IBOutlet UIImageView *userFacebook;
    IBOutlet UIImageView *userTwitter;
    IBOutlet UIImageView *userTumblr;
    IBOutlet UIImageView *userButton;
    
    IBOutlet UISearchBar *searchBar;
    BOOL _searchBarVisible;

    ShareView *_shareView;
    UserAccountView *_userAccountView;
    
    RemoteModeViewController *_remoteModeView;

    BOOL _settingsSliding;
    BOOL _settingsVisible;
    IBOutlet UIView *settingsHolder;

    IBOutlet UIView *videoTableAndButtonsHolder;
    
    FullscreenWebViewController *_fullscreenWebView;
    
    NSSet *_authorizations;
}

@property (nonatomic, retain) ShareView *shareView;

@property (readonly) NSInteger networkCounter;
@property (readwrite) BOOL touched;

- (IBAction)userViewWasPressed:(id)sender;
- (IBAction)listButtonPressed:(id)sender;
- (IBAction)favoritesButtonPressed:(id)sender;
- (IBAction)watchLaterButtonPressed:(id)sender;
- (void)pauseCurrentVideo;

- (void)loadUserData;

- (void)slideSettings:(BOOL)becomingVisible;
- (void)playVideo:(Video *)video;

- (BOOL)isVideoPlaying;

// FullscreenWebViewControllerDelegate
- (void)fullscreenWebViewCloseWasPressed:(id)sender;
- (void)fullscreenWebViewDidFinishLoad:(UIWebView *)webView;
- (void)fullscreenWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

- (void)zoomInToVideoPlayerWithCompletionBlock:(void (^)(void))block;
- (void)zoomOutToGuideWithCompletionBlock:(void (^)(void))block;

@end

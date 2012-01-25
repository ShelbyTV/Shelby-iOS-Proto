//
//  NavigationViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "ShareView.h"
#import "ConnectivityViewController.h"
#import "VideoTableViewController.h"
#import "FullscreenWebViewController.h"
#import "RemoteModeViewController.h"

@class VideoTableViewController;
@class VideoPlayer;

@interface NavigationViewController : ConnectivityViewController <VideoPlayerDelegate, VideoTableViewControllerDelegate, ShareViewDelegate, NetworkObject, FullscreenWebViewControllerDelegate, RemoteModeDelegate, UITabBarDelegate>
{
    IBOutlet UIView *header;
    IBOutlet UIView *buttonsHolder;
    IBOutlet UIView *activityHolder;
    IBOutlet UIView *videoTableHolder; // this view just tells us where in device .xib file to show the video table
    VideoTableViewController *videoTable;
    IBOutlet UIView *buttonsFiller;
    IBOutlet UIButton *listButton;
    IBOutlet UIButton *favoritesButton;
    IBOutlet UIButton *watchLaterButton;
    
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
    
    RemoteModeViewController *_remoteModeView;

    BOOL _settingsSliding;
    BOOL _settingsVisible;
    IBOutlet UIView *settingsView;
    IBOutlet UIButton *addFacebookButton;
    IBOutlet UIButton *addTwitterButton;
    IBOutlet UIButton *addTumblrButton;
    
    IBOutlet UIView *videoTableAndButtonsHolder;
    
    FullscreenWebViewController *_fullscreenWebView;
    
    NSSet *_authorizations;
    
    IBOutlet UIToolbar *_settingsToolbar;
    IBOutlet UIBarButtonItem *_demoModeButton;
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

- (IBAction)demoMode:(id)sender;
- (IBAction)backToVideos:(id)sender;
- (IBAction)addFacebook:(id)sender;
- (IBAction)addTwitter:(id)sender;
- (IBAction)addTumblr:(id)sender;
- (IBAction)logOut:(id)sender;
- (IBAction)termsOfUse:(id)sender;
- (IBAction)privacyPolicy:(id)sender;

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

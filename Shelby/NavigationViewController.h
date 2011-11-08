//
//  NavigationViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "ShareViewController.h"
#import "ConnectivityViewController.h"
#import "VideoTableViewController.h"

@class VideoTableViewController;
@class VideoPlayer;

@interface NavigationViewController : ConnectivityViewController <VideoPlayerDelegate, VideoTableViewControllerDelegate, ShareViewDelegate, NetworkObject, UIWebViewDelegate>
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

    IBOutlet UIImageView *userImage;
    IBOutlet UILabel     *userName;
    IBOutlet UIImageView *userFacebook;
    IBOutlet UIImageView *userTwitter;
    IBOutlet UIImageView *userTumblr;
    IBOutlet UIImageView *userButton;

    ShareViewController *_shareView;

    BOOL _settingsSliding;
    BOOL _settingsVisible;
    IBOutlet UIView *settingsView;
    IBOutlet UIButton *addFacebookButton;
    IBOutlet UIButton *addTwitterButton;
    IBOutlet UIButton *addTumblrButton;
    
    IBOutlet UIView *videoTableAndButtonsHolder;
    
    IBOutlet UIWebView *_webView;
    IBOutlet UIView *_webViewHolder;
    
    NSSet *_authorizations;
}

@property (nonatomic, retain) ShareViewController *shareView;
@property (readonly) NSInteger networkCounter;

- (IBAction)userViewWasPressed:(id)sender;
- (IBAction)listButtonPressed:(id)sender;
- (IBAction)favoritesButtonPressed:(id)sender;
- (IBAction)watchLaterButtonPressed:(id)sender;
- (void)pauseCurrentVideo;

- (void)loadUserData;

- (IBAction)backToVideos:(id)sender;
- (IBAction)addFacebook:(id)sender;
- (IBAction)addTwitter:(id)sender;
- (IBAction)addTumblr:(id)sender;
- (IBAction)logOut:(id)sender;
- (IBAction)termsOfUse:(id)sender;
- (IBAction)privacyPolicy:(id)sender;

- (IBAction)closeWebView:(id)sender;

- (void)slideSettings:(BOOL)becomingVisible;
- (void)playVideo:(Video *)video;

@end

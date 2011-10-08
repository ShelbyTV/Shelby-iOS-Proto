//
//  NavigationViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "STVShareView.h"
#import "ConnectivityViewController.h"
#import "VideoTableViewController.h"

@class VideoTableViewController;
@class VideoPlayer;

@interface NavigationViewController : ConnectivityViewController <VideoPlayerDelegate, VideoTableViewControllerDelegate, STVShareViewDelegate>
{
    IBOutlet UIView *header;
    IBOutlet UIView *buttonsHolder;
    IBOutlet UIView *activityHolder;
    IBOutlet UIView *videoTableHolder; // this view just tells us where in device .xib file to show the video table
    VideoTableViewController *videoTable;
    IBOutlet UIView *buttonsFiller;
    IBOutlet UIButton *listButton;
    IBOutlet UIButton *favoritesButton;
    IBOutlet VideoPlayer *_videoPlayer; // main navigation view for iPhone, view off to the side for iPad

    IBOutlet UIImageView *userImage;
    IBOutlet UILabel     *userName;
    IBOutlet UIImageView *userFacebook;
    IBOutlet UIImageView *userTwitter;
    IBOutlet UIImageView *userTumblr;
    IBOutlet UIImageView *userButton;

    //BOOL keyboardIsShown;
    CGRect _keyboardFrame;
    STVShareView *_shareView;

    NSSet *_authorizations;
}

@property (nonatomic, retain) STVShareView *shareView;

- (IBAction)userViewWasPressed:(id)sender;
- (IBAction)listButtonPressed:(id)sender;
- (IBAction)favoritesButtonPressed:(id)sender;

- (void)loadUserData;
- (void)showLogoutAlert;

- (void)centerShareViewAnimated:(double)animated;

@end

//
//  NavigationViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "STVUserView.h"
#import "ConnectivityViewController.h"
#import "VideoTableViewController.h"

@class VideoTableViewController;
@class VideoPlayer;
//@class STVUserView;

@interface NavigationViewController : ConnectivityViewController <VideoPlayerDelegate, UINavigationControllerDelegate, STVUserViewDelegate, VideoTableViewControllerDelegate>
{
    IBOutlet UIView *header;
    IBOutlet UIView *buttonsHolder;
    IBOutlet UIView *videoTableHolder; // this view just tells us where in device .xib file to show the video table
    VideoTableViewController *videoTable;
    IBOutlet UIView *buttonsFiller;
    IBOutlet UIButton *listButton;
    IBOutlet UIButton *favoritesButton;
    IBOutlet VideoPlayer *_videoPlayer; // main navigation view for iPhone, view off to the side for iPad
    IBOutlet STVUserView *_userView;
}

@property (nonatomic, readonly) STVUserView *userView;

- (IBAction)listButtonPressed:(id)sender;
- (IBAction)favoritesButtonPressed:(id)sender;

- (void)loadUserData;
- (void)showLogoutAlert;

@end

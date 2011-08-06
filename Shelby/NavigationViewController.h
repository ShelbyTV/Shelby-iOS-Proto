//
//  NavigationViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"

@class VideoTableViewController;
@class VideoPlayer;

@interface NavigationViewController : UIViewController <VideoPlayerDelegate>
{
    IBOutlet UIView *header;
    IBOutlet UIView *videoTableHolder; // this view just tells us where in device .xib file to show the video table
    VideoTableViewController *videoTable;
    IBOutlet UIView *videoHolder; // main navigation view for iPhone, view off to the side for iPad

    VideoPlayer *_videoPlayer;
}

- (void)playContentURL:(NSURL *)url;
- (void)loadUserData;

@end

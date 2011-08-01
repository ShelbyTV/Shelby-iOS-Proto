//
//  NavigationViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoTableViewController;

@interface NavigationViewController : UIViewController
{
    IBOutlet UIView *header;
    IBOutlet UIView *videoTableHolder; // this view just tells us where in device .xib file to show the video table
    VideoTableViewController *videoTable;
    IBOutlet UIView *videoHolder; // main navigation view for iPhone, view off to the side for iPad

}

- (void)playContentURL:(NSURL *)url;
- (void)loadUserData;

@end

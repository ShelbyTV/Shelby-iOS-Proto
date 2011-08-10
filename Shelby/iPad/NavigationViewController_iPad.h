//
//  NavigationViewController_iPad.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NavigationViewController.h"

@interface NavigationViewController_iPad : NavigationViewController
{

  // This is the little bit of "trim" in the top right between the two major
  // views.
  IBOutlet UIView *_trimView;
  BOOL _trayClosed;
  // Are we in fullscreen mode?
  BOOL _fullscreen;
  // The original (non-fullscreen) frame for the videoPlayer.
  CGRect _videoPlayerOriginal;
}

- (IBAction)shelbyIconWasPressed:(id)sender;

@end

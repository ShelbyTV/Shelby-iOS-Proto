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
  IBOutlet UIButton *_logoButton;
  BOOL _trayClosed;
  BOOL _traySliding;
  // The original (non-fullscreen) frame for the videoPlayer.
  CGRect _videoPlayerOriginal;
}

- (IBAction)shelbyIconWasPressed:(id)sender;

@end

//
//  RemoteModeViewController.h
//  Shelby
//
//  Created by Mark Johnson on 1/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RemoteModeHelpTableViewController;

@protocol RemoteModeDelegate

- (void)remoteModePreviousVideo;
- (void)remoteModeNextVideo;
- (void)remoteModeLikeVideo;
- (void)remoteModeWatchLaterVideo;
- (void)remoteModeNextChannel;
- (void)remoteModePreviousChannel;
- (void)remoteModeScanForward;
- (void)remoteModeScanBackward;
- (void)remoteModeShowInfo;
- (void)remoteModeHideInfo;
- (void)remoteModeTogglePlayPause;
- (void)remoteModeShowSharing;

@end

@interface RemoteModeViewController : UIViewController
{
    UIPinchGestureRecognizer *pinchRecognizer;

    UISwipeGestureRecognizer *leftSwipeRecognizer;
    UISwipeGestureRecognizer *rightSwipeRecognizer;
    UISwipeGestureRecognizer *upSwipeRecognizer;
    UISwipeGestureRecognizer *downSwipeRecognizer;

    UISwipeGestureRecognizer *leftDoubleSwipeRecognizer;
    UISwipeGestureRecognizer *rightDoubleSwipeRecognizer;
    UISwipeGestureRecognizer *upDoubleSwipeRecognizer;
    UISwipeGestureRecognizer *downDoubleSwipeRecognizer;

    UITapGestureRecognizer *doubleTapRecognizer;
    
    double _lastTouchesBegan;
    
    IBOutlet UIView *stripesView;
    
    IBOutlet UIImageView *needHelpImage;
    IBOutlet UIButton *helpButton;
    IBOutlet UIView *helpContainerView;
    
    IBOutlet UIImageView *tapAnywhereImage;
    
    BOOL alreadyPinching;
    BOOL alreadySpreading;
    
    RemoteModeHelpTableViewController *helpController;
}

@property (assign) id <RemoteModeDelegate> delegate;

- (IBAction)helpPressed:(id)sender;

- (void)showRemoteMode;
- (void)hideRemoteMode;

@end

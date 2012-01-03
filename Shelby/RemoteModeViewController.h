//
//  RemoteModeViewController.h
//  Shelby
//
//  Created by Mark Johnson on 1/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

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
    
    IBOutlet UIImageView *pinchWhite;
    IBOutlet UIImageView *spreadWhite;
    IBOutlet UIImageView *swipeUpWhite;
    IBOutlet UIImageView *swipeLeftWhite;
    IBOutlet UIImageView *swipeRightWhite;
    IBOutlet UIImageView *swipeDownWhite;
    IBOutlet UIImageView *doubleSwipeUpWhite;
    IBOutlet UIImageView *doubleSwipeLeftWhite;
    IBOutlet UIImageView *doubleSwipeRightWhite;
    IBOutlet UIImageView *doubleSwipeDownWhite;
    IBOutlet UIImageView *tapWhite;
    IBOutlet UIImageView *doubleTapWhite;
    
    BOOL alreadyPinching;
    BOOL alreadySpreading;
}

@property (assign) id <RemoteModeDelegate> delegate;

@end

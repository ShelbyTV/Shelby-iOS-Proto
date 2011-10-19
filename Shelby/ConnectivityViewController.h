//
//  ConnectivityViewController.h
//  Shelby
//
//  Created by David Kay on 9/19/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;
@class ShelbyApp;

@interface ConnectivityViewController : UIViewController {
    // Offline view
    UIView *_offlineView;
    UIView *_networkActivityView;
    UIView *_networkActivityViewParent;
}

// Offline detection
@property(nonatomic, retain) Reachability *internetReachable;
@property(nonatomic, retain) Reachability *hostReachable;
@property(readwrite) BOOL internetActive;
@property(readwrite) BOOL hostActive;

- (void)showShelbyDown;

@end

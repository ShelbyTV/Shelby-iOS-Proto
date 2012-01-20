//
//  ShelbyAppDelegate_iPhone.m
//  Shelby
//
//  Created by Mark Johnson on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShelbyAppDelegate_iPhone.h"
#import "LoginViewController.h"
#import "NavigationViewController_iPhone.h"
#import "ShelbyApp.h"
#import "LoginHelper.h"
#import "ShelbyWindow.h"
#import "TransitionController.h"

@implementation ShelbyAppDelegate_iPhone

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window.hidden = YES;
    [ShelbyApp sharedApp].hiddenAllRotationsWindow = self.window;

    shelbyWindow = [[ShelbyWindow alloc] init];
    
    navigationViewController = [[NavigationViewController_iPhone alloc] initWithNibName:@"Navigation_iPhone" bundle:nil];
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    shelbyWindow.frame = frame;
    navigationViewController.view.frame = frame;
    
    BOOL userAlreadyLoggedIn = [ShelbyApp sharedApp].loginHelper.loggedIn;
    
    loginViewController = [[LoginViewController alloc] initWithNibName:@"Login_iPhone"
                                                                bundle:nil
                                                        callbackObject:navigationViewController
                                                      callbackSelector:@selector(loadUserData)];
    loginViewController.view.frame = navigationViewController.view.bounds;

    [ShelbyApp sharedApp].shelbyWindow = shelbyWindow;
    [[ShelbyApp sharedApp] addNetworkObject:loginViewController];
    [[ShelbyApp sharedApp] addNetworkObject:navigationViewController];
    
    [ShelbyApp sharedApp].navigationViewController = navigationViewController;
    
    [ShelbyApp sharedApp].transitionController = [[TransitionController alloc] initWithViewController:navigationViewController];

    
    // If we're logged in, we can bypass login here and below...
    if (!userAlreadyLoggedIn) {
        [[ShelbyApp sharedApp].transitionController transitionToViewController:loginViewController withOptions:UIViewAnimationOptionTransitionNone];
    }
        
    [loginViewController viewWillAppear: NO];
    [loginViewController viewDidAppear: NO];

    [shelbyWindow addSubview: [ShelbyApp sharedApp].transitionController.view];
    shelbyWindow.rootViewController = [ShelbyApp sharedApp].transitionController;
    shelbyWindow.windowLevel = UIWindowLevelNormal;
    [shelbyWindow makeKeyAndVisible];
    shelbyWindow.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    if (userAlreadyLoggedIn) {
        [navigationViewController loadUserData];
    }
    
        
    return YES;
}

@end

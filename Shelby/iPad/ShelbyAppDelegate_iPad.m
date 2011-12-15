//
//  ShelbyAppDelegate_iPad.m
//  Shelby
//
//  Created by Mark Johnson on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShelbyAppDelegate_iPad.h"
#import "LoginViewController.h"
#import "NavigationViewController_iPad.h"
#import "ShelbyApp.h"
#import "LoginHelper.h"
#import "ShelbyWindow.h"

@implementation ShelbyAppDelegate_iPad

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    shelbyWindow = [[ShelbyWindow alloc] init];
    
    navigationViewController = [[NavigationViewController_iPad alloc] initWithNibName:@"Navigation_iPad" bundle:nil];
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    shelbyWindow.frame = frame;
    navigationViewController.view.frame = frame;
    
    BOOL userAlreadyLoggedIn = [ShelbyApp sharedApp].loginHelper.loggedIn;

    loginViewController = [[LoginViewController alloc] initWithNibName:@"Login_iPad"
                                                                bundle:nil
                                                        callbackObject:navigationViewController
                                                      callbackSelector:@selector(loadUserData)];
    loginViewController.view.frame = navigationViewController.view.bounds;
    
    // If we're logged in, we can bypass login here and below...
    if (userAlreadyLoggedIn) {
        loginViewController.view.alpha = 0.0;
        loginViewController.view.hidden = YES;
    }
    
    [[ShelbyApp sharedApp] addNetworkObject:loginViewController];
    [[ShelbyApp sharedApp] addNetworkObject:navigationViewController];
    
    [ShelbyApp sharedApp].navigationViewController = navigationViewController;
    
    [loginViewController viewWillAppear: NO];
    [navigationViewController.view addSubview:loginViewController.view];
    [loginViewController viewDidAppear: NO];
    
    [shelbyWindow addSubview: navigationViewController.view];
    shelbyWindow.rootViewController = navigationViewController;
    shelbyWindow.windowLevel = UIWindowLevelNormal;
    [shelbyWindow makeKeyAndVisible];
    shelbyWindow.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    if (userAlreadyLoggedIn) {
        [navigationViewController loadUserData];
    }
    
    self.window.hidden = YES;
    
    return YES;
}

@end

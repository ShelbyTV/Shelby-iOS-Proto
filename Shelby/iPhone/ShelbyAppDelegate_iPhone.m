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

@implementation ShelbyAppDelegate_iPhone

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    navigationViewController = [[NavigationViewController_iPhone alloc] initWithNibName:@"Navigation_iPhone" bundle:nil];
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    navigationViewController.view.frame = frame;

    BOOL userAlreadyLoggedIn = [ShelbyApp sharedApp].loginHelper.loggedIn;
    
    loginViewController = [[LoginViewController alloc] initWithNibName:@"Login_iPhone"
                                                                bundle:nil
                                                        callbackObject:navigationViewController
                                                      callbackSelector:@selector(loadUserData)];
    loginViewController.view.frame = navigationViewController.view.bounds;

    // If we're logged in, we can bypass login here and below...
    if (userAlreadyLoggedIn) {
        loginViewController.view.alpha = 0.0;
        loginViewController.view.hidden = YES;
    }
    
    [loginViewController viewWillAppear: NO];
    [navigationViewController.view addSubview:loginViewController.view];
    [loginViewController viewDidAppear: NO];

    [self.window addSubview: navigationViewController.view];
    self.window.rootViewController = navigationViewController;
    [self.window makeKeyAndVisible];
    
    if (userAlreadyLoggedIn) {
        [navigationViewController loadUserData];
    }
    
    return YES;
}

@end

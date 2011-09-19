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
#import "NetworkManager.h"

@implementation ShelbyAppDelegate_iPhone

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    navigationViewController = [[NavigationViewController_iPhone alloc] initWithNibName:@"Navigation_iPhone" bundle:nil];
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    navigationViewController.view.frame = frame;

    // If we're not logged in, let's ask the user to log in.
    loginViewController = [[LoginViewController alloc] initWithNibName:@"Login_iPad"
                                                                bundle:nil
                                                        callbackObject:navigationViewController
                                                      callbackSelector:@selector(loadUserData)];
    loginViewController.view.frame = navigationViewController.view.bounds;
    [loginViewController viewWillAppear: NO];
    [navigationViewController.view addSubview:loginViewController.view];
    [loginViewController viewDidAppear: NO];

    if ([ShelbyApp sharedApp].networkManager.loggedIn) {
        // If we're logged in, we can bypass login.
        [loginViewController allDone];
    }

    [self.window addSubview: navigationViewController.view];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [super dealloc];
}

@end

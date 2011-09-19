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

    // Windows don't work very well at passing events to multiple subviews. Use rootView to contain everything.
    //rootViewController = [[RootViewController alloc] initWithNibName:@"Root_iPhone" bundle:nil];

    navigationViewController = [[NavigationViewController_iPhone alloc] initWithNibName:@"Navigation_iPhone" bundle:nil];
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    navigationViewController.view.frame = frame;
    //navigationViewController.view.frame = rootViewController.view.bounds;
    //navigationViewController.view.frame = [[UIApplication sharedApplication] keyWindow].bounds;

    //[rootViewController.view addSubview:navigationViewController.view];

    if ([ShelbyApp sharedApp].networkManager.loggedIn) {
        // If we're logged in, we can bypass login.
        [navigationViewController loadUserData];
    } else {
        loginViewController = [[LoginViewController alloc] initWithNibName:@"Login_iPhone"
                                                                    bundle:nil
                                                            callbackObject:navigationViewController
                                                          callbackSelector:@selector(loadUserData)];

        loginViewController.view.frame = navigationViewController.view.bounds;
        [loginViewController viewWillAppear: NO];
        [navigationViewController.view addSubview:loginViewController.view];
        [loginViewController viewDidAppear: NO];
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

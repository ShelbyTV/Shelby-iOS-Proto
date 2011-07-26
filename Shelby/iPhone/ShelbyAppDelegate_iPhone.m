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
#import "RootViewController.h"

@implementation ShelbyAppDelegate_iPhone

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    rootViewController = [[RootViewController alloc] initWithNibName:@"Root_iPhone" bundle:nil];
    
    navigationViewController = [[NavigationViewController_iPhone alloc] initWithNibName:@"Navigation_iPhone" bundle:nil];
    navigationViewController.view.frame = rootViewController.view.bounds;
    [rootViewController.view addSubview:navigationViewController.view];
    
    loginViewController = [[LoginViewController alloc] initWithNibName:@"Login_iPhone" bundle:nil];
    loginViewController.view.frame = rootViewController.view.bounds;
    [rootViewController.view addSubview:loginViewController.view]; 
    
    [self.window addSubview:rootViewController.view];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
	[super dealloc];
}

@end

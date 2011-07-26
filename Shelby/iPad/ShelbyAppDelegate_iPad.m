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
#import "RootViewController.h"

@implementation ShelbyAppDelegate_iPad

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    rootViewController = [[RootViewController alloc] initWithNibName:@"Root_iPad" bundle:nil];
    
    navigationViewController = [[NavigationViewController_iPad alloc] initWithNibName:@"Navigation_iPad" bundle:nil];
    navigationViewController.view.frame = rootViewController.view.bounds;
    [rootViewController.view addSubview:navigationViewController.view];

    loginViewController = [[LoginViewController alloc] initWithNibName:@"Login_iPad" bundle:nil];
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

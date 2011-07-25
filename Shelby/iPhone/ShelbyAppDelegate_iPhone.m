//
//  ShelbyAppDelegate_iPhone.m
//  Shelby
//
//  Created by Mark Johnson on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShelbyAppDelegate_iPhone.h"
#import "LoginViewController_iPhone.h"
#import "NavigationViewController_iPhone.h"
#import "RootViewController_iPhone.h"

@implementation ShelbyAppDelegate_iPhone

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    self.rootViewController = [[RootViewController_iPhone alloc] initWithNibName:@"Root_iPhone" bundle:nil];
    
    self.navigationViewController = [[NavigationViewController_iPhone alloc] initWithNibName:@"Navigation_iPhone" bundle:nil];
    self.navigationViewController.view.frame = self.rootViewController.view.bounds;
    [self.rootViewController.view addSubview:self.navigationViewController.view];
    
    self.loginViewController = [[LoginViewController_iPhone alloc] initWithNibName:@"Login_iPhone" bundle:nil];
    self.loginViewController.view.frame = self.rootViewController.view.bounds;
    [self.rootViewController.view addSubview:self.loginViewController.view]; 
    
    [self.window addSubview:self.rootViewController.view];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
	[super dealloc];
}

@end

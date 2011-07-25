//
//  ShelbyAppDelegate_iPad.m
//  Shelby
//
//  Created by Mark Johnson on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShelbyAppDelegate_iPad.h"
#import "LoginViewController_iPad.h"
#import "NavigationViewController_iPad.h"
#import "RootViewController_iPad.h"

@implementation ShelbyAppDelegate_iPad

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.rootViewController = [[RootViewController_iPad alloc] initWithNibName:@"Root_iPad" bundle:nil];
    
    self.navigationViewController = [[NavigationViewController_iPad alloc] initWithNibName:@"Navigation_iPad" bundle:nil];
    self.navigationViewController.view.frame = self.rootViewController.view.bounds;
    [self.rootViewController.view addSubview:self.navigationViewController.view];

    self.loginViewController = [[LoginViewController_iPad alloc] initWithNibName:@"Login_iPad" bundle:nil];
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

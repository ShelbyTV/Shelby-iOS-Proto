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
#import "UserSessionHelper.h"
#import "ShelbyWindow.h"

@implementation ShelbyAppDelegate_iPhone

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window.hidden = YES;

    shelbyWindow = [[ShelbyWindow alloc] init];
    
    navigationViewController = [[NavigationViewController_iPhone alloc] initWithNibName:@"Navigation_iPhone" bundle:nil];
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    shelbyWindow.frame = frame;
    navigationViewController.view.frame = frame;
    
    BOOL userAlreadyLoggedIn = [ShelbyApp sharedApp].userSessionHelper.loggedIn;
    
    loginViewController = [[LoginViewController alloc] initWithNibName:@"Login_iPhone"
                                                                bundle:nil
                                                        callbackObject:navigationViewController
                                                      callbackSelector:@selector(loadInitialUserDataAfterLogin)];
    loginViewController.view.frame = navigationViewController.view.bounds;

    // If we're logged in, we can bypass login here and below...
    if (userAlreadyLoggedIn) {
        loginViewController.view.alpha = 0.0;
        loginViewController.view.hidden = YES;
    }
    
    [ShelbyApp sharedApp].shelbyWindow = shelbyWindow;
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
        [navigationViewController loadInitialUserDataAlreadyLoggedIn];
    }
        
    
    [self initializeThirdPartyLibraries];
    
    return YES;
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

#pragma mark - Third Party Libraries
- (void)initializeThirdPartyLibraries
{
    [Appirater appLaunched:YES]; 
    [Crashlytics startWithAPIKey:@"84a79b7ee6f2eca13877cd17b9b9a290790f99aa"];
}

@end

//
//  LoginViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginHelper.h"
#import "ShelbyApp.h"
#import "Reachability.h"
#import "GraphiteStats.h"

@implementation LoginViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       callbackObject:(id)object
     callbackSelector:(SEL)selector
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        callbackObject = object;
        callbackSelector = selector;

        _loginHelper = [ShelbyApp sharedApp].loginHelper;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedIn:)
                                                     name:@"UserLoggedIn"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedOut:)
                                                     name:@"UserLoggedOut"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(showShelbyDown) 
                                                     name:@"OAuthHandshakeFailed" 
                                                   object:nil];
        
        // Network Activity
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkActiveNotification:)
                                                     name:@"ShelbyAppNetworkActive"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkInactiveNotification:)
                                                     name:@"ShelbyAppNetworkInactive"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /*
     * Even though normally I don't like programmatically checking for iPad vs. iPhone, an iPad
     * or iPhone-specific subclass would only have this one method. Doesn't seem worth it.
     *
     * This may not be necessary -- just having this on the RootView might be enough?
     */

    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait &&
            UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ||
           (interfaceOrientation == UIInterfaceOrientationLandscapeRight &&
            UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _networkActivityViewParent = activityHolder;
    
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackgroundStripes" ofType:@"png"]]]];

    //[self showNetworkActivityIndicator];
}

- (void) viewWillAppear:(BOOL)animated
{
    LOG(@"viewWillAppear");
    [super viewWillAppear: animated];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG(@"viewDidAppear");
}

- (void)viewDidDisappear:(BOOL)animated {
    LOG(@"viewDidDisappear");
}

- (void) viewWillDisappear:(BOOL)animated
{
    LOG(@"viewWillDisappear");
    [super viewWillDisappear: animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

#pragma mark - Misc Methods

- (void)fade:(BOOL)visible {
    float alpha;
    BOOL hidden;
    if (visible) {
        alpha = 1.0f;
        hidden = NO;
    } else {
        alpha = 0.0f;
        hidden = YES;
    }
    // Note: this won't work on iOS3.
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = alpha;
    }
    completion:^(BOOL finished){
       if (finished) {
           [self.view setHidden: hidden];
       }
    }];
}

- (void)fadeIn
{
    [self fade: YES];
}

- (void)fadeOut
{
    [self fade: NO];
}

/**
 * Once we've completed logging in, this removes the view.
 */
- (void)allDone
{
    [callbackObject performSelector:callbackSelector];
    [self fadeOut];
}

- (void)beginLoginWithProvider:(NSString *)provider
{
    [_loginHelper getRequestTokenWithProvider:provider];
}

#pragma mark - Notification Handlers

- (void)userLoggedIn:(NSNotification*)aNotification
{    
    [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"userLoggedIn"];

    [self allDone];
}

- (void)userLoggedOut:(NSNotification*)aNotification
{
    // Show the screen again.
    [self fadeIn];
}

#pragma mark - View Callbacks

- (IBAction)loginWithFacebook:(id)sender
{
    [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"userLoginViaFacebookAttempt"];

    //[self allDone];
    [self beginLoginWithProvider: @"facebook"];

    //    LOG(@"loginWithFace   book! username:%@ password:%@", [username text], [password text]);
}

- (IBAction)loginWithTwitter:(id)sender
{
    [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"userLoginViaTwitterAttempt"];

    //[self allDone];
    //[self beginLogin];
    [self beginLoginWithProvider: @"twitter"];

    //    LOG(@"loginWithTwitter! username:%@ password:%@", [username text], [password text]);
}

@end

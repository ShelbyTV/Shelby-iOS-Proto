
//
//  LoginViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkManager.h"
#import "ShelbyApp.h"
#import "Reachability.h"
#import "STVOfflineView.h"


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

        _networkManager = [ShelbyApp sharedApp].networkManager;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedIn:)
                                                     name:@"NetworkManagerLoggedIn"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedOut:)
                                                     name:@"NetworkManagerLoggedOut"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(showShelbyDown) 
                                                     name:@"LoginHelperOAuthHandshakeFailed" 
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

- (void)beginLogin
{
#ifdef OFFLINE_MODE
    [self allDone];
#else
    [_networkManager beginOAuthHandshake];
#endif
}

#pragma mark - Notification Handlers

- (void)userLoggedIn:(NSNotification*)aNotification
{
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
    //[self allDone];
    [self beginLogin];

    //    LOG(@"loginWithFacebook! username:%@ password:%@", [username text], [password text]);
}

- (IBAction)loginWithTwitter:(id)sender
{
    //[self allDone];
    [self beginLogin];

    //    LOG(@"loginWithTwitter! username:%@ password:%@", [username text], [password text]);
}

@end

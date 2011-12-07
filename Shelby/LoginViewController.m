
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
#import "ShelbyAppDelegate.h"

@interface LoginViewController ()
@property (readwrite) NSInteger networkCounter;
@end

@implementation LoginViewController

@synthesize networkCounter;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginURLAvailable:)
                                                     name:@"LoginURLAvailable"
                                                   object:nil];
        
        _fullscreenWebView = [FullscreenWebView fullscreenWebViewFromNib];
        _fullscreenWebView.hidden = YES;
        [_fullscreenWebView setDelegate:self];
        [self.view addSubview:_fullscreenWebView];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _networkActivityViewParent = activityHolder;
    
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackgroundStripes" ofType:@"png"]]]];
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
           _fullscreenWebView.hidden = YES;
       }
    }];
}

- (void)clearAllCookies
{
    NSHTTPCookie *cookie;
	for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		//NSLog(@"%@", [cookie description]);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
	}
}

- (void)beginLoginWithProvider:(NSString *)provider
{
    [self clearAllCookies];
    [_loginHelper getRequestTokenWithProvider:provider];
}

#pragma mark - Notification Handlers

- (void)userLoggedIn:(NSNotification*)aNotification
{    
    [GraphiteStats incrementCounter:@"userLoggedIn"];
    [callbackObject performSelector:callbackSelector];
    [self fade:NO];
}

- (void)userLoggedOut:(NSNotification*)aNotification
{
    [self clearAllCookies];
    [self fade:YES];
}

- (void)didReceiveMemoryWarning
{
    // do nothing, since we can't handle disappearing / reloading from NIB very well...
}

- (void)loginURLAvailable:(NSNotification*)aNotification
{   
    NSLog(@"loginURL: %@", [aNotification.userInfo objectForKey:@"url"]);
    [_fullscreenWebView.webView loadRequest:[NSURLRequest requestWithURL:[aNotification.userInfo objectForKey:@"url"]
                                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                         timeoutInterval:60.0]];
    self.networkCounter = 1;
}

#pragma mark - View Callbacks

- (IBAction)loginWithFacebook:(id)sender
{
    [GraphiteStats incrementCounter:@"userLoginViaFacebookAttempt"];
    [self beginLoginWithProvider: @"facebook"];
}

- (IBAction)loginWithTwitter:(id)sender
{
    [GraphiteStats incrementCounter:@"userLoginViaTwitterAttempt"];
    [self beginLoginWithProvider: @"twitter"];
}

// FullscreenWebViewDelegate
- (void)fullscreenWebViewCloseWasPressed:(id)sender
{
    _fullscreenWebView.hidden = YES;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] raiseShelbyWindow];
}

- (void)fullscreenWebViewDidFinishLoad:(UIWebView *)webView;
{
    _fullscreenWebView.hidden = NO;
    self.networkCounter = 0;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] lowerShelbyWindow];
}

- (void)fullscreenWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _fullscreenWebView.hidden = YES;
    self.networkCounter = 0;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] raiseShelbyWindow];
}

@end

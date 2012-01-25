
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
#import "UINavigationController+Transitions.h"
#import "TransitionController.h"
#import "NavigationViewController.h"

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
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _fullscreenWebView = [[[FullscreenWebViewController alloc] initWithNibName:@"FullscreenWebViewController_iPad" bundle:[NSBundle mainBundle]] retain];
        } else {
            _fullscreenWebView = [[[FullscreenWebViewController alloc] initWithNibName:@"FullscreenWebViewController_iPhone" bundle:[NSBundle mainBundle]] retain];
        }
        [_fullscreenWebView loadView];
        [_fullscreenWebView setDelegate:self];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _fullscreenWebView.view.hidden = TRUE;
            [self.view addSubview:_fullscreenWebView.view];
            
            self.view.hidden = TRUE;
        }

        NSAssert(NOT_NULL(_fullscreenWebView.webView), @"_fullscreenWebView.webView is NULL!");
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _networkActivityViewParent = activityHolder;
    
    // Do any additional setup after loading the view from its nib.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [stripesView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LoginBackgroundStripes_iPad"]]];
    } else {
        [stripesView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LoginBackgroundStripes_iPhone"]]];
    }
    [stripesView setOpaque:NO];
    [[stripesView layer] setOpaque:NO]; // hack needed for transparent backgrounds on iOS < 5
}

#pragma mark - Misc Methods

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
    [twitterButton setEnabled:NO];
    [facebookButton setEnabled:NO];
    
    [self clearAllCookies];
    [_loginHelper getRequestTokenWithProvider:provider];
}

#pragma mark - Notification Handlers

- (void)userLoggedIn:(NSNotification*)aNotification
{    
    NSLog(@"userLoggedIn");
    [GraphiteStats incrementCounter:@"signin" withAction:@"signin"];
    [callbackObject performSelector:callbackSelector];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.view.hidden = TRUE;
    } else {
        [[ShelbyApp sharedApp].transitionController transitionImmediatelyToViewController:[ShelbyApp sharedApp].navigationViewController
                                                                 withEndOfCompletionBlock:^(void){}];
    }
}

- (void)userLoggedOut:(NSNotification*)aNotification
{
    [self clearAllCookies];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.view.hidden = FALSE;
    } else {
        [[ShelbyApp sharedApp].transitionController transitionImmediatelyToViewController:self
                                                                 withEndOfCompletionBlock:^(void){}];
    }
}

- (void)didReceiveMemoryWarning
{
    // do nothing, since we can't handle disappearing / reloading from NIB very well...
}

- (void)loginURLAvailable:(NSNotification*)aNotification
{   
    NSLog(@"loginURL: %@", [aNotification.userInfo objectForKey:@"url"]);

    NSAssert(NOT_NULL(_fullscreenWebView.webView), @"_fullscreenWebView.webView is NULL!");
    
    [_fullscreenWebView.webView loadRequest:[NSURLRequest requestWithURL:[aNotification.userInfo objectForKey:@"url"]
                                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                         timeoutInterval:60.0]];
    self.networkCounter = 1;
}

#pragma mark - View Callbacks

- (IBAction)loginWithFacebook:(id)sender
{
    [GraphiteStats incrementCounter:@"signin_click.facebook" withAction:@"signin_click_facebook"];
    [self beginLoginWithProvider: @"facebook"];
}

- (IBAction)loginWithTwitter:(id)sender
{
    [GraphiteStats incrementCounter:@"signin_click.twitter" withAction:@"signin_click_twitter"];
    [self beginLoginWithProvider: @"twitter"];
}

// FullscreenWebViewControllerDelegate
- (void)fullscreenWebViewCloseWasPressed:(id)sender
{
    NSLog(@"fullscreenWebViewCloseWasPressed");
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] raiseShelbyWindow];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _fullscreenWebView.view.hidden = TRUE;
    } else {
        [[ShelbyApp sharedApp].transitionController transitionImmediatelyToViewController:self
                                                                 withEndOfCompletionBlock:^(void){}];
    }
}

- (void)fullscreenWebViewDidFinishLoad:(UIWebView *)webView;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _fullscreenWebView.view.hidden = FALSE;
    } else {
        [[ShelbyApp sharedApp].transitionController transitionImmediatelyToViewController:_fullscreenWebView
                                                                 withEndOfCompletionBlock:^(void){}];
    }
    self.networkCounter = 0;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] lowerShelbyWindow];
    
    [twitterButton setEnabled:YES];
    [facebookButton setEnabled:YES];
}

- (void)fullscreenWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _fullscreenWebView.view.hidden = TRUE;
    } else {
        [[ShelbyApp sharedApp].transitionController transitionImmediatelyToViewController:self
                                                                 withEndOfCompletionBlock:^(void){}];
    }
    self.networkCounter = 0;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] raiseShelbyWindow];
    
    [twitterButton setEnabled:YES];
    [facebookButton setEnabled:YES];
}

- (IBAction)infoTabPressed:(id)sender
{   
    float amountToMove;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        amountToMove = 102;
    } else {
        amountToMove = 56;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            footerText.alpha = infoViewExpanded ? 1.0 : 0.0;
        }
        
        CGRect temp = infoView.frame;
        temp.origin.y += infoViewExpanded ? amountToMove : -1 * amountToMove;
        infoView.frame = temp;
    }
    completion:^(BOOL finished){
        if (finished) {
            infoViewExpanded = !infoViewExpanded;
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end


//
//  LoginViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "UserSessionHelper.h"
#import "ShelbyApp.h"
#import "Reachability.h"
#import "GraphiteStats.h"
#import "ShelbyAppDelegate.h"
#import "NavigationViewController.h"
#import "DataApi.h"
#import "KitchenSinkUtilities.h"

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

        _fullscreenWebView.view.hidden = TRUE;
        [self.view addSubview:_fullscreenWebView.view];

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
                             _fullscreenWebView.view.hidden = YES;
                         }
                     }];
}



- (void)beginLoginWithProvider:(NSString *)provider
{
    [twitterButton setEnabled:NO];
    [facebookButton setEnabled:NO];
    
    [KitchenSinkUtilities clearAllCookies];
    [[ShelbyApp sharedApp].userSessionHelper beginLoginWithProvider:provider];
}

#pragma mark - Notification Handlers

- (void)userLoggedIn:(NSNotification*)aNotification
{    
    NSLog(@"userLoggedIn");
    [GraphiteStats incrementCounter:@"signin" withAction:@"signin"];
    [callbackObject performSelector:callbackSelector];
    [self fade:NO];
}

- (void)userLoggedOut:(NSNotification*)aNotification
{
    [KitchenSinkUtilities clearAllCookies];
    [self fade:YES];
}

- (void)didReceiveMemoryWarning
{
    // do nothing, since we can't handle disappearing / reloading from NIB very well...
}

- (void)loginURLAvailable:(NSNotification*)aNotification
{   
    NSLog(@"loginURL: %@", [aNotification.userInfo objectForKey:@"url"]);

    NSAssert(NOT_NULL(_fullscreenWebView.webView), @"_fullscreenWebView.webView is NULL!");
    
    [_fullscreenWebView loadRequest:[NSURLRequest requestWithURL:[aNotification.userInfo objectForKey:@"url"]
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
    _fullscreenWebView.view.hidden = TRUE;
}

- (void)fullscreenWebViewDidFinishLoad:(UIWebView *)webView;
{
    _fullscreenWebView.view.hidden = FALSE;

    self.networkCounter = 0;
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] lowerShelbyWindow];
    
    [twitterButton setEnabled:YES];
    [facebookButton setEnabled:YES];
}

- (void)fullscreenWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _fullscreenWebView.view.hidden = TRUE;

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

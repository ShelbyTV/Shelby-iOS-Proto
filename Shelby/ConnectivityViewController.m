//
//  ConnectivityViewController.m
//  Shelby
//
//  Created by David Kay on 9/19/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "ConnectivityViewController.h"
#import "Reachability.h"
#import "OfflineView.h"
#import "ShelbyApp.h"

@implementation ConnectivityViewController

@synthesize internetReachable;
@synthesize hostReachable;
@synthesize internetActive;
@synthesize hostActive;

#pragma mark - Network Activity

- (UIView *)networkActivityView
{
    if (!_networkActivityView) {
        
        UIActivityIndicatorViewStyle desiredStyle = UIActivityIndicatorViewStyleWhite;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            desiredStyle = UIActivityIndicatorViewStyleWhite;
        }
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: desiredStyle];
        activityIndicator.hidesWhenStopped = NO;
        [activityIndicator startAnimating];
        _networkActivityView = activityIndicator;

        _networkActivityView.hidden = YES;
        [_networkActivityViewParent addSubview:_networkActivityView];
    }
    
    return _networkActivityView;
}

- (void)showNetworkActivityIndicator
{
    UIView *networkView = [self networkActivityView];
    [_networkActivityViewParent bringSubviewToFront: networkView];
    networkView.hidden = NO;
}

- (void)hideNetworkActivityIndicator {
    [self networkActivityView].hidden = YES;
}

- (void)networkActiveNotification:(NSNotification*)notification {
    //NSLog(@"networkActiveNotification");
    [self performSelectorOnMainThread:@selector(showNetworkActivityIndicator) withObject:nil waitUntilDone:NO];
}

- (void)networkInactiveNotification:(NSNotification*)notification {
    //NSLog(@"networkInactiveNotification");
    [self performSelectorOnMainThread:@selector(hideNetworkActivityIndicator) withObject:nil waitUntilDone:NO];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == [ShelbyApp sharedApp] && [keyPath isEqualToString:@"isNetworkBusy"]) {
        if ([ShelbyApp sharedApp].isNetworkBusy) {
            LOG(@"network is busy");
            [self showNetworkActivityIndicator];
        } else {
            LOG(@"network is done");
            [self hideNetworkActivityIndicator];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}

#pragma mark - Offline Detection

- (UIView *)offlineView {
    if (!_offlineView) {
        _offlineView = [[OfflineView viewFromNib] retain];
    }
    return _offlineView;
}

- (void)showInternetUp
{
    [[self offlineView] removeFromSuperview];
}

- (void)showInternetDown
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
    UIView *offlineView = [self offlineView];

    // Center the view.
    CGRect frame = offlineView.frame;
    frame.origin.x = (self.view.bounds.size.width / 2) - (offlineView.bounds.size.width / 2);
    frame.origin.y = (self.view.bounds.size.height / 2) - (offlineView.bounds.size.height / 2);
    offlineView.frame = frame;

    offlineView.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleBottomMargin;

    [self.view addSubview: offlineView];
}

- (void)showShelbyDown
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Doh!" message:@"Apparently there are just too many bits for our compy's right now. Take a walk and try again later?"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

#pragma mark - Notification Handlers

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable:
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            [self showInternetDown];
            break;
        case ReachableViaWiFi:
            //NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            [self showInternetUp];
            break;
        case ReachableViaWWAN:
            //NSLog(@"The internet is working via WWAN.");
            [self showInternetUp];
            self.internetActive = YES;
            break;
    }

    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus) {
        case NotReachable:
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            if (self.internetActive) {
                // Seeing this message a lot... Need to figure out if it's legit or not.
                // [self showShelbyDown];
            }
            break;
        case ReachableViaWiFi:
            //NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            break;
        case ReachableViaWWAN:
            //NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            break;
    }
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];

    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];

    // check if a pathway to a random host exists
    hostReachable = [[Reachability reachabilityWithHostName: @"api.shelby.tv"] retain];
    [hostReachable startNotifier];
}

- (void) viewWillDisappear:(BOOL)animated
{
    LOG(@"viewWillDisappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [super viewWillDisappear: animated];
}

@end

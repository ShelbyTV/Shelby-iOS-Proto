//
//  ConnectivityViewController.m
//  Shelby
//
//  Created by David Kay on 9/19/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "ConnectivityViewController.h"
#import "Reachability.h"
#import "STVOfflineView.h"
#import "ShelbyApp.h"

@implementation ConnectivityViewController

@synthesize internetReachable;
@synthesize hostReachable;
@synthesize internetActive;
@synthesize hostActive;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _shelbyApp = [ShelbyApp sharedApp];
        //[_shelbyApp addObserver:self forKeyPath:@"isNetworkBusy" options:0 context:NULL];
        //[_shelbyApp addObserver:self forKeyPath:@"networkCounter" options:0 context:NULL];

        //[[NSNotificationCenter defaultCenter] addObserver:self
        //                                         selector:@selector(networkActiveNotification:)
        //                                             name:@"ShelbyAppNetworkActive"
        //                                           object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self
        //                                         selector:@selector(networkInactiveNotification:)
        //                                             name:@"ShelbyAppNetworkInactive"
        //                                           object:nil];
        //[[NSNotificationCenter defaultCenter] postNotificationName: @"ShelbyAppNetworkActive"
        //[[NSNotificationCenter defaultCenter] postNotificationName: @"ShelbyAppNetworkInactive"
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Network Activity

/*
 * This is a bit of a hack to allow us to reuse this code to create the network activity indicator
 * somewhere other than the center of our current view.
 *
 * We should probably do something more generic and establish some rules about when this variable
 * needs to be set, but this seems to work for now, as long as the _networkActivityViewParent variable
 * is set in viewDidLoad.
 */
- (UIView *)networkActivityViewContainer {
    if (NOT_NULL(_networkActivityViewParent)) {
        return _networkActivityViewParent;
    } else {
        return [self view];
    }
}

- (UIView *)networkActivityView {
    if (!_networkActivityView) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.hidesWhenStopped = NO;
        [activityIndicator startAnimating];
        _networkActivityView = activityIndicator;

        //_networkActivityView = [[UIView alloc] init];
        //_networkActivityView.backgroundColor = [UIColor redColor];

        _networkActivityView.hidden = YES;
        [[self networkActivityViewContainer] addSubview: _networkActivityView];
    }
    return _networkActivityView;
}

- (void)showNetworkActivityIndicator {
    UIView *networkView = [self networkActivityView];
    // If the network indicator is not already visible
    if (networkView.hidden == YES) {

        const float activitySize = 24;
        CGRect frame = networkView.frame;
        frame.size = CGSizeMake(activitySize, activitySize);
        networkView.frame = frame;
        frame.origin.x = ([self networkActivityViewContainer].bounds.size.width / 2) - (networkView.bounds.size.width / 2);
        frame.origin.y = ([self networkActivityViewContainer].bounds.size.height / 2) - (networkView.bounds.size.height / 2);

        networkView.frame = frame;
        //networkView.frame = CGRectMake(0, 0, 100, 100);

        //networkView.autoresizingMask =
        //    UIViewAutoresizingFlexibleLeftMargin
        //    | UIViewAutoresizingFlexibleRightMargin
        //    | UIViewAutoresizingFlexibleTopMargin
        //    | UIViewAutoresizingFlexibleBottomMargin;

        [[self networkActivityViewContainer] bringSubviewToFront: networkView];
        networkView.hidden = NO;
    }
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
#if 1
    if (object == _shelbyApp && [keyPath isEqualToString:@"isNetworkBusy"]) {
        if (_shelbyApp.isNetworkBusy) {
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
#else
        //NSLog(@"observeKeyValueForPath");
    if (object == _shelbyApp && [keyPath isEqualToString:@"networkCounter"]) {
        if (_shelbyApp.networkCounter > 0) {
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
#endif
}

#pragma mark - Offline Detection

- (UIView *)offlineView {
    if (!_offlineView) {
        _offlineView = [[STVOfflineView viewFromNib] retain];
    }
    return _offlineView;
}

- (void)showInternetUp
{
    [[self offlineView] removeFromSuperview];
}

- (void)showInternetDown
{
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

- (void)showShelbyUp
{

    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shelby Working!" message:@"Shelby is rocking it."
    //                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];
    //[alert release];
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
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            [self showInternetUp];
            break;
        case ReachableViaWWAN:
            NSLog(@"The internet is working via WWAN.");
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
            NSLog(@"A gateway to the host server is working via WIFI.");
            [self showShelbyUp];
            self.hostActive = YES;
            break;
        case ReachableViaWWAN:
            NSLog(@"A gateway to the host server is working via WWAN.");
            [self showShelbyUp];
            self.hostActive = YES;
            break;
    }
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    LOG(@"viewWillAppear");
    [super viewWillAppear: animated];
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];

    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];

    // check if a pathway to a random host exists
    hostReachable = [[Reachability reachabilityWithHostName: @"api.shelby.tv"] retain];
    [hostReachable startNotifier];

    // now patiently wait for the notification
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [super viewWillDisappear: animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

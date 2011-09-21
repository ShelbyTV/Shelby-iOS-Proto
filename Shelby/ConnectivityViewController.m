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
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
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
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Working!" message:@"Your Internet connection is awesome."
    //                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];
    //[alert release];

    //[self.view removeSubview: [self offlineView]];

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
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Shelby seems to be down! Try again soon."
    //                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];
    //[alert release];
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
                [self showShelbyDown];
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

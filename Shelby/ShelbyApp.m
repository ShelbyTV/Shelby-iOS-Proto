//
//  ShelbyApp.m
//  Shelby
//
//  Created by David Kay on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShelbyApp.h"
#import "LoginHelper.h"
#import "ApiHelper.h"
#import "ShelbyAppDelegate.h"
#import "VideoGetter.h"
#import "SessionStats.h"
#import "BSWebViewUserAgent.h"

#import "TestFlight.h"
#import <Crashlytics/Crashlytics.h>

@implementation ShelbyApp

@synthesize persistentStoreCoordinator;
@synthesize loginHelper;
@synthesize apiHelper;
@synthesize navigationViewController;
@synthesize demoModeEnabled = _demoModeEnabled;
@synthesize safariUserAgent;

#pragma mark - Singleton

static ShelbyApp *gShelbyApp;
static UIWindow *gSecondScreenWindow;

+ (ShelbyApp *)sharedApp
{
    if (IS_NULL(gShelbyApp)) {
        
        gShelbyApp = [[ShelbyApp alloc] init];
        
        BSWebViewUserAgent *agent = [[BSWebViewUserAgent alloc] init];
        gShelbyApp.safariUserAgent = [agent userAgentString];
        NSLog(@"Safari user agent string: %@", gShelbyApp.safariUserAgent);
        [agent release];
        
        [SessionStats startSessionReportingTimer];
    }
    
    return gShelbyApp;
}

+ (UIWindow *)secondScreenWindow
{
    if (IS_NULL(gSecondScreenWindow)) {
        gSecondScreenWindow = [[UIWindow alloc] init];
    }
    
    return gSecondScreenWindow;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        //uncomment this for TestFlight builds to get crash, session reporting
        //[TestFlight takeOff:@"9ea2465d15ab5a7cff8f30e985670aa2_MzExNDQyMDExLTA5LTMwIDAwOjMzOjA2LjYzNzY0OA"];
        [Crashlytics startWithAPIKey:@"84a79b7ee6f2eca13877cd17b9b9a290790f99aa"];

        _networkObjects = [[NSMutableSet alloc] initWithCapacity: 20];
        
        ShelbyAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        context = appDelegate.managedObjectContext; // just for loginHelper and app open/close
        
        persistentStoreCoordinator = appDelegate.persistentStoreCoordinator; // used to create other contexts for other threads / subsystems
        
        self.loginHelper = [[[LoginHelper alloc] initWithContext:context] autorelease];
        self.apiHelper = [[[ApiHelper alloc] init] autorelease];
        [self.apiHelper loadTokens];
        [self addNetworkObject:self.loginHelper];
        [self addNetworkObject:self.apiHelper];
        [self addNetworkObject:[VideoGetter singleton]];
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"demoModeEnabled"]) {
            _demoModeEnabled = FALSE;
        } else {
            _demoModeEnabled = TRUE;
        }
    }

    return self;
}

#pragma mark - Network Activity

- (BOOL)isNetworkBusy {
    BOOL toReturn = NO;
    for (id <NetworkObject> networkObject in _networkObjects) 
    {
        //NSLog(@"networkObject: %@ networkCounter: %d", [[networkObject class] description], networkObject.networkCounter);
        if (networkObject.networkCounter > 0) {
            toReturn = YES; // should really just return here, but it's nice for debugging to have the above log print out for everything
        }
    }        
    
    return toReturn;
}

- (void)postNetworkActivityNotification {
    if ([self isNetworkBusy]) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"ShelbyAppNetworkActive"
                                                            object: self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"ShelbyAppNetworkInactive"
                                                            object: self];
    }
}

- (void)addNetworkObject:(NSObject <NetworkObject> *)networkObject {
    [networkObject addObserver: self
                    forKeyPath: @"networkCounter"
                       options: 0
                       context: NULL];
    [_networkObjects addObject: networkObject];
}

- (void)removeNetworkObject:(NSObject <NetworkObject> *)networkObject {
    [networkObject removeObserver: self
                       forKeyPath: @"networkCounter"];
    [_networkObjects removeObject: networkObject];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)keyPathContext
{
    //NSLog(@"observeKeyValueForPath");
    if ([_networkObjects containsObject: object] && [keyPath isEqualToString:@"networkCounter"]) {
        [self postNetworkActivityNotification];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:keyPathContext];
    }
}

#pragma mark - Demo Mode

- (void)setDemoModeEnabled:(BOOL)demoModeEnabled
{
    _demoModeEnabled = demoModeEnabled;
    
    [[NSUserDefaults standardUserDefaults] setBool:demoModeEnabled forKey:@"demoModeEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

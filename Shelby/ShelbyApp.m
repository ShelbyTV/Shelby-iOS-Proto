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
#import "GraphiteStats.h"
#import "ShelbyAppDelegate.h"

@implementation ShelbyApp

@synthesize context;
@synthesize loginHelper;
@synthesize apiHelper;
@synthesize graphiteStats;

#pragma mark - Singleton

static ShelbyApp *gShelbyApp;

+ (ShelbyApp *)sharedApp {
  if (!gShelbyApp) {
    gShelbyApp = [[ShelbyApp alloc] init];
  }
  return gShelbyApp;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        _networkObjects = [[NSMutableSet alloc] initWithCapacity: 20];
        
        ShelbyAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        context = appDelegate.managedObjectContext;
        
        self.loginHelper = [[[LoginHelper alloc] initWithContext:context] autorelease];
        self.apiHelper = [[[ApiHelper alloc] init] autorelease];
        self.graphiteStats = [[[GraphiteStats alloc] init] autorelease];
        [self.apiHelper loadTokens];
        [self addNetworkObject: self.loginHelper];
        [self addNetworkObject: self.apiHelper];
    }

    return self;
}

#pragma mark - Network Activity

- (BOOL)isNetworkBusy {
    for (id <STVNetworkObject> networkObject in _networkObjects) {
        if (networkObject.networkCounter > 0) {
            return YES; 
        }
    }
    return NO;
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

- (void)addNetworkObject:(NSObject <STVNetworkObject> *)networkObject {
    [networkObject addObserver: self
                    forKeyPath: @"networkCounter"
                       options: 0
                       context: NULL];
    [_networkObjects addObject: networkObject];
}

- (void)removeNetworkObject:(NSObject <STVNetworkObject> *)networkObject {
    [networkObject removeObserver: self
                       forKeyPath: @"networkCounter"];
    [_networkObjects removeObject: networkObject];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)aContext
{
    //NSLog(@"observeKeyValueForPath");
    if ([_networkObjects containsObject: object] && [keyPath isEqualToString:@"networkCounter"]) {
        [self postNetworkActivityNotification];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:aContext];
    }
}

@end

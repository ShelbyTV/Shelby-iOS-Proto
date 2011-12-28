//
//  ShelbyApp.h
//  Shelby
//
//  Created by David Kay on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkObject.h"

@class LoginHelper;
@class ApiHelper;
@class NavigationViewController;

/*
 * Global singleton for maintaining state.
 */
@interface ShelbyApp : NSObject {
    NSInteger _networkCounter;
    NSMutableSet *_networkObjects;
    NSManagedObjectContext *context; // context for LoginHelper
}

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) LoginHelper *loginHelper;
@property (nonatomic, retain) ApiHelper *apiHelper;
@property (nonatomic, retain) NavigationViewController *navigationViewController;
@property (nonatomic) BOOL demoModeEnabled;
@property (nonatomic, retain) NSString *safariUserAgent;

@property (nonatomic, readonly) BOOL isNetworkBusy;

+ (ShelbyApp *)sharedApp;
+ (UIWindow *)secondScreenWindow;

- (void)addNetworkObject:(id <NetworkObject>)networkObject;
- (void)removeNetworkObject:(id <NetworkObject>)networkObject;

@end

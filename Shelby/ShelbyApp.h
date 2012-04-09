//
//  ShelbyApp.h
//  Shelby
//
//  Created by David Kay on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkObject.h"

@class UserSessionHelper;
@class ApiHelper;
@class NavigationViewController;
@class VideoData;
@class DataApi;

/*
 * Global singleton for maintaining state.
 */
@interface ShelbyApp : NSObject {
    NSInteger _networkCounter;
    NSMutableSet *_networkObjects;
    NSManagedObjectContext *context; // context for userSessionHelper
    
    BOOL _demoModeEnabled;
}

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UserSessionHelper            *userSessionHelper;
@property (strong, nonatomic) ApiHelper                    *apiHelper;
@property (strong, nonatomic) VideoData                    *videoData;
@property (strong, nonatomic) NavigationViewController     *navigationViewController;
@property (nonatomic, copy) NSString                     *safariUserAgent;
@property (strong, nonatomic) UIWindow                     *shelbyWindow;

@property (nonatomic) BOOL demoModeEnabled;
@property (nonatomic, readonly) BOOL isNetworkBusy;

+ (ShelbyApp *)sharedApp;
+ (UIWindow *)secondScreenWindow;

- (void)addNetworkObject:(id <NetworkObject>)networkObject;
- (void)removeNetworkObject:(id <NetworkObject>)networkObject;

@end

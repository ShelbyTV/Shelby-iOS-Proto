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
@class GraphiteStats;

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
@property (nonatomic, retain) GraphiteStats *graphiteStats;

@property (nonatomic, readonly) BOOL isNetworkBusy;

+ (ShelbyApp *)sharedApp;

- (void)addNetworkObject:(id <NetworkObject>)networkObject;
- (void)removeNetworkObject:(id <NetworkObject>)networkObject;
- (void)resetGraphiteStats;

@end

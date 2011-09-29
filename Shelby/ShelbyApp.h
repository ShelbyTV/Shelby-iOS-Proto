//
//  ShelbyApp.h
//  Shelby
//
//  Created by David Kay on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STVNetworkObject.h"

@class LoginHelper;
@class ApiHelper;
@class GraphiteStats;

/*
 * Global singleton for maintaining state.
 */
@interface ShelbyApp : NSObject {
  NSInteger _networkCounter;
  NSMutableSet *_networkObjects;
}

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) LoginHelper *loginHelper;
@property (nonatomic, retain) ApiHelper *apiHelper;
@property (nonatomic, retain) GraphiteStats *graphiteStats;

@property (nonatomic, readonly) BOOL isNetworkBusy;

+ (ShelbyApp *)sharedApp;

- (void)addNetworkObject:(id <STVNetworkObject>)networkObject;
- (void)removeNetworkObject:(id <STVNetworkObject>)networkObject;

@end

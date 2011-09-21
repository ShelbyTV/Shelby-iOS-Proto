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
@class NetworkManager;

/*
 * Global singleton for maintaining state.
 */
@interface ShelbyApp : NSObject {
  NSInteger _networkCounter;
  NSMutableSet *_networkObjects;
}

@property (nonatomic, retain) NetworkManager *networkManager;
@property (nonatomic, readonly) BOOL isNetworkBusy;

+ (ShelbyApp *)sharedApp;

- (void)addNetworkObject:(id <STVNetworkObject>)networkObject;
- (void)removeNetworkObject:(id <STVNetworkObject>)networkObject;

@end

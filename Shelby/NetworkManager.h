//
//  NetworkManager.h
//  Shelby
//
//  Created by David Kay on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STVNetworkObject.h"

@class LoginHelper;
@class User;

/**
 * This is our public-facing class for all things that go on the network.
 */
@interface NetworkManager : NSObject <STVNetworkObject> {
@private
    LoginHelper *_loginHelper;
}


@property (nonatomic, readonly) BOOL loggedIn;
@property (nonatomic, readonly) User *user;
@property (readonly) NSInteger networkCounter;

#pragma mark - Settings
- (void)changeChannel:(NSInteger)newChannel;

#pragma mark - OAuth Handshake
- (void)beginOAuthHandshake;
- (void)oAuthVerifierReturned:(NSString *)verifier;

- (void)logout;

#pragma mark - API Calls
- (BOOL)fetchBroadcasts;

@end

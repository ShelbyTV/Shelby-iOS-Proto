//
//  NetworkManager.h
//  Shelby
//
//  Created by David Kay on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginHelper;

/**
 * This is our public-facing class for all things that go on the network.
 */
@interface NetworkManager : NSObject {
@private
    LoginHelper *_loginHelper;
}


@property (nonatomic, readonly) BOOL loggedIn;

#pragma mark - OAuth Handshake
- (void)beginOAuthHandshake;
- (void)oAuthVerifierReturned:(NSString *)verifier;

#pragma mark - API Calls
- (BOOL)fetchBroadcasts;

@end

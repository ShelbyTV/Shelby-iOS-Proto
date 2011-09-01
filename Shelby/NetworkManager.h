//
//  NetworkManager.h
//  Shelby
//
//  Created by David Kay on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginHelper;

@interface NetworkManager : NSObject {

}

@property (nonatomic, retain) LoginHelper *loginHelper;

#pragma mark - OAuth Handshake
- (void)beginOAuthHandshake;
- (void)oAuthVerifierReturned:(NSString *)verifier;

#pragma mark - API Calls
- (BOOL)fetchBroadcasts;

@end

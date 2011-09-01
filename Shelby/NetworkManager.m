//
//  NetworkManager.m
//  Shelby
//
//  Created by David Kay on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkManager.h"
#import "LoginHelper.h"

@implementation NetworkManager

@synthesize loginHelper;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.loginHelper = [[[LoginHelper alloc] init] autorelease];
    }
    return self;
}

#pragma mark - Status
- (BOOL)loggedIn {
    // If we have stored both the accessToken and the secret, we're logged in.
    return self.loginHelper.loggedIn;
}

#pragma mark - OAuth Handshake
- (void)beginOAuthHandshake {
    [self.loginHelper getRequestToken];
}

- (void)oAuthVerifierReturned:(NSString *)verifier {
    [self.loginHelper verifierReturnedFromAuth: verifier];
}

#pragma mark - API Calls
- (BOOL)fetchBroadcasts {
    return [self.loginHelper fetchBroadcasts];
}

@end

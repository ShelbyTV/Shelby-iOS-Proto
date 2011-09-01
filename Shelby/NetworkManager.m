//
//  NetworkManager.m
//  Shelby
//
//  Created by David Kay on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkManager.h"
#import "LoginHelper.h"

@interface NetworkManager ()
@property (nonatomic, retain) LoginHelper *loginHelper;
@end

@implementation NetworkManager

@synthesize loginHelper = _loginHelper;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.loginHelper = [[[LoginHelper alloc] init] autorelease];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginHelperAuthorizedTokenNotification:)
                                                     name:@"LoginHelperAuthorizedAccessToken"
                                                   object:nil];
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

#pragma mark - Notifications

- (void)loginHelperAuthorizedTokenNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"NetworkManagerLoggedIn"
                                                        object: self];
}

@end

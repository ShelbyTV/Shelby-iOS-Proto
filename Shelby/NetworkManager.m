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

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginHelperAuthorizedToken:)
                                                     name:@"LoginHelperAuthorizedAccessToken"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginHelperLoginComplete:)
                                                     name:@"LoginHelperLoginComplete"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginHelperLoggedOut:)
                                                     name:@"LoginHelperLoggedOut"
                                                   object:nil];
    }
    return self;
}

#pragma mark - Status
- (BOOL)loggedIn {
    // If we have stored both the accessToken and the secret, we're logged in.
    return self.loginHelper.loggedIn;
}

- (User *)user {
    // If we have stored both the accessToken and the secret, we're logged in.
    return self.loginHelper.user;
}

- (NSInteger)networkCounter {
    return _loginHelper.networkCounter;
}

#pragma mark - Settings

- (void)changeChannel:(NSInteger)newChannel {
    // Change the channel.
    [self.loginHelper changeChannel: newChannel];
    // Fetch new broadcasts.
    [self fetchBroadcasts];
}

#pragma mark - OAuth Handshake
- (void)beginOAuthHandshake {
    [self.loginHelper getRequestToken];
}

- (void)oAuthVerifierReturned:(NSString *)verifier {
    [self.loginHelper verifierReturnedFromAuth: verifier];
}

- (void)logout {
    [self.loginHelper logout];
    // Now draw the login screen again.
}

#pragma mark - API Calls

- (BOOL)fetchBroadcasts {
    return [self.loginHelper fetchBroadcasts];
}

#pragma mark - Notifications

- (void)loginHelperAuthorizedToken:(NSNotification *)notification {
    //[[NSNotificationCenter defaultCenter] postNotificationName: @"NetworkManagerLoggedIn"
    //                                                    object: self];
}

- (void)loginHelperLoginComplete:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"NetworkManagerLoggedIn"
                                                        object: self];
}

- (void)loginHelperLoggedOut:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"NetworkManagerLoggedOut"
                                                        object: self];
}

@end

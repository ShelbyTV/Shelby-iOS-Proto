//
//  UserSessionHelper.m
//  Shelby
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserSessionHelper.h"
#import "User.h"
#import "Channel.h"
#import "Broadcast.h"
#import "SharerImage.h"
#import "ThumbnailImage.h"

#import "ShelbyAppDelegate.h"
#import "ShelbyApp.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "Video.h"

#import "NSURLConnection+AsyncBlock.h"
#import "NSString+URLEncoding.h"
#import "ApiMutableURLRequest.h"

#import "ApiConstants.h"
#import "ApiHelper.h"
#import "CoreDataHelper.h"

#import "GraphiteStats.h"
#import "SessionStats.h"

#import "DataApi.h"

@interface UserSessionHelper ()

@property (nonatomic, readwrite, retain) User *currentUser;
@property (nonatomic, retain) Channel *currentUserPublicChannel;
@property (nonatomic, retain) NSString *identityProvider;
@property (readwrite) NSInteger networkCounter;

@end

@implementation UserSessionHelper

@synthesize networkCounter;
@synthesize currentUser;
@synthesize currentUserPublicChannel;
@synthesize identityProvider;

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        self.currentUser = [CoreDataHelper fetchUserFromCoreDataContext:_context];
        self.currentUserPublicChannel = [CoreDataHelper fetchPublicChannelFromCoreDataContext:_context];
    }

    return self;
}

- (void)setCurrentUserFromCoreData
{
    self.currentUser = [CoreDataHelper fetchUserFromCoreDataContext:_context];
}

- (void)setCurrentUserPublicChannelFromCoreData
{
    self.currentUserPublicChannel = [CoreDataHelper fetchPublicChannelFromCoreDataContext:_context];
}

- (void)updateCurrentUserInCoreData
{
    [CoreDataHelper saveContextAndLogErrors:_context];
}

#pragma mark - Network Activity

- (void)incrementNetworkCounter
{
    @synchronized(self) { self.networkCounter++; }
}

- (void)decrementNetworkCounter
{
    @synchronized(self) { self.networkCounter--; }
}

#pragma mark - Login & Logout

- (BOOL)loggedIn
{
    // If we have stored both the accessToken and the secret, we're logged in.
    return ([ShelbyApp sharedApp].apiHelper.accessToken &&
            [ShelbyApp sharedApp].apiHelper.accessTokenSecret &&
            self.currentUser &&
            self.currentUserPublicChannel);
}


- (void)logout
{
    [GraphiteStats incrementCounter:@"signout" withAction:@"signout"];

    [[ShelbyApp sharedApp].apiHelper clearTokens];
    self.currentUser = nil;
    [CoreDataHelper deleteAllData];
    [SessionStats resetHeartbeatCount];
    [ShelbyApp sharedApp].demoModeEnabled = FALSE;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggedOut"
                                                        object:self
                                                        ];
}

#pragma mark - Request Token

- (void)beginLoginWithProvider:(NSString *)provider
{
    self.identityProvider = provider;

    handshake = [[OAuthHandshake alloc] init];
    [handshake setTokenRequestURL:[NSURL URLWithString:kRequestTokenUrl]];
    [handshake setTokenAuthURL:[NSURL URLWithString:kAccessTokenUrl]];
    [handshake setCallbackURL:kCallbackUrl];
    [handshake setDelegate:self];

    NSString *consumerKey = kShelbyConsumerKey;
    NSString *consumerSecret = kShelbyConsumerSecret;

    [handshake setConsumerKey:consumerKey];
    [handshake setConsumerSecret:consumerSecret];

    [self incrementNetworkCounter];
    [handshake beginHandshake];
}

#pragma mark - User Authorization

- (void)handshake:(OAuthHandshake *)handshake requestsUserToAuthenticateToken:(NSString *)token
{
    NSString *targetURL = [kUserAuthorizationUrl stringByAppendingFormat: @"?oauth_token=%@", [token URLEncodedString]];
    
    if (self.identityProvider) {
        targetURL = [targetURL stringByAppendingFormat: @"&provider=%@", self.identityProvider];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginURLAvailable"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSURL URLWithString:targetURL], @"url", nil]];
    
    [self decrementNetworkCounter];
}

- (void)handshake:(OAuthHandshake *)handshake failedWithError:(NSError *) error
{
    NSLog(@"OAuth request failed with an error: %@", [error localizedDescription]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OAuthHandshakeFailed" object:self];
    
    [self decrementNetworkCounter];
}

- (void)verifierReturnedFromAuth:(NSString *)verifier
{
    [self incrementNetworkCounter];
    [handshake continueHandshakeWithVerifier:verifier];
}

#pragma mark - Access Token

- (void)handshake:(OAuthHandshake *)handshake authenticatedToken:(NSString *)token withSecret:(NSString *)tokenSecret;
{
    [self decrementNetworkCounter];
    LOG(@"Authenticated token! %@ : %@", token, tokenSecret);

    [[ShelbyApp sharedApp].apiHelper storeAccessToken:token accessTokenSecret:tokenSecret];

    [DataApi fetchAndStoreUserSessionData];
    
    [[Panhandler sharedInstance] recordEventWithWeight:1];
}

@end

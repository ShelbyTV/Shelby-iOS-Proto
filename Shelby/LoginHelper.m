//
//  LoginHelper.m
//  ConsumerTwo
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginHelper.h"
#import "NSURLConnection+AsyncBlock.h"
#import "NSString+URLEncoding.h"
#import "OAuthMutableURLRequest.h"

#define kAppName @"Shelby.tv iOS"
#define kProviderName @"shelby.tv"

#define kRequestTokenName @"request"
#define kAccessTokenName @"access"
#define kAccessTokenSecretName @"access_secret"

#define kShelbyConsumerKey		@"RXbwSMUr8l810IwUz64fcHGsww2ZZXRItCbmNgmv"
#define kShelbyConsumerSecret		@"UaH7vX7e695nmEfgtLpPQVLeHZTOdBgnox0XfYfn"

#define kShelbyRequestToken	@"XNMyurKpFC8NIvGez5IgJzMuy78HhzmgoZ2gCW8B"
#define kShelbyRequestTokenSecret		@"eZB8bcVcNudzBYMORHUfsvzQtdxf3ylMbCvyjCLf"

#define kRequestTokenUrl      @"http://dev.shelby.tv/oauth/request_token"
#define kUserAuthorizationUrl @"http://dev.shelby.tv/oauth/authorize"
#define kAccessTokenUrl       @"http://dev.shelby.tv/oauth/access_token"

//#define kRequestTokenUrl      @"http://api.shelby.tv/oauth/request_token"
//#define kUserAuthorizationUrl @"http://api.shelby.tv/oauth/authorize"
//#define kAccessTokenUrl       @"http://api.shelby.tv/oauth/access_token"

#define kCallbackUrl       @"shelby://ios.shelby.tv"

@interface LoginHelper(Private)

#pragma mark - Persistence
- (void)loadTokens;
- (void)storeTokens;
- (void)clearTokens;

@end

@implementation LoginHelper

@synthesize delegate;

@synthesize accessToken;
@synthesize accessTokenSecret;

- (id)init
{
    self = [super init];
    if (self) {
        parser = [[SBJsonStreamParser alloc] init];
        parser.delegate = self;
        [self loadTokens];
    }

    return self;
}

#pragma mark - Token Storage

- (NSString *)consumerTokenSecret {
	return kShelbyConsumerSecret;
}

- (NSString *)consumerToken {
	return kShelbyConsumerKey;
}

- (void)loadTokens {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.accessToken = [defaults stringForKey: kAccessTokenName];
	self.accessTokenSecret = [defaults stringForKey: kAccessTokenSecretName];
}

/**
 * For now, we're using NSUserDefaults. However, this is insecure.
 * We should move to the keychain in the future.
 */
- (void)storeTokens {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: self.accessToken
                 forKey: kAccessTokenName];
    [defaults setObject: self.accessTokenSecret
                 forKey: kAccessTokenSecretName];
    [defaults synchronize];
}

- (void)clearTokens {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey: kAccessTokenName];
    [defaults removeObjectForKey: kAccessTokenSecretName];
    [defaults synchronize];
}

#pragma mark - Load Old Credentials

- (OAuthMutableURLRequest *) requestForURL: (NSURL *) url withMethod: (NSString *) method;
{
    OAuthMutableURLRequest *request = [[[OAuthMutableURLRequest alloc] initWithURL: url] autorelease];

    [request setConsumerKey: self.consumerToken secret: self.consumerTokenSecret];
    if (self.accessToken != nil) [request setToken: self.accessToken secret: self.accessTokenSecret];

    [request setHTTPMethod: method];

    return request;
}

#pragma mark - Request Token

- (void)getRequestToken {
    handshake = [[OAuthHandshake alloc] init];
    [handshake setTokenRequestURL:[NSURL URLWithString: kRequestTokenUrl]];
    [handshake setTokenAuthURL: [NSURL URLWithString: kAccessTokenUrl]];
    [handshake setCallbackURL: @"shelby://auth"];
    [handshake setDelegate: self];

    NSString *consumerKey = kShelbyConsumerKey;
    NSString *consumerSecret = kShelbyConsumerSecret;

    [handshake setConsumerKey: consumerKey];
    [handshake setConsumerSecret: consumerSecret];

    [handshake beginHandshake];
}

#pragma mark - User Authorization

- (void)handshake:(OAuthHandshake *)handshake requestsUserToAuthenticateToken:(NSString *)token;
{
    NSString *targetURL = [NSString stringWithFormat: @"%@?oauth_token=%@",
             kUserAuthorizationUrl,
             [token URLEncodedString]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: targetURL]];
}

- (void)verifierReturnedFromAuth:(NSString *)verifier {
  [handshake continueHandshakeWithVerifier: verifier];
}

#pragma mark - Access Token

- (void)handshake:(OAuthHandshake *)handshake authenticatedToken:(NSString *)token withSecret:(NSString *)tokenSecret;
{
  NSLog(@"Authenticated token! %@ : %@", token, tokenSecret);

  // Store token for later use.
  self.accessToken = token;
  self.accessTokenSecret = tokenSecret;
  [self storeTokens];

  [[NSNotificationCenter defaultCenter] postNotificationName: @"LoginHelperAuthorizedAccessToken"
                                                      object: self
                                                      ];
                                                    //userInfo: userInfo];
}


#pragma mark - Access Resources

//- (void)fetchBroadcasts {
- (BOOL)fetchBroadcasts {
    NSURL *url = [NSURL URLWithString: @"http://api.shelby.tv/broadcasts.json"];

    //OAuthMutableURLRequest *req = [handshake requestForURL:url withMethod:@"GET"];
    OAuthMutableURLRequest *req = [self requestForURL:url withMethod:@"GET"];

    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];

        [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetBroadcastsResponse:data:error:forRequest:)];
        return YES;
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetBroadcastsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
    NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"Got broadcasts: %@", string);

    [parser parse: data];
}

#pragma mark SBJsonStreamParserDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
	// Pass the data to VideoTableData.

	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		array, @"broadcasts",
                            nil];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"LoginHelperReceivedBroadcasts"
                                                        object: self
                                                      userInfo: userInfo];
	//[videoTableData gotNewJSONBroadcasts: array];
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
    [NSException raise:@"unexpected" format:@"Should not get here"];
}

@end

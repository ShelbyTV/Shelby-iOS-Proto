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

#define kUserIdName @"user_id"
#define kChannelIdName @"channel_id"
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

#define kFetchUserUrl         @"http://api.shelby.tv/users.json"
#define kFetchChannelsUrl     @"http://api.shelby.tv/channels.json"
#define kFetchBroadcastsUrl   @"http://api.shelby.tv/broadcasts/%@.json"

//#define kRequestTokenUrl      @"http://api.shelby.tv/oauth/request_token"
//#define kUserAuthorizationUrl @"http://api.shelby.tv/oauth/authorize"
//#define kAccessTokenUrl       @"http://api.shelby.tv/oauth/access_token"

#define kCallbackUrl       @"shelby://ios.shelby.tv"


@interface LoginHelper ()

#pragma mark - Persistence
- (void)loadTokens;
- (void)storeTokens;
- (void)clearTokens;

@end

@implementation LoginHelper

@synthesize delegate;

@synthesize accessToken;
@synthesize accessTokenSecret;
@synthesize userId;
@synthesize channelId;

- (id)init
{
    self = [super init];
    if (self) {
        parser = [[SBJsonStreamParser alloc] init];
        parser.delegate = self;
        parser.supportMultipleDocuments = YES;
        [self loadTokens];
    }

    return self;
}

#pragma mark - Token Storage

- (BOOL)loggedIn {
    // If we have stored both the accessToken and the secret, we're logged in.
    return (self.accessToken && self.accessTokenSecret && self.userId && self.channelId);
}

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
    self.userId = [defaults stringForKey: kUserIdName];
    self.userId = [defaults stringForKey: kChannelIdName];
}

/**
 * For now, we're using NSUserDefaults. However, this is insecure.
 * We should move to the keychain in the future.
 */
- (void)storeTokens {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: self.channelId
                 forKey: kChannelIdName];
    [defaults setObject: self.userId
                 forKey: kUserIdName];
    [defaults setObject: self.accessToken
                 forKey: kAccessTokenName];
    [defaults setObject: self.accessTokenSecret
                 forKey: kAccessTokenSecretName];
    [defaults synchronize];
}

- (void)clearTokens {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey: kUserIdName];
    [defaults removeObjectForKey: kChannelIdName];
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

    [self fetchUserId];
}

#pragma mark - User Id

- (BOOL)fetchUserId
{
    NSURL *url = [NSURL URLWithString: kFetchUserUrl];
    OAuthMutableURLRequest *req = [self requestForURL:url withMethod:@"GET"];

    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];

        [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetUserResponse:data:error:forRequest:)];
        return YES;
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetUserResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request
{
    NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"Got user: %@", string);

    _parserMode = STVParserModeUser;
    SBJsonStreamParserStatus status = [parser parse: data];
    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"User Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"User JSON Parsing error! %@", parser.error];
    }
}

#pragma mark - Channels

- (BOOL)fetchChannels
{
    NSURL *url = [NSURL URLWithString: kFetchChannelsUrl];
    OAuthMutableURLRequest *req = [self requestForURL:url withMethod:@"GET"];

    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];

        [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetChannelsResponse:data:error:forRequest:)];
        return YES;
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetChannelsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
    NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"Got channels: %@", string);

    _parserMode = STVParserModeChannels;
    SBJsonStreamParserStatus status = [parser parse: data];

    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"Channels Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"Channels JSON Parsing error! %@", parser.error];
    }
}

#pragma mark - Login Complete

- (void)loginComplete
{
    [self storeTokens];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"LoginHelperLoginComplete"
                                                        object: self
                                                        ];
}

#pragma mark - Access Resources

- (BOOL)fetchBroadcasts {
    if (self.userId) {
        NSURL *url = [NSURL URLWithString:
               [NSString stringWithFormat: kFetchBroadcastsUrl, self.channelId]];

        //OAuthMutableURLRequest *req = [handshake requestForURL:url withMethod:@"GET"];
        OAuthMutableURLRequest *req = [self requestForURL:url withMethod:@"GET"];

        if (req) {
            // Set to plaintext on request because oAuth library is broken.
            [req signPlaintext];

            [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetBroadcastsResponse:data:error:forRequest:)];
            return YES;
        }
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetBroadcastsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
    NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"Got broadcasts: %@", string);

    _parserMode = STVParserModeBroadcasts;
    SBJsonStreamParserStatus status = [parser parse: data];
    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"Broadcasts Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"Broadcasts JSON Parsing error!"];
    }
}

#pragma mark SBJsonStreamParserDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    // Pass the data to VideoTableData.

    switch (_parserMode) {
        case STVParserModeUser:
            LOG(@"USER Array found: %@", array);

            NSDictionary *user = [array objectAtIndex: 0];
            self.userId = [user objectForKey: @"_id"];
            [self storeTokens];
            [self fetchChannels];
            //[self loginComplete];

            LOG(@"USER dict found: %@", user);
            break;
        case STVParserModeChannels:
           LOG(@"CHANNEL array found: %@", array);
           NSDictionary *timeline =  [array objectAtIndex: 1];
           self.channelId = [timeline objectForKey: @"_id"];
           [self loginComplete];
           break;
        case STVParserModeBroadcasts:
            // For some reason, the compiler requires a log statement just after the 'case' statemnet.
           LOG(@"woohoo");
           NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
               array, @"broadcasts",
               nil];
           [[NSNotificationCenter defaultCenter] postNotificationName: @"LoginHelperReceivedBroadcasts"
                                                               object: self
                                                             userInfo: userInfo];
           break;
        default:
            [NSException raise:@"unexpected" format:@"Invalid parser mode!"];

    }
    _parserMode = STVParserModeIdle;
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
    switch (_parserMode) {
        case STVParserModeBroadcasts:
            LOG(@"YAhoo");
            NSString *error = [dict objectForKey: @"err"];
            if (error) {
                [NSException raise:@"unexpected" format:@"User not logged in!. Error: %@", error];
            } else {
                [NSException raise:@"unexpected" format:@"Should not get here"];
            }
            break;
        case STVParserModeUser:
            LOG(@"USER object found: %@", dict);
            break;
        default:
            [NSException raise:@"unexpected" format:@"Invalid parser mode!"];
    }
    _parserMode = STVParserModeIdle;
}

@end

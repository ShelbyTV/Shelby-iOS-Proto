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

#define kShelbyConsumerKey		@"RXbwSMUr8l810IwUz64fcHGsww2ZZXRItCbmNgmv"
#define kShelbyConsumerSecret		@"UaH7vX7e695nmEfgtLpPQVLeHZTOdBgnox0XfYfn"

#define kShelbyRequestToken	@"XNMyurKpFC8NIvGez5IgJzMuy78HhzmgoZ2gCW8B"
#define kShelbyRequestTokenSecret		@"eZB8bcVcNudzBYMORHUfsvzQtdxf3ylMbCvyjCLf"

#define kRequestTokenUrl      @"http://dev.shelby.tv/oauth/request_token"
#define kUserAuthorizationUrl @"http://dev.shelby.tv/oauth/authorize"
#define kAccessTokenUrl       @"http://dev.shelby.tv/oauth/access_token"

#define kCallbackUrl       @"shelby://ios.shelby.tv"

@implementation LoginHelper

@synthesize delegate;
//@synthesize requestToken = _requestToken;
//@synthesize accessToken = _accessToken;
//@synthesize verifier = _verifier;

- (id)init
{
  self = [super init];
  if (self) {
    // Initialization code here.
//    self.requestToken = [self retrieveTokenWithName: kRequestTokenName];
//    self.accessToken  = [self retrieveTokenWithName: kAccessTokenName];
  }

  return self;
}

#pragma mark - Token Storage

//- (void)clearTokens {
//  [OAToken removeFromUserDefaultsWithServiceProviderName: kProviderName
//                                                  prefix: kRequestTokenName];
//  [OAToken removeFromUserDefaultsWithServiceProviderName: kProviderName
//                                                  prefix: kAccessTokenName];
//}
//
//- (void)storeToken:(OAToken *)token withName:(NSString *)name {
//  //[token storeInDefaultKeychainWithAppName:kAppName
//  //										 serviceProviderName:kProviderName];
//  [token storeInUserDefaultsWithServiceProviderName: kProviderName
//                                             prefix: name
//                                             ];
//}
//
//- (OAToken *)retrieveTokenWithName:(NSString *)name {
//  //OAToken *accessToken = [[OAToken alloc] initWithKeychainUsingAppName:kAppName
//  //                                                 serviceProviderName:kProviderName];
//  OAToken *accessToken = [[OAToken alloc]
//    initWithUserDefaultsUsingServiceProviderName: kProviderName
//                                          prefix: name
//                                          ];
//  return [accessToken autorelease];
//}

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
  [self fetchBroadcasts];
}

#pragma mark - Access Resources

- (void)fetchBroadcasts {
  NSURL *url = [NSURL URLWithString: @"http://api.shelby.tv/broadcasts.json"];
  OAuthMutableURLRequest *req = [handshake requestForURL:url withMethod:@"GET"];

  //OAuthMutableURLRequest *req = [handshake requestForURL:url withMethod:@"POST"];
  //NSString *tweet = @"<enter tweet here>";
  //NSString *message = [NSString stringWithFormat: @"status=%@", [tweet URLEncodedString]];
  //[req setHTTPBody: [message dataUsingEncoding: NSASCIIStringEncoding]];
  //[req setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"content-type"];

  //[req sign];
  //[req setValue: @"PLAINTEXT" forOAuthParameter: @"oauth_signature_method"];
  // Set to plaintext on request because oAuth library is broken.
  [req signPlaintext];

  [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetBroadcastsResponse:data:error:forRequest:)];
}

- (void)receivedGetBroadcastsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
  NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
  NSLog( @"sent tweet, reply: %@", string );
}

@end

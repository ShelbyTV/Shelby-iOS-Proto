//
//  LoginHelper.m
//  ConsumerTwo
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginHelper.h"

#import "OAuthConsumer.h"

#define kAppName @"Shelby.tv iOS"
#define kProviderName @"shelby.tv"

#define kShelbyConsumerKey		@"RXbwSMUr8l810IwUz64fcHGsww2ZZXRItCbmNgmv"
#define kShelbyConsumerSecret		@"UaH7vX7e695nmEfgtLpPQVLeHZTOdBgnox0XfYfn"

#define kShelbyRequestToken	@"XNMyurKpFC8NIvGez5IgJzMuy78HhzmgoZ2gCW8B"
#define kShelbyRequestTokenSecret		@"eZB8bcVcNudzBYMORHUfsvzQtdxf3ylMbCvyjCLf"

#define kRequestTokenUrl      @"http://dev.shelby.tv/oauth/request_token"
#define kUserAuthorizationUrl @"http://dev.shelby.tv/oauth/authorize"
#define kAccessTokenUrl       @"http://dev.shelby.tv/oauth/access_token"

@implementation LoginHelper

@synthesize delegate;
@synthesize requestToken = _requestToken;
@synthesize accessToken = _accessToken;

- (id)init
{
  self = [super init];
  if (self) {
    // Initialization code here.

  }

  return self;
}

#pragma mark - Request Token

- (void)getRequestToken {
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kShelbyConsumerKey
                                                    secret:kShelbyConsumerSecret];
    
    NSURL *url = [NSURL URLWithString: kRequestTokenUrl];
    
		OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																																	 consumer:consumer
																																			token:nil   // we don't have a Token yet
																																			realm:nil   // our service provider doesn't specify a realm
																													signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		OAToken *requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    [responseBody release];
    self.requestToken = requestToken;
    [requestToken release];
    // Notify delegate.
    [self.delegate fetchRequestTokenDidFinish: requestToken];
    LOG(@"request token: %@", requestToken);
	}
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"requestToken failure! %@", error);
  [self.delegate requestTokenTicket:ticket didFailWithError: error];
}

#pragma mark - User Authorization

- (void)authorizeToken:(OAToken *)requestToken {
    LOG(@"authorizing token: %@", requestToken);
  // Create the url string with the given token

	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: 
    @"%@?oauth_token=%@",
    kUserAuthorizationUrl,
    requestToken.key
  ]];

	[[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Access Token

- (void)getAccessToken:(OAToken *)requestToken {
	// Similar to fetching the request token.
  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kShelbyConsumerKey
                                                  secret:kShelbyConsumerSecret];

	NSURL *url = [NSURL URLWithString: kAccessTokenUrl];

	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																																 consumer:consumer
																																		token:requestToken   // we don't have a Token yet
																																		realm:nil   // our service provider doesn't specify a realm
																												signatureProvider:nil]; // use the default method, HMAC-SHA1

	[request setHTTPMethod:@"POST"];

	OADataFetcher *fetcher = [[OADataFetcher alloc] init];

	[fetcher fetchDataWithRequest:request
											 delegate:self.delegate
							didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
								didFailSelector:@selector(accessTokenTicket:didFailWithError:)];

}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    self.accessToken = accessToken;
    LOG(@"access token: %@", accessToken);
    // notify delegate
    [self.delegate fetchAccessTokenDidFinish: accessToken];
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"accessToken failure! %@", error);
  [self.delegate accessTokenTicket:ticket didFailWithError: error];
}

#pragma mark - Token Storage

- (void)clearTokens {
  
}

- (void)storeToken:(OAToken *)token {
	[token storeInDefaultKeychainWithAppName:kAppName       
											 serviceProviderName:kProviderName];
}

- (OAToken *)retrieveToken {
	  OAToken *accessToken = [[OAToken alloc] initWithKeychainUsingAppName:kAppName
                                                     serviceProviderName:kProviderName];
		return accessToken;
}

#pragma mark - Access Resources



@end

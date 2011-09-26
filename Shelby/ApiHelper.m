//
//  ApiHelper.m
//  Shelby
//
//  Created by Mark Johnson on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ApiHelper.h"
#import "ApiConstants.h"
#import "OAuthMutableURLRequest.h"

@implementation ApiHelper

#pragma mark - Properties

@synthesize accessToken;
@synthesize accessTokenSecret;
@synthesize networkCounter;

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - URL Request

- (OAuthMutableURLRequest *)requestForURL:(NSURL *)url 
                               withMethod:(NSString *)method;
{
    OAuthMutableURLRequest *request = [[[OAuthMutableURLRequest alloc] initWithURL: url] autorelease];
    
    [request setConsumerKey:kShelbyConsumerKey secret:kShelbyConsumerSecret];
    if (self.accessToken != nil) [request setToken: self.accessToken secret: self.accessTokenSecret];
    
    [request setHTTPMethod: method];
    
    return request;
}

#pragma mark - Token Storage

/**
 * For now, we're using NSUserDefaults. However, this is insecure.
 * We should move to the keychain in the future.
 */
- (void)storeAccessToken:(NSString *)newAccessToken
       accessTokenSecret:(NSString *)newAccessTokenSecret
{
    self.accessToken = newAccessToken;
    self.accessTokenSecret = newAccessTokenSecret;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: newAccessToken
                 forKey: kAccessTokenName];
    [defaults setObject: newAccessTokenSecret
                 forKey: kAccessTokenSecretName];
    [defaults synchronize];
}

- (void)loadTokens
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [defaults stringForKey: kAccessTokenName];
    self.accessTokenSecret = [defaults stringForKey: kAccessTokenSecretName];
}

- (void)clearTokens
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey: kAccessTokenName];
    [defaults removeObjectForKey: kAccessTokenSecretName];
    [defaults synchronize];
}

#pragma mark - Network Op Counts

- (void)incrementNetworkCounter {
    self.networkCounter++;
}

- (void)decrementNetworkCounter {
    self.networkCounter--;
}


@end

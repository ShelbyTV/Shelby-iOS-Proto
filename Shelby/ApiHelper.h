//
//  ApiHelper.h
//  Shelby
//
//  Created by Mark Johnson on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STVNetworkObject.h"

@class OAuthMutableURLRequest;

@interface ApiHelper : NSObject <STVNetworkObject>

@property (readwrite) NSInteger networkCounter;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *accessTokenSecret;

- (OAuthMutableURLRequest *)requestForURL: (NSURL *) url withMethod: (NSString *) method;
- (void)storeAccessToken:(NSString *)newAccessToken
       accessTokenSecret:(NSString *)newAccessTokenSecret;
- (void)loadTokens;
- (void)clearTokens;
- (void)incrementNetworkCounter;
- (void)decrementNetworkCounter;

@end

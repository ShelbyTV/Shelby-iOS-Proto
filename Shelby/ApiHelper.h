//
//  ApiHelper.h
//  Shelby
//
//  Created by Mark Johnson on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STVNetworkObject.h"

@class ApiMutableURLRequest;

@interface ApiHelper : NSObject <STVNetworkObject>

#pragma mark - Properties
@property (readwrite) NSInteger networkCounter;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *accessTokenSecret;

#pragma mark - URL Request
- (ApiMutableURLRequest *)requestForURL: (NSURL *) url withMethod: (NSString *) method;

#pragma mark - Token Storage
- (void)storeAccessToken:(NSString *)newAccessToken
       accessTokenSecret:(NSString *)newAccessTokenSecret;
- (void)loadTokens;
- (void)clearTokens;

#pragma mark - Network Op Counts
- (void)incrementNetworkCounter;
- (void)decrementNetworkCounter;

@end

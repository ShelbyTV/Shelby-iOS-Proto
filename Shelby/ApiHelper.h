//
//  ApiHelper.h
//  Shelby
//
//  Created by Mark Johnson on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkObject.h"

@class ApiMutableURLRequest;

@interface ApiHelper : NSObject <NetworkObject> {
}

@property (readonly) NSInteger networkCounter;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *accessTokenSecret;

- (ApiMutableURLRequest *)requestForURL:(NSURL *)url 
                             withMethod:(NSString *)method;
- (void)loadTokens;
- (void)clearTokens;
- (void)storeAccessToken:(NSString *)newAccessToken
       accessTokenSecret:(NSString *)newAccessTokenSecret;

- (void)incrementNetworkCounter;
- (void)decrementNetworkCounter;

@end

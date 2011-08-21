//
//  LoginHelper.h
//  ConsumerTwo
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthHandshake.h"

@class SBJsonStreamParser;

@protocol LoginHelperDelegate

//- (void)fetchRequestTokenDidFinish:(OAToken *)requestToken;
//- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
//
//- (void)fetchAccessTokenDidFinish:(OAToken *)accessToken;
//- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

@end

@interface LoginHelper : NSObject <OAuthHandshakeDelegate> {
  OAuthHandshake *handshake;
  SBJsonStreamParser *parser;
}

@property (assign) id <LoginHelperDelegate> delegate;

@property (nonatomic, readonly) NSString *consumerToken;
@property (nonatomic, readonly) NSString *consumerTokenSecret;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *accessTokenSecret;

- (void)getRequestToken;
- (void)verifierReturnedFromAuth:(NSString *)verifier;
- (void)fetchBroadcasts;

@end

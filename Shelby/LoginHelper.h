//
//  LoginHelper.h
//  ConsumerTwo
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"

@protocol LoginHelperDelegate

- (void)fetchRequestTokenDidFinish:(OAToken *)requestToken;
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (void)fetchAccessTokenDidFinish:(OAToken *)accessToken;
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

@end

@interface LoginHelper : NSObject {
  // Cache our tokens for future use.
}

@property (assign) id <LoginHelperDelegate> delegate;

@property (nonatomic, retain) OAToken *requestToken;
@property (nonatomic, retain) OAToken *accessToken;

@end

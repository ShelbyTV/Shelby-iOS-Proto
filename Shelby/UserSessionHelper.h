//
//  UserSessionHelper.h
//  Shelby
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthHandshake.h"
#import "NetworkObject.h"

@class User;
@class Channel;

@interface UserSessionHelper : NSObject <OAuthHandshakeDelegate, NetworkObject>
{
    NSManagedObjectContext *_context; // context we keep alive for the global currentUser* variables
    OAuthHandshake *handshake;
}

@property (readonly) NSInteger networkCounter;
@property (nonatomic, readonly, retain) User *currentUser;
@property (nonatomic, readonly, retain) Channel *currentUserPublicChannel;

- (id)initWithContext:(NSManagedObjectContext *)context;

- (void)getRequestTokenWithProvider:(NSString *)provider;
- (void)verifierReturnedFromAuth:(NSString *)verifier;

- (void)setCurrentUserFromCoreData;

- (void)logout;
- (BOOL)loggedIn;

@end

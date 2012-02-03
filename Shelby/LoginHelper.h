//
//  LoginHelper.h
//  Shelby
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OAuthHandshake.h"
#import "SBJsonStreamParser.h"
#import "NetworkObject.h"

typedef enum {
    ParserModeIdle,
    ParserModeUser,
    ParserModeBroadcasts,
    ParserModeChannels,
} ParserMode;

@class SBJsonStreamParser;
@class User;
@class Channel;
@class Broadcast;
@class Video;

@interface LoginHelper : NSObject <OAuthHandshakeDelegate, SBJsonStreamParserDelegate, NetworkObject>
{
    OAuthHandshake *handshake;
    SBJsonStreamParser *_parser;
    ParserMode _parserMode;
    NSManagedObjectContext *_context;
}

@property (readonly) NSInteger networkCounter;
@property (nonatomic, retain) NSDate *lastFetchBroadcasts;
@property (nonatomic, readonly, retain) User *user;

- (id)initWithContext:(NSManagedObjectContext *)context;

- (void)getRequestTokenWithProvider:(NSString *)provider;
- (void)verifierReturnedFromAuth:(NSString *)verifier;

- (void)logout;
- (BOOL)loggedIn;

- (void)fetchAuthentications;
- (void)fetchBroadcasts;

@end

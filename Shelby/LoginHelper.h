//
//  LoginHelper.h
//  ConsumerTwo
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

/**
 * The NetworkManager uses this class internally, but no other objects should
 * have to worry about this class.
 */
@interface LoginHelper : NSObject <OAuthHandshakeDelegate, SBJsonStreamParserDelegate, NetworkObject> {
    OAuthHandshake *handshake;
    SBJsonStreamParser *_parser;
    ParserMode _parserMode;
    NSManagedObjectContext *_context;
}

@property (readonly) NSInteger networkCounter;
@property (nonatomic, retain) NSDate *lastFetchBroadcasts;
@property (nonatomic, readonly, retain) User *user;
@property (nonatomic, retain) Channel *channel;

@property (nonatomic, retain) NSString *identityProvider;

#pragma mark - Initialization
- (id)initWithContext:(NSManagedObjectContext *)context;

#pragma mark - OAuth Handshake
- (void)getRequestTokenWithProvider:(NSString *)provider;
- (void)getRequestToken;
- (void)verifierReturnedFromAuth:(NSString *)verifier;
- (void)logout;

#pragma mark - API Calls
- (BOOL)fetchBroadcasts;
- (Broadcast *)fetchBroadcastWithId:(NSString*)broadcastId;

#pragma mark - Broadcast CoreData Storage
- (void)storeBroadcastVideo:(Video *)video withThumbnailData:(NSData *)thumbnailData inContext:(NSManagedObjectContext *)context;
- (void)storeBroadcastVideo:(Video *)video withSharerImageData:(NSData *)sharerImageData inContext:(NSManagedObjectContext *)context;

- (BOOL)loggedIn;

@end

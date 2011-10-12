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

#import "STVNetworkObject.h"

typedef enum {
    STVParserModeIdle,
    STVParserModeUser,
    STVParserModeBroadcasts,
    STVParserModeChannels,
} STVParserMode;

@class SBJsonStreamParser;
@class User;
@class Channel;
@class Broadcast;
@class Video;

@protocol LoginHelperDelegate

//- (void)fetchRequestTokenDidFinish:(OAToken *)requestToken;
//- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
//
//- (void)fetchAccessTokenDidFinish:(OAToken *)accessToken;
//- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

@end

/**
 * The NetworkManager uses this class internally, but no other objects should
 * have to worry about this class.
 */
@interface LoginHelper : NSObject <OAuthHandshakeDelegate, SBJsonStreamParserDelegate, STVNetworkObject> {
    OAuthHandshake *handshake;
    SBJsonStreamParser *_parser;
    User *_user;
    @private
    STVParserMode _parserMode;
    NSManagedObjectContext *_context;
}

@property (assign) id <LoginHelperDelegate> delegate;
@property (readwrite) NSInteger networkCounter;
@property (nonatomic, retain) NSDate *lastFetchBroadcasts;

@property (nonatomic, readonly) BOOL loggedIn;


@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Channel *channel;

@property (nonatomic, retain) NSString *identityProvider;

#pragma mark - Initialization
- (id)initWithContext:(NSManagedObjectContext *)context;

#pragma mark - Settings
- (void)changeChannel:(NSInteger)newChannel;

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

@end

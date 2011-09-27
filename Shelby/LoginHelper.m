//
//  LoginHelper.m
//  ConsumerTwo
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginHelper.h"
#import "User.h"
#import "Channel.h"
#import "Broadcast.h"
#import "ShelbyAppDelegate.h"
#import "ShelbyApp.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"

#import "NSURLConnection+AsyncBlock.h"
#import "NSString+URLEncoding.h"
#import "ApiMutableURLRequest.h"

#import "ApiConstants.h"
#import "ApiHelper.h"

@interface LoginHelper ()

- (BOOL)fetchUserId;
- (User *)retrieveUser;
- (NSArray *)retrieveChannels;
- (Channel *)getPublicChannel:(NSInteger)public fromArray:(NSArray *)channels;

@end

@implementation LoginHelper

@synthesize delegate;
@synthesize networkCounter;
@synthesize user;
@synthesize channel;
@synthesize identityProvider;


- (id)init
{
    ShelbyAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    return [self initWithContext: context];
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        _context = [context retain];
        _parser = [[SBJsonStreamParser alloc] init];
        _parser.delegate = self;
        _parser.supportMultipleDocuments = YES;
        self.user = [self retrieveUser];
        self.channel = [self getPublicChannel: 0 fromArray: [self retrieveChannels]];
    }

    return self;
}

#pragma mark - Network Activity

- (void)incrementNetworkCounter {
    //[self incrementNetworkCounter];
    self.networkCounter++;
}

- (void)decrementNetworkCounter {
    //[self decrementNetworkCounter];
    self.networkCounter--;
}

#pragma mark - Settings

- (void)changeChannel:(NSInteger)newChannel {
    // Change the channel.
    self.channel = [self getPublicChannel: newChannel fromArray: [self retrieveChannels]];
}


- (BOOL)loggedIn {
    // If we have stored both the accessToken and the secret, we're logged in.
    return ([ShelbyApp sharedApp].apiHelper.accessToken && 
            [ShelbyApp sharedApp].apiHelper.accessTokenSecret && 
            self.user && 
            self.channel);
}


- (void)logout {
    [[ShelbyApp sharedApp].apiHelper clearTokens];
    //DEBUG ONLY!
    //[[NSThread mainThread] exit];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UserLoggedOut"
                                                        object: self
                                                        ];
}

#pragma mark - Request Token

- (void)getRequestTokenWithProvider:(NSString *)provider {
    self.identityProvider = provider;

    handshake = [[OAuthHandshake alloc] init];
    [handshake setTokenRequestURL:[NSURL URLWithString: kRequestTokenUrl]];
    [handshake setTokenAuthURL: [NSURL URLWithString: kAccessTokenUrl]];
    [handshake setCallbackURL: kCallbackUrl];
    [handshake setDelegate: self];

    NSString *consumerKey = kShelbyConsumerKey;
    NSString *consumerSecret = kShelbyConsumerSecret;

    [handshake setConsumerKey: consumerKey];
    [handshake setConsumerSecret: consumerSecret];

    [handshake beginHandshake];

    [self incrementNetworkCounter];
}

- (void)getRequestToken {
    [self getRequestTokenWithProvider: nil];
}

#pragma mark - User Authorization

- (void)handshake:(OAuthHandshake *)handshake requestsUserToAuthenticateToken:(NSString *)token
{
    NSString *targetURL = [NSString stringWithFormat: @"%@?oauth_token=%@",
             kUserAuthorizationUrl,
             [token URLEncodedString]];
    if (self.identityProvider) {
        targetURL = [NSString stringWithFormat: @"%@&provider=%@",
            targetURL,
            self.identityProvider];

    }
    //NSString *targetURL = [NSString stringWithFormat: @"%@?oauth_token=%@&provider=twitter",
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: targetURL]];
}

- (void)handshake:(OAuthHandshake *)handshake failedWithError:(NSError *) error
{
    NSLog(@"OAuth request failed with an error: %@", [error localizedDescription]);
    [[NSNotificationCenter defaultCenter] postNotificationName: @"OAuthHandshakeFailed"
                                                        object: self];
    [self decrementNetworkCounter];
}

- (void)verifierReturnedFromAuth:(NSString *)verifier {
    [handshake continueHandshakeWithVerifier: verifier];
}

#pragma mark - Access Token

- (void)handshake:(OAuthHandshake *)handshake authenticatedToken:(NSString *)token withSecret:(NSString *)tokenSecret;
{
    NSLog(@"Authenticated token! %@ : %@", token, tokenSecret);

    // Store token for later use.
    [[ShelbyApp sharedApp].apiHelper storeAccessToken:token accessTokenSecret:tokenSecret];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"OAuthAuthorizedAccessToken"
                                                        object:self
                                                        ];

    [self fetchUserId];
}

#pragma mark - User Id

- (BOOL)fetchUserId
{
    NSURL *url = [NSURL URLWithString: kUserUrl];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];

    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];

        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedGetUserResponse:data:error:forRequest:)];
        [self incrementNetworkCounter];
        return YES;
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetUserResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request
{
    [self decrementNetworkCounter];
    NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"Got user: %@", string);

    _parserMode = STVParserModeUser;
    SBJsonStreamParserStatus status = [_parser parse: data];
    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"User Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"User JSON Parsing error! %@", _parser.error];
    }
}

- (NSData *)fetchUserImageDataWithDictionary:(NSDictionary *)dict
{
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURL *url = [[[NSURL alloc] initWithString:[dict objectForKey:@"user_image"]] autorelease];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    /*
     * if there's an error, this should just return NULL, which will result in the default
     * blank face user image eventually being shown.
     *
     * bad news is a slow response might make us hang here for a little while, so it would
     * be nice to make this async and have it just update the UI to show the image if it
     * gets handled after the UI is all laid out.
     */
    return [NSURLConnection sendSynchronousRequest:request
                                  returningResponse:&response
                                              error:&error];
}

- (User *)storeUserWithDictionary:(NSDictionary *)dict
                    withImageData:(NSData *)imageData
{
    User *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:_context];
    [newUser setValue:[dict objectForKey:@"name"]  forKey:@"name"];
    [newUser setValue:[dict objectForKey:@"nickname"]  forKey:@"nickname"];
    [newUser setValue:[dict objectForKey:@"user_image"]  forKey:@"imageUrl"];
    [newUser setValue:[dict objectForKey:@"_id"]  forKey:@"shelbyId"];
    [newUser setValue:imageData forKey:@"image"];

    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
    return newUser;
}

- (User *)retrieveUser {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
        entityForName:@"User" inManagedObjectContext: _context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *objects = [_context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if ([objects count] > 0) {
        return [objects objectAtIndex: 0];
    } else {
        return nil;
    }
}

#pragma mark - Channels

- (Channel *)getPublicChannel:(NSInteger)public fromArray:(NSArray *)channels
{
    for (Channel *c in channels) {
        if ([c.public integerValue] == public) {
            return c;
            break;
        }
    }
    return nil;
}

- (BOOL)fetchChannels
{
    NSURL *url = [NSURL URLWithString: kChannelsUrl];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];

    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];

        [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetChannelsResponse:data:error:forRequest:)];
        [self incrementNetworkCounter];
        return YES;
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetChannelsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
    [self decrementNetworkCounter];
    NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"Got channels: %@", string);

    _parserMode = STVParserModeChannels;
    SBJsonStreamParserStatus status = [_parser parse: data];

    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"Channels Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"Channels JSON Parsing error! %@", _parser.error];
    }
}

- (void)storeChannelsWithArray:(NSArray *)array user:(User *)newUser {
    for (NSDictionary *dict in array) {
        LOG(@"Channel dict: %@", dict);
        Channel *newChannel = [NSEntityDescription
          insertNewObjectForEntityForName:@"Channel"
                   inManagedObjectContext:_context];
        NSNumber *public = [dict objectForKey:@"public"];
        [newChannel setValue: public forKey:@"public"];
        NSString *name = [dict objectForKey:@"name"];
        [newChannel setValue: name forKey:@"name"];
        NSString *shelbyId = [dict objectForKey:@"_id"];
        [newChannel setValue: shelbyId forKey:@"shelbyId"];
        if (newUser) newChannel.user = newUser;
    }

    NSError *error;
    if (![_context save:&error]) {
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@"  DetailedError: %@", [detailedError userInfo]);
            }
        }
        else {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
}

- (void)storeChannelsWithArray:(NSArray *)array {
    [self storeChannelsWithArray: array user: self.user];
}

- (NSArray *)retrieveChannels {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
        entityForName:@"Channel" inManagedObjectContext: _context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *channels = [_context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if ([channels count] > 0) {
        return channels;
    } else {
        return nil;
    }
}

#pragma mark - Broadcasts

- (BOOL)fetchBroadcasts {
    if (self.user) {
        NSURL *url = [NSURL URLWithString:
               [NSString stringWithFormat: kBroadcastsUrl, self.channel.shelbyId]];
        LOG(@"Fetching broadcasts from: %@", url);

        //ApiMutableURLRequest *req = [handshake requestForURL:url withMethod:@"GET"];
        ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];

        if (req) {
            // Set to plaintext on request because oAuth library is broken.
            [req signPlaintext];

            [self incrementNetworkCounter];
            [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetBroadcastsResponse:data:error:forRequest:)];
            return YES;
        }
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetBroadcastsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
    [self decrementNetworkCounter];
    //NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    //NSLog(@"Got broadcasts: %@", string);

    _parserMode = STVParserModeBroadcasts;
    SBJsonStreamParserStatus status = [_parser parse: data];
    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"Broadcasts Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"Broadcasts JSON Parsing error!"];
    }
}

- (Broadcast *)populateBroadcastFromDictionary:(Broadcast *)broadcast dictionary:(NSDictionary *)dict {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    NSString *shelbyId = [dict objectForKey: @"_id"];
    if (NOTNULL(shelbyId)) {
        broadcast.shelbyId = shelbyId ;
    }
    NSString *providerId = [dict objectForKey: @"video_id_at_provider"];
    if (NOTNULL(providerId)) {
        broadcast.providerId = providerId ;
    }
    NSString *thumbnailImageUrl = [dict objectForKey: @"video_thumbnail_url"];
    if (NOTNULL(thumbnailImageUrl)) {
        broadcast.thumbnailImageUrl = thumbnailImageUrl ;
    }
    NSString *title  = [dict objectForKey: @"video_title"];
    if (NOTNULL(title)) {
        broadcast.title = title ;
    }
    NSString *sharerComment  = [dict objectForKey: @"description"];
    if (NOTNULL(sharerComment)) {
        broadcast.sharerComment = sharerComment ;
    }
    NSString *sharerName = [dict objectForKey: @"video_originator_user_name"];
    if (NOTNULL(sharerName)) {
        broadcast.sharerName = sharerName ;
    }
    NSString *videoOrigin = [dict objectForKey: @"video_origin"];
    if (NOTNULL(videoOrigin)) {
        broadcast.origin = videoOrigin ;
    }
    NSString *sharerImageUrl = [dict objectForKey: @"video_originator_user_image"];
    if (NOTNULL(sharerImageUrl)) {
        broadcast.sharerImageUrl = sharerImageUrl ;
    }
 
    NSDate *createdAt = [dateFormatter dateFromString:[dict objectForKey: @"created_at"]];
    if (NOTNULL(createdAt)) {
        broadcast.createdAt = createdAt ;
    }

    //"liked_by_owner": true,
     //"liked_by_user": null,
    //NSString *liked = [dict objectForKey: @"liked_by_user"];
    NSNumber *liked = [dict objectForKey: @"liked_by_owner"];
    if (NOTNULL(liked) && [liked boolValue]) {
        //broadcast.liked = YES;
        broadcast.liked = [NSNumber numberWithBool: YES];
    } else {
        //broadcast.liked = NO;
        broadcast.liked = [NSNumber numberWithBool: NO];
    }

    return broadcast;
}

- (void)storeBroadcastsWithArray:(NSArray *)array channel:(Channel *)newChannel
{    
    
    for (NSDictionary *dict in array) {
        //LOG(@"Broadcast dict: %@", dict);
        Broadcast *broadcast = [NSEntityDescription
          insertNewObjectForEntityForName:@"Broadcast"
                   inManagedObjectContext:_context];

        broadcast = [self populateBroadcastFromDictionary:broadcast dictionary: dict];
        

        //NSString *youtubeDescription  = [broadcast objectForKey: @"video_description"];
        //Description - tweet
        //video_description - youtube description
        //video_title - youtube title

        if (newChannel) broadcast.channel = newChannel;
    }

    NSError *error;
    if (![_context save:&error]) {
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@"  DetailedError: %@", [detailedError userInfo]);
            }
        } else {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
}

- (Broadcast *)fetchBroadcastWithId:(NSString*)broadcastId {
    Broadcast *broadcast = nil;

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: kBroadcastUrl, broadcastId]];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    [req signPlaintext];

    /*
     * if there's an error, this should just return NULL, which will result in the default
     * blank face user image eventually being shown.
     *
     * bad news is a slow response might make us hang here for a little while, so it would
     * be nice to make this async and have it just update the UI to show the image if it
     * gets handled after the UI is all laid out.
     */

    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&response
                                                     error:&error];

    if (data) {
        NSString *stringReply = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
         NSLog(@"Broadcast: %@", stringReply);
        // Parse into JSON
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *array = [parser objectWithData: data];
        if (parser.error) {
            NSLog(@"Broadcast Parser error: %@", parser.error);
        } else {
            NSDictionary *dict = [array objectAtIndex: 0];
            broadcast = [NSEntityDescription
                insertNewObjectForEntityForName:@"Broadcast"
                         inManagedObjectContext:_context];
            [self populateBroadcastFromDictionary: broadcast dictionary: dict];
            [parser release];
        }
    }

    return broadcast;
}

- (NSArray *)retrieveBroadcastsForChannel:(Channel *)c {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
        entityForName:@"Broadcast" inManagedObjectContext: _context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
        @"(channel == %@)", c];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *broadcasts = [_context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if ([broadcasts count] > 0) {
        return broadcasts;
    } else {
        LOG(@"Found no broadcasts for channel: %@. Error: %@", c, error);
        return nil;
    }
}

#pragma mark - Login Complete

- (void)loginComplete {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UserLoggedIn"
                                                        object: self
                                                        ];
}

#pragma mark - SBJsonStreamParserDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    // Pass the data to VideoTableData.

    switch (_parserMode) {
        case STVParserModeUser:
            LOG(@"USER Array found: %@", array);

            NSDictionary *dict = [array objectAtIndex: 0];
            [self incrementNetworkCounter];
            self.user = [self storeUserWithDictionary:dict withImageData:[self fetchUserImageDataWithDictionary:dict]];
            [self decrementNetworkCounter];

            [self fetchChannels];

            break;
        case STVParserModeChannels:
           LOG(@"CHANNEL array found: %@", array);
           [self storeChannelsWithArray: array];
           NSArray *channels = [self retrieveChannels];
        self.channel = [self getPublicChannel: 0 fromArray: channels];
           if (self.channel) {
               [self loginComplete];
           } else {
               [NSException raise:@"unexpected" format:@"Couldn't Save channel!"];
           }
           break;
        case STVParserModeBroadcasts:
            // For some reason, the compiler requires a log statement just after the 'case' statemnet.
           LOG(@"woohoo");
           [self storeBroadcastsWithArray: array channel: self.channel];
           //NSArray *broadcasts = [self retrieveBroadcastsForChannel: self.channel];
           NSArray *broadcasts = array;
           NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
               broadcasts, @"broadcasts",
               nil];
           [[NSNotificationCenter defaultCenter] postNotificationName: @"ReceivedBroadcasts"
                                                               object: self
                                                             userInfo: userInfo];
           break;
        default:
            [NSException raise:@"unexpected" format:@"Invalid parser mode!"];

    }
    _parserMode = STVParserModeIdle;
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
    switch (_parserMode) {
        case STVParserModeBroadcasts:
            LOG(@"YAhoo");
            NSString *error = [dict objectForKey: @"err"];
            if (error) {
                [NSException raise:@"unexpected" format:@"User not logged in!. Error: %@", error];
            } else {
                [NSException raise:@"unexpected" format:@"Should not get here"];
            }
            break;
        case STVParserModeUser:
            LOG(@"USER object found: %@", dict);
            break;
        default:
            [NSException raise:@"unexpected" format:@"Invalid parser mode!"];
    }
    _parserMode = STVParserModeIdle;
}

- (void)dealloc {
    [super dealloc];
}

@end

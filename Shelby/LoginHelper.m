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

#import "NSURLConnection+AsyncBlock.h"
#import "NSString+URLEncoding.h"
#import "OAuthMutableURLRequest.h"

#define kAppName @"Shelby.tv iOS"
#define kProviderName @"shelby.tv"

#define kUserIdName @"user_id"
#define kChannelIdName @"channel_id"
#define kRequestTokenName @"request"
#define kAccessTokenName @"access"
#define kAccessTokenSecretName @"access_secret"

#define kShelbyConsumerKey		@"RXbwSMUr8l810IwUz64fcHGsww2ZZXRItCbmNgmv"
#define kShelbyConsumerSecret		@"UaH7vX7e695nmEfgtLpPQVLeHZTOdBgnox0XfYfn"

#define kShelbyRequestToken	@"XNMyurKpFC8NIvGez5IgJzMuy78HhzmgoZ2gCW8B"
#define kShelbyRequestTokenSecret		@"eZB8bcVcNudzBYMORHUfsvzQtdxf3ylMbCvyjCLf"

#define kRequestTokenUrl      @"http://dev.shelby.tv/oauth/request_token"
#define kUserAuthorizationUrl @"http://dev.shelby.tv/oauth/authorize"
#define kAccessTokenUrl       @"http://dev.shelby.tv/oauth/access_token"

#define kFetchUserUrl         @"http://api.shelby.tv/v2/users.json"
#define kFetchChannelsUrl     @"http://api.shelby.tv/v2/channels.json"
#define kFetchBroadcastUrl    @"http://api.shelby.tv/v2/broadcasts/%@.json"
#define kFetchBroadcastsUrl   @"http://api.shelby.tv/v2/channels/%@/broadcasts.json"

#define kCallbackUrl       @"shelby://ios.shelby.tv"


@interface LoginHelper ()

#pragma mark - Persistence
- (void)loadTokens;
- (void)storeTokens;
- (void)clearTokens;

- (BOOL)fetchUserId;
- (User *)retrieveUser;
- (NSArray *)retrieveChannels;
- (Channel *)getPublicChannel:(NSInteger)public fromArray:(NSArray *)channels;

@end

@implementation LoginHelper

@synthesize delegate;

@synthesize accessToken;
@synthesize accessTokenSecret;
@synthesize user = _user;
@synthesize channel = _channel;


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
        parser = [[SBJsonStreamParser alloc] init];
        parser.delegate = self;
        parser.supportMultipleDocuments = YES;
        [self loadTokens];
    }

    return self;
}

#pragma mark - Settings

- (void)changeChannel:(NSInteger)newChannel {
    // Change the channel.
    self.channel = [self getPublicChannel: newChannel fromArray: [self retrieveChannels]];
}

#pragma mark - Token Storage

- (BOOL)loggedIn {
    // If we have stored both the accessToken and the secret, we're logged in.
    return (self.accessToken && self.accessTokenSecret && self.user && self.channel);
}

- (NSString *)consumerTokenSecret {
    return kShelbyConsumerSecret;
}

- (NSString *)consumerToken {
    return kShelbyConsumerKey;
}

- (void)loadTokens {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [defaults stringForKey: kAccessTokenName];
    self.accessTokenSecret = [defaults stringForKey: kAccessTokenSecretName];
    self.user = [self retrieveUser];
    self.channel = [self getPublicChannel: 0 fromArray: [self retrieveChannels]];
}

- (void)logout {
    [self clearTokens];
    //DEBUG ONLY!
    //[[NSThread mainThread] exit];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"LoginHelperLoggedOut"
                                                        object: self
                                                        ];
}

/**
 * For now, we're using NSUserDefaults. However, this is insecure.
 * We should move to the keychain in the future.
 */
- (void)storeTokens {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: self.accessToken
                 forKey: kAccessTokenName];
    [defaults setObject: self.accessTokenSecret
                 forKey: kAccessTokenSecretName];
    [defaults synchronize];
}

- (void)clearTokens {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey: kAccessTokenName];
    [defaults removeObjectForKey: kAccessTokenSecretName];
    [defaults synchronize];
}

#pragma mark - Load Old Credentials

- (OAuthMutableURLRequest *) requestForURL: (NSURL *) url withMethod: (NSString *) method;
{
    OAuthMutableURLRequest *request = [[[OAuthMutableURLRequest alloc] initWithURL: url] autorelease];

    [request setConsumerKey: self.consumerToken secret: self.consumerTokenSecret];
    if (self.accessToken != nil) [request setToken: self.accessToken secret: self.accessTokenSecret];

    [request setHTTPMethod: method];

    return request;
}

#pragma mark - Request Token

- (void)getRequestToken {
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
}

#pragma mark - User Authorization

- (void)handshake:(OAuthHandshake *)handshake requestsUserToAuthenticateToken:(NSString *)token;
{
    NSString *targetURL = [NSString stringWithFormat: @"%@?oauth_token=%@",
             kUserAuthorizationUrl,
             [token URLEncodedString]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: targetURL]];
}

- (void)verifierReturnedFromAuth:(NSString *)verifier {
    [handshake continueHandshakeWithVerifier: verifier];
}

#pragma mark - Access Token

- (void)handshake:(OAuthHandshake *)handshake authenticatedToken:(NSString *)token withSecret:(NSString *)tokenSecret;
{
    NSLog(@"Authenticated token! %@ : %@", token, tokenSecret);

    // Store token for later use.
    self.accessToken = token;
    self.accessTokenSecret = tokenSecret;
    [self storeTokens];

    [[NSNotificationCenter defaultCenter] postNotificationName: @"LoginHelperAuthorizedAccessToken"
                                                        object: self
                                                        ];

    [self fetchUserId];
}

#pragma mark - User Id

- (BOOL)fetchUserId
{
    NSURL *url = [NSURL URLWithString: kFetchUserUrl];
    OAuthMutableURLRequest *req = [self requestForURL:url withMethod:@"GET"];

    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];

        [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetUserResponse:data:error:forRequest:)];
        return YES;
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetUserResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request
{
    NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"Got user: %@", string);

    _parserMode = STVParserModeUser;
    SBJsonStreamParserStatus status = [parser parse: data];
    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"User Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"User JSON Parsing error! %@", parser.error];
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
    return [[NSURLConnection sendSynchronousRequest:request
                                  returningResponse:&response
                                              error:&error] retain];
}

- (User *)storeUserWithDictionary:(NSDictionary *)dict
                    withImageData:(NSData *)imageData
{
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:_context];
    [user setValue:[dict objectForKey:@"name"]  forKey:@"name"];
    [user setValue:[dict objectForKey:@"nickname"]  forKey:@"nickname"];
    [user setValue:[dict objectForKey:@"user_image"]  forKey:@"imageUrl"];
    [user setValue:[dict objectForKey:@"_id"]  forKey:@"shelbyId"];
    [user setValue:imageData forKey:@"image"];
    
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
    return user;
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
        User *user = [objects objectAtIndex: 0];
        return user;
    } else {
        return nil;
    }
}

#pragma mark - Channels

- (Channel *)getPublicChannel:(NSInteger)public fromArray:(NSArray *)channels
{
    for (Channel *channel in channels) {
        if ([channel.public integerValue] == public) {
            return channel;
            break;
        }
    }
    return nil;
}

- (BOOL)fetchChannels
{
    NSURL *url = [NSURL URLWithString: kFetchChannelsUrl];
    OAuthMutableURLRequest *req = [self requestForURL:url withMethod:@"GET"];

    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];

        [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetChannelsResponse:data:error:forRequest:)];
        return YES;
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetChannelsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
    NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"Got channels: %@", string);

    _parserMode = STVParserModeChannels;
    SBJsonStreamParserStatus status = [parser parse: data];

    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"Channels Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"Channels JSON Parsing error! %@", parser.error];
    }
}

- (void)storeChannelsWithArray:(NSArray *)array user:(User *)user {
    for (NSDictionary *dict in array) {
        LOG(@"Channel dict: %@", dict);
        Channel *channel = [NSEntityDescription
          insertNewObjectForEntityForName:@"Channel"
                   inManagedObjectContext:_context];
        NSNumber *public = [dict objectForKey:@"public"];
        [channel setValue: public forKey:@"public"];
        NSString *name = [dict objectForKey:@"name"];
        [channel setValue: name forKey:@"name"];
        NSString *shelbyId = [dict objectForKey:@"_id"];
        [channel setValue: shelbyId forKey:@"shelbyId"];
        if (user) channel.user = user;
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
               [NSString stringWithFormat: kFetchBroadcastsUrl, self.channel.shelbyId]];
        LOG(@"Fetching broadcasts from: %@", url);

        //OAuthMutableURLRequest *req = [handshake requestForURL:url withMethod:@"GET"];
        OAuthMutableURLRequest *req = [self requestForURL:url withMethod:@"GET"];

        if (req) {
            // Set to plaintext on request because oAuth library is broken.
            [req signPlaintext];

            [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetBroadcastsResponse:data:error:forRequest:)];
            return YES;
        }
    }
    // We failed to send the request. Let the caller know.
    return NO;
}

- (void)receivedGetBroadcastsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
    NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"Got broadcasts: %@", string);

    _parserMode = STVParserModeBroadcasts;
    SBJsonStreamParserStatus status = [parser parse: data];
    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"Broadcasts Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"Broadcasts JSON Parsing error!"];
    }
}

- (void)storeBroadcastsWithArray:(NSArray *)array channel:(Channel *)channel {
    for (NSDictionary *dict in array) {
        LOG(@"Broadcast dict: %@", dict);
        Broadcast *broadcast = [NSEntityDescription
          insertNewObjectForEntityForName:@"Broadcast"
                   inManagedObjectContext:_context];

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

        //"liked_by_owner": true,
        //"liked_by_user": null,
        NSString *liked = [dict objectForKey: @"liked_by_user"];
        if (NOTNULL(liked)) {
            if ([liked isEqualToString: @"true"]) {
                broadcast.liked = YES;
            }
        }

        //NSString *youtubeDescription  = [broadcast objectForKey: @"video_description"];
        //Description - tweet
        //video_description - youtube description
        //video_title - youtube title

        if (channel) broadcast.channel = channel;
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

- (NSArray *)retrieveBroadcastsForChannel:(Channel *)channel {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
        entityForName:@"Broadcast" inManagedObjectContext: _context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
        @"(channel == %@)", channel];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *broadcasts = [_context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if ([broadcasts count] > 0) {
        return broadcasts;
    } else {
        LOG(@"Found no broadcasts for channel: %@. Error: %@", channel, error);
        return nil;
    }
}

#pragma mark - Login Complete

- (void)loginComplete
{
    [self storeTokens];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"LoginHelperLoginComplete"
                                                        object: self
                                                        ];
}

#pragma mark SBJsonStreamParserDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    // Pass the data to VideoTableData.

    switch (_parserMode) {
        case STVParserModeUser:
            LOG(@"USER Array found: %@", array);

            NSDictionary *dict = [array objectAtIndex: 0];
            self.user = [self storeUserWithDictionary:dict withImageData:[self fetchUserImageDataWithDictionary:dict]];

            [self storeTokens];
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
           [[NSNotificationCenter defaultCenter] postNotificationName: @"LoginHelperReceivedBroadcasts"
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

@end

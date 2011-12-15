//
//  LoginHelper.m
//  Shelby
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginHelper.h"
#import "User.h"
#import "Channel.h"
#import "Broadcast.h"
#import "SharerImage.h"
#import "ThumbnailImage.h"

#import "ShelbyAppDelegate.h"
#import "ShelbyApp.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "Video.h"

#import "NSURLConnection+AsyncBlock.h"
#import "NSString+URLEncoding.h"
#import "ApiMutableURLRequest.h"

#import "ApiConstants.h"
#import "ApiHelper.h"
#import "CoreDataHelper.h"

#import "GraphiteStats.h"
#import "SessionStats.h"

@interface LoginHelper ()

@property (nonatomic, readwrite, retain) User *user;
@property (readwrite) NSInteger networkCounter;
@property (nonatomic, retain) Channel *channel;
@property (nonatomic, retain) NSString *identityProvider;

- (BOOL)fetchUserId;
- (void)deleteUser;
- (NSArray *)retrieveChannels;
- (Channel *)getPublicChannel:(NSInteger)public fromArray:(NSArray *)channels;

@end

@implementation LoginHelper

@synthesize networkCounter;
@synthesize user;
@synthesize channel;
@synthesize identityProvider;
@synthesize lastFetchBroadcasts;

- (User *)retrieveUser
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:_context]];
    
    NSError *error;
    NSArray *objects = [_context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    return ([objects count] > 0) ? [objects objectAtIndex:0] : nil;
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        _context = [context retain];
        [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        _parser = [[SBJsonStreamParser alloc] init];
        _parser.delegate = self;
        _parser.supportMultipleDocuments = YES;
        self.user = [self retrieveUser];
        self.channel = [self getPublicChannel:0 fromArray:[self retrieveChannels]];
    }

    return self;
}

#pragma mark - Network Activity

- (void)incrementNetworkCounter
{
    @synchronized(self) { self.networkCounter++; }
}

- (void)decrementNetworkCounter
{
    @synchronized(self) { self.networkCounter--; }
}

#pragma mark - Login & Logout

- (BOOL)loggedIn
{
    // If we have stored both the accessToken and the secret, we're logged in.
    return ([ShelbyApp sharedApp].apiHelper.accessToken &&
            [ShelbyApp sharedApp].apiHelper.accessTokenSecret &&
            self.user &&
            self.channel);
}


- (void)logout
{
    [GraphiteStats incrementCounter:@"userLoggedOut"];

    [[ShelbyApp sharedApp].apiHelper clearTokens];
    self.user = nil;
    [self deleteUser];
    [SessionStats resetHeartbeatCount];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggedOut"
                                                        object:self
                                                        ];
}

#pragma mark - Request Token

- (void)getRequestTokenWithProvider:(NSString *)provider
{
    self.identityProvider = provider;

    handshake = [[OAuthHandshake alloc] init];
    [handshake setTokenRequestURL:[NSURL URLWithString:kRequestTokenUrl]];
    [handshake setTokenAuthURL:[NSURL URLWithString:kAccessTokenUrl]];
    [handshake setCallbackURL:kCallbackUrl];
    [handshake setDelegate:self];

    NSString *consumerKey = kShelbyConsumerKey;
    NSString *consumerSecret = kShelbyConsumerSecret;

    [handshake setConsumerKey:consumerKey];
    [handshake setConsumerSecret:consumerSecret];

    [self incrementNetworkCounter];
    [handshake beginHandshake];
}

#pragma mark - User Authorization

- (void)handshake:(OAuthHandshake *)handshake requestsUserToAuthenticateToken:(NSString *)token
{
    NSString *targetURL = [kUserAuthorizationUrl stringByAppendingFormat: @"?oauth_token=%@", [token URLEncodedString]];
    
    if (self.identityProvider) {
        targetURL = [targetURL stringByAppendingFormat: @"&provider=%@", self.identityProvider];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginURLAvailable"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSURL URLWithString:targetURL], @"url", nil]];
    
    [self decrementNetworkCounter];
}

- (void)handshake:(OAuthHandshake *)handshake failedWithError:(NSError *) error
{
    NSLog(@"OAuth request failed with an error: %@", [error localizedDescription]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OAuthHandshakeFailed" object:self];
    
    [self decrementNetworkCounter];
}

- (void)verifierReturnedFromAuth:(NSString *)verifier
{
    [self incrementNetworkCounter];
    [handshake continueHandshakeWithVerifier:verifier];
}

#pragma mark - Access Token

- (void)handshake:(OAuthHandshake *)handshake authenticatedToken:(NSString *)token withSecret:(NSString *)tokenSecret;
{
    [self decrementNetworkCounter];
    LOG(@"Authenticated token! %@ : %@", token, tokenSecret);

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

    _parserMode = ParserModeUser;
    SBJsonStreamParserStatus status = [_parser parse: data];
    
    // might need to check status and NOT_NULL(self.user). if data is blank, we seem to think that's a success case.
    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"User Parsing Complete!");
    } else {
        [self logout];
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

- (void)deleteEntityType:(NSString *)entityName
{
    NSFetchRequest *allEntities = [[NSFetchRequest alloc] init];
    [allEntities setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:_context]];
    [allEntities setIncludesPropertyValues:NO]; //only fetch the managedObjectID

    NSError *error;
    NSArray *entities = [_context executeFetchRequest:allEntities error:&error];
    [allEntities release];

    for (NSManagedObject *entity in entities) {
        [_context deleteObject:entity];
    }
}

- (void)deleteUser
{
    [self deleteEntityType:@"User"];
    [self deleteEntityType:@"Channel"];
    [self deleteEntityType:@"Broadcast"];
    [self deleteEntityType:@"ThumbnailImage"];
    [self deleteEntityType:@"SharerImage"];

    NSError *error = nil;
    [_context save:&error];
    if (error) {
        NSLog(@"Error saving User/Channel/Broadcast deletions: %@", error);
    }
}

- (User *)storeUserWithDictionary:(NSDictionary *)dict
                    withImageData:(NSData *)imageData
{
    User *upsert = [CoreDataHelper fetchExistingUniqueEntity:@"User" withShelbyId:[dict objectForKey:@"_id"] inContext:_context];
    
    if (NULL == upsert) {
        upsert = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:_context];
    }
    [upsert setValue:[dict objectForKey:@"name"]  forKey:@"name"];
    [upsert setValue:[dict objectForKey:@"nickname"]  forKey:@"nickname"];
    [upsert setValue:[dict objectForKey:@"user_image"]  forKey:@"imageUrl"];
    [upsert setValue:[dict objectForKey:@"_id"]  forKey:@"shelbyId"];
    [upsert setValue:imageData forKey:@"image"];

    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
    return upsert;
}


#pragma mark - Authentications

- (void)fetchAuthentications
{
    NSURL *url = [NSURL URLWithString: kAuthenticationsUrl];
    OAuthMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];

    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];

        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedGetAuthenticationsResponse:data:error:forRequest:)];
        [self incrementNetworkCounter];

    }
}

- (void)storeAuthentications:(NSArray *)authentications
{
    for (NSString *authentication in authentications) {
        if ([authentication isEqualToString: @"twitter"]) {
            self.user.auth_twitter = [NSNumber numberWithBool:YES];
        }
        if ([authentication isEqualToString: @"facebook"]) {
            self.user.auth_facebook = [NSNumber numberWithBool:YES];
        }
        if ([authentication isEqualToString: @"tumblr"]) {
            self.user.auth_tumblr = [NSNumber numberWithBool:YES];
        }
    }
}

- (void)receivedGetAuthenticationsResponse:(NSURLResponse *)resp 
                                      data:(NSData *)data 
                                     error:(NSError *)error 
                                forRequest:(NSURLRequest *)request
{
    [self decrementNetworkCounter];
    LOG(@"Got authentications: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);

    // Parse into JSON
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *array = [parser objectWithData: data];
    if (parser.error) {
        NSLog(@"Broadcast Parser error: %@", parser.error);
    } else {
        [self storeAuthentications: array];
    }
    [parser release];
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

- (void)fetchChannels
{
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:[NSURL URLWithString:kChannelsUrl] 
                                                                    withMethod:@"GET"];
    // Set to plaintext on request because oAuth library is broken.
    [req signPlaintext];
    
    [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetChannelsResponse:data:error:forRequest:)];
    
    [self incrementNetworkCounter];
}

- (void)receivedGetChannelsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
    [self decrementNetworkCounter];
    LOG(@"Got channels: %@", [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease]);

    _parserMode = ParserModeChannels;
    SBJsonStreamParserStatus status = [_parser parse: data];

    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"Channels Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"Channels JSON Parsing error! %@", _parser.error];
    }
}

- (void)storePrivateChannelsWithArray:(NSArray *)array user:(User *)newUser
{
    for (NSDictionary *dict in array) {
        LOG(@"Channel dict: %@", dict);
        if ([(NSNumber *)[dict objectForKey:@"public"] intValue] == 0) {

            Channel *upsert = [CoreDataHelper fetchExistingUniqueEntity:@"Channel" withShelbyId:[dict objectForKey:@"_id"] inContext:_context];
            
            if (NULL == upsert) {
                upsert = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Channel"
                                   inManagedObjectContext:_context];
            }
            NSNumber *public = [dict objectForKey:@"public"];
            [upsert setValue: public forKey:@"public"];
            NSString *name = [dict objectForKey:@"name"];
            [upsert setValue: name forKey:@"name"];
            NSString *shelbyId = [dict objectForKey:@"_id"];
            [upsert setValue: shelbyId forKey:@"shelbyId"];
            if (newUser) upsert.user = newUser;
        }
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

- (void)storePrivateChannelsWithArray:(NSArray *)array
{
    [self storePrivateChannelsWithArray:array user:self.user];
}

- (NSArray *)retrieveChannels
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Channel" 
                                        inManagedObjectContext: _context]];
    
    NSError *error;
    NSArray *channels = [_context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    return ([channels count] > 0) ? channels : nil;
}

#pragma mark - Broadcasts

- (void)fetchBroadcasts
{
    if (IS_NULL(self.user)) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: kBroadcastsUrl, self.channel.shelbyId]];
    LOG(@"Fetching broadcasts from: %@", url);
    
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    
    // Set to plaintext on request because oAuth library is broken.
    [req signPlaintext];
    
    [self incrementNetworkCounter];
    
    [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetBroadcastsResponse:data:error:forRequest:)];
    self.lastFetchBroadcasts = [NSDate date];
}

- (void)receivedGetBroadcastsResponse:(NSURLResponse *)resp 
                                 data:(NSData *)data 
                                error:(NSError *)error 
                           forRequest:(NSURLRequest *)request
{
    LOG(@"Received fetchBroadcasts response!");

    [self decrementNetworkCounter];
    
    _parserMode = ParserModeBroadcasts;
    SBJsonStreamParserStatus status = [_parser parse: data];
    
    if (status == SBJsonStreamParserWaitingForData) {
        LOG(@"Broadcasts Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"Broadcasts JSON Parsing error!"];
    }
}

- (void)storeBroadcastVideo:(Video *)video 
        withSharerImageData:(NSData *)sharerImageData 
                  inContext:(NSManagedObjectContext *)context
{
    Broadcast *update = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast" withShelbyId:video.shelbyId inContext:context];
    
    if (NULL == update ) 
    {
        NSLog(@"Couldn't find CoreData entry for video %@; aborting store of sharerImageData", video.shelbyId);
        return;
    }
    
    if (IS_NULL(update.sharerImage)) {
        update.sharerImage = [NSEntityDescription
                              insertNewObjectForEntityForName:@"SharerImage"
                              inManagedObjectContext:context];
    }
    
    update.sharerImage.imageData = sharerImageData;
    
    NSError *error;
    if (![context save:&error]) {
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


- (void)storeBroadcastVideo:(Video *)video 
          withThumbnailData:(NSData *)thumbnailData 
                  inContext:(NSManagedObjectContext *)context
{
    Broadcast *update = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast" withShelbyId:video.shelbyId inContext:context];
    
    if (NULL == update ) 
    {
        NSLog(@"Couldn't find CoreData entry for video %@; aborting store of thumbnailData", video.shelbyId);
        return;
    }
    
    if (IS_NULL(update.thumbnailImage)) {
        update.thumbnailImage = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"ThumbnailImage"
                                 inManagedObjectContext:context];
    }
        
    update.thumbnailImage.imageData = thumbnailData;
        
    NSError *error;
    if (![context save:&error]) {
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

- (NSArray *)retrieveBroadcastsForChannel:(Channel *)c 
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Broadcast" 
                                        inManagedObjectContext:_context]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(channel == %@)", c]];
    
    NSError *error;
    NSArray *broadcasts = [_context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    return ([broadcasts count] > 0) ? broadcasts : nil;
}

#pragma mark - Login Complete

- (void)loginComplete
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggedIn"
                                                        object:self];
}

#pragma mark - SBJsonStreamParserDelegate methods

- (void)parser:(SBJsonStreamParser *)parser 
    foundArray:(NSArray *)array
{
    switch (_parserMode) {
            
        case ParserModeUser:;
            
            NSDictionary *dict = [array objectAtIndex: 0];
            [self incrementNetworkCounter];
            self.user = [self storeUserWithDictionary:dict withImageData:[self fetchUserImageDataWithDictionary:dict]];
            [self decrementNetworkCounter];
            
            [self fetchAuthentications];
            [self fetchChannels];
            
            break;
        
        case ParserModeChannels:;
            
            [self storePrivateChannelsWithArray: array];
            NSArray *channels = [self retrieveChannels];
            self.channel = [self getPublicChannel:0 fromArray:channels];
            
            if (self.channel) {
                [self loginComplete];
            } else {
                [NSException raise:@"unexpected" format:@"Couldn't Save channel!"];
            }
            
            break;
            
        case ParserModeBroadcasts:;
           
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedBroadcasts" 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:array, @"jsonDictionariesArray", 
                                                                                                                  nil]];
            
            break;
            
        default:;
            
            [NSException raise:@"unexpected" format:@"Invalid parser mode!"];
    }
    
    _parserMode = ParserModeIdle;
}

- (void)parser:(SBJsonStreamParser *)parser
   foundObject:(NSDictionary *)dict
{
    [NSException raise:@"Unxpected JSON response" format:@"Received JSON object instead of array!"];
}

#pragma mark - Dealloc

- (void)dealloc
{
    self.lastFetchBroadcasts =  nil;
    self.user = nil;
    
    [super dealloc];
}

@end

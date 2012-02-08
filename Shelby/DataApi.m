//
//  DataApi.m
//  Shelby
//
//  Created by Mark Johnson on 2/7/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "DataApi.h"
#import "ShelbyApp.h"
#import "ApiMutableURLRequest.h"
#import "ApiConstants.h"
#import "ApiHelper.h"
#import "NSURLConnection+AsyncBlock.h"
#import "User.h"
#import "Channel.h"
#import "CoreDataHelper.h"
#import "SBJsonParser.h"
#import "UserSessionHelper.h"

@implementation DataApi

@synthesize lastFetchBroadcasts;

- (id)init
{
    self = [super init];
    if (self) {
        
        _parser = [[SBJsonStreamParser alloc] init];
        _parser.delegate = self;
        _parser.supportMultipleDocuments = YES;
        
    }
    return self;
}

#pragma mark - User Id

- (void)fetchUserId
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString: kUserUrl];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    
    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];
        
        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedGetUserResponse:data:error:forRequest:)];
        [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
    }
}

- (void)receivedGetUserResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request
{
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
    NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"Got user: %@", string);
    
    _parserMode = ParserModeUser;
    SBJsonStreamParserStatus status = [_parser parse: data];
    
    // might need to check status and NOT_NULL(self.user). if data is blank, we seem to think that's a success case.
    if (status == SBJsonStreamParserWaitingForData) {
        // Woot. Good to go!
        LOG(@"User Parsing Complete!");
    } else {
        [[ShelbyApp sharedApp].userSessionHelper logout];
    }
}

- (NSData *)fetchUserImageDataWithDictionary:(NSDictionary *)dict
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return NULL;
    }
    
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
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    
    User *upsert = [CoreDataHelper fetchExistingUniqueEntity:@"User" withShelbyId:[dict objectForKey:@"_id"] inContext:context];
    
    if (NULL == upsert) {
        upsert = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:context];
    }
    [upsert setValue:[dict objectForKey:@"name"]  forKey:@"name"];
    [upsert setValue:[dict objectForKey:@"nickname"]  forKey:@"nickname"];
    [upsert setValue:[dict objectForKey:@"user_image"]  forKey:@"imageUrl"];
    [upsert setValue:[dict objectForKey:@"_id"]  forKey:@"shelbyId"];
    [upsert setValue:imageData forKey:@"image"];
    
    [CoreDataHelper saveAndReleaseContext:context];
    return upsert;
}


#pragma mark - Authentications

- (void)fetchCurrentUserAuthentications
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString: kAuthenticationsUrl];
    OAuthMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    
    if (req) {
        // Set to plaintext on request because oAuth library is broken.
        [req signPlaintext];
        
        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedGetAuthenticationsResponse:data:error:forRequest:)];
        [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
        
    }
}

- (void)storeAuthentications:(NSArray *)authentications
{
    for (NSString *authentication in authentications) {
        if ([authentication isEqualToString: @"twitter"]) {
            [ShelbyApp sharedApp].userSessionHelper.currentUser.auth_twitter = [NSNumber numberWithBool:YES];
        }
        if ([authentication isEqualToString: @"facebook"]) {
            [ShelbyApp sharedApp].userSessionHelper.currentUser.auth_facebook = [NSNumber numberWithBool:YES];
        }
        if ([authentication isEqualToString: @"tumblr"]) {
            [ShelbyApp sharedApp].userSessionHelper.currentUser.auth_tumblr = [NSNumber numberWithBool:YES];
        }
    }
}

- (void)receivedGetAuthenticationsResponse:(NSURLResponse *)resp 
                                      data:(NSData *)data 
                                     error:(NSError *)error 
                                forRequest:(NSURLRequest *)request
{
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
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
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:[NSURL URLWithString:kChannelsUrl] 
                                                                    withMethod:@"GET"];
    // Set to plaintext on request because oAuth library is broken.
    [req signPlaintext];
    
    [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetChannelsResponse:data:error:forRequest:)];
    
    [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
}

- (void)receivedGetChannelsResponse: (NSURLResponse *) resp data: (NSData *)data error: (NSError *)error forRequest: (NSURLRequest *)request;
{
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
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
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    
    for (NSDictionary *dict in array) {
        LOG(@"Channel dict: %@", dict);
        if ([(NSNumber *)[dict objectForKey:@"public"] intValue] == 0) {
            
            Channel *upsert = [CoreDataHelper fetchExistingUniqueEntity:@"Channel" withShelbyId:[dict objectForKey:@"_id"] inContext:context];
            
            if (NULL == upsert) {
                upsert = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Channel"
                          inManagedObjectContext:context];
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
    
    [CoreDataHelper saveAndReleaseContext:context];
}

- (void)storePrivateChannelsWithArray:(NSArray *)array
{
    [self storePrivateChannelsWithArray:array user:[ShelbyApp sharedApp].userSessionHelper.currentUser];
}

#pragma mark - Broadcasts

- (void)fetchBroadcasts
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedBroadcasts" 
                                                            object:self 
                                                          userInfo:nil];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: kBroadcastsUrl, [ShelbyApp sharedApp].userSessionHelper.currentUserPublicChannel.shelbyId]];
    LOG(@"Fetching broadcasts from: %@", url);
    
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    
    // Set to plaintext on request because oAuth library is broken.
    [req signPlaintext];
    
    [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
    
    [NSURLConnection sendAsyncRequest: req delegate: self completionSelector: @selector(receivedGetBroadcastsResponse:data:error:forRequest:)];
    self.lastFetchBroadcasts = [NSDate date];
}

- (void)receivedGetBroadcastsResponse:(NSURLResponse *)resp 
                                 data:(NSData *)data 
                                error:(NSError *)error 
                           forRequest:(NSURLRequest *)request
{
    LOG(@"Received fetchBroadcasts response!");
    
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
    
    _parserMode = ParserModeBroadcasts;
    SBJsonStreamParserStatus status = [_parser parse: data];
    
    if (status == SBJsonStreamParserWaitingForData) {
        LOG(@"Broadcasts Parsing Complete!");
    } else {
        [NSException raise:@"unexpected" format:@"Broadcasts JSON Parsing error!"];
    }
}

#pragma mark - SBJsonStreamParserDelegate methods

- (void)parser:(SBJsonStreamParser *)parser 
    foundArray:(NSArray *)array
{
    switch (_parserMode) {
            
        case ParserModeUser:;
            
            NSDictionary *dict = [array objectAtIndex: 0];
            [self storeUserWithDictionary:dict withImageData:[self fetchUserImageDataWithDictionary:dict]];
            
            [[ShelbyApp sharedApp].userSessionHelper setCurrentUserFromCoreData];
                        
            [self fetchCurrentUserAuthentications];
            [self fetchChannels];
            
            break;
            
        case ParserModeChannels:;
            
            [self storePrivateChannelsWithArray: array];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggedIn"
                                                                object:self];

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

@end

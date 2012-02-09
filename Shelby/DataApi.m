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
#import "Broadcast.h"

@implementation DataApi

#pragma mark - Helper Methods

+ (void)makeRequest:(ApiMutableURLRequest *)request
withProcessResponseSelector:(SEL)processResponseSelector
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }

    [request signPlaintext];
    [request setUserInfoDict:[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:processResponseSelector], @"processResponseSelector", nil]];
    
    [NSURLConnection sendAsyncRequest:request delegate:self completionSelector:@selector(receivedResponse:data:error:forRequest:)];
    
    [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
}

+ (void)receivedResponse:(NSURLResponse *)resp
                    data:(NSData *)data
                   error:(NSError *)error
              forRequest:(NSURLRequest *)request
{    
    if (NOT_NULL(error)) {
        [NSException raise:@"unexpected" format:@"Data API request error! error: %@", error];
    } else {
        SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
        id value = [parser objectWithData:data];
        
        // we expect arrays for all DataApi requests -- if we get a Dictionary back, it means we had an error
        if ([value isKindOfClass:[NSDictionary class]]) 
        {
            NSString *apiError = [(NSDictionary *)value objectForKey:@"err"];
            [NSException raise:@"unexpected" format:@"Data API error! error: %@", apiError];
        
        } else { // isKindOfClass:[NSArray class]
        
            SEL processReponseSelector = [[((ApiMutableURLRequest *)request).userInfoDict  objectForKey:@"processResponseSelector"] pointerValue];
            [[DataApi class] performSelector:processReponseSelector withObject:value];
        }
    }
    
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
}

/*
 * User Session Data
 *
 * A chain of async data calls and callbacks fetches and stores the user, user authentication,
 * and channel data in CoreData and appropriate in-memory data structures and notifies on
 * successful completion.
 */

#pragma mark - User Session Data
#pragma mark - User ID

+ (void)fetchAndStoreUserSessionData
{
    NSLog(@"Entering fetchAndStoreUserSessionData");
    
    NSURL *url = [NSURL URLWithString: kUserUrl];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    [DataApi makeRequest:req withProcessResponseSelector:@selector(processGetUserResponse:)];
}

+ (void)downloadUserImageAndStoreUserWithDictionary:(NSDictionary *)dict
{
    NSLog(@"Entering downloadUserImageAndStoreUserWithDictionary");
    
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    User *upsert = [CoreDataHelper fetchExistingUniqueEntity:@"User" withShelbyId:[dict objectForKey:@"_id"] inContext:context];
    
    if (IS_NULL(upsert)) {
        upsert = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:context];
    }

    [upsert populateFromApiJSONDictionary:dict];

    NSURL *url = [[[NSURL alloc] initWithString:upsert.imageUrl] autorelease];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    upsert.image = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];;
    
    [CoreDataHelper saveAndReleaseContext:context];
}

+ (void)processGetUserResponse:(NSArray *)array
{
    NSLog(@"Entering processGetUserResponse");

    // get User all squared away
    [DataApi downloadUserImageAndStoreUserWithDictionary:[array objectAtIndex: 0]];
    [[ShelbyApp sharedApp].userSessionHelper setCurrentUserFromCoreData];
    
    // fire off the next step
    [DataApi fetchCurrentUserAuthentications];
}

#pragma mark Authentications

+ (void)fetchCurrentUserAuthentications
{
    NSLog(@"Entering fetchCurrentUserAuthentications");
    
    NSURL *url = [NSURL URLWithString: kAuthenticationsUrl];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    [DataApi makeRequest:req withProcessResponseSelector:@selector(processGetAuthenticationsResponse:)];
}

+ (void)processGetAuthenticationsResponse:(NSArray *)array
{
    for (NSString *authentication in array) {
        if ([authentication isEqualToString: @"twitter"]) {
            [ShelbyApp sharedApp].userSessionHelper.currentUser.auth_twitter = [NSNumber numberWithBool:YES];
        } else if ([authentication isEqualToString: @"facebook"]) {
            [ShelbyApp sharedApp].userSessionHelper.currentUser.auth_facebook = [NSNumber numberWithBool:YES];
        } else if ([authentication isEqualToString: @"tumblr"]) {
            [ShelbyApp sharedApp].userSessionHelper.currentUser.auth_tumblr = [NSNumber numberWithBool:YES];
        }
    }

    // fire off the next step
    [DataApi fetchChannels];
}

#pragma mark Channels

+ (void)fetchChannels
{
    NSURL *url = [NSURL URLWithString:kChannelsUrl] ;
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    [DataApi makeRequest:req withProcessResponseSelector:@selector(processGetChannelsResponse:)];
}

+ (void)processGetChannelsResponse:(NSArray *)array
{
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    
    for (NSDictionary *dict in array) {
        if ([(NSNumber *)[dict objectForKey:@"public"] intValue] != 0) {
            continue;
        }
            
        Channel *upsert = [CoreDataHelper fetchExistingUniqueEntity:@"Channel" withShelbyId:[dict objectForKey:@"_id"] inContext:context];
        
        if (NULL == upsert) {
            upsert = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Channel"
                      inManagedObjectContext:context];
        }
        
        [upsert populateFromApiJSONDictionary:dict];
        upsert.user = [CoreDataHelper fetchUserFromCoreDataContext:context];
    }
    
    [CoreDataHelper saveAndReleaseContext:context];
    
    [[ShelbyApp sharedApp].userSessionHelper setCurrentUserPublicChannelFromCoreData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggedIn" object:[DataApi class]];
}

#pragma mark - Broadcasts

+ (void)fetchBroadcastsAndStoreInCoreData
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: kBroadcastsUrl, [ShelbyApp sharedApp].userSessionHelper.currentUserPublicChannel.shelbyId]];    
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    [DataApi makeRequest:req withProcessResponseSelector:@selector(processGetBroadcastsResponseAndStoreInCoreData:)];
}

+ (void)processGetBroadcastsResponseAndStoreInCoreData:(NSArray *)array
{
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    
    for (NSDictionary *dict in array)
    {
        Broadcast *upsert = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast" withShelbyId:[dict objectForKey:@"_id"] inContext:context];
        
        if (IS_NULL(upsert)) {
            upsert = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Broadcast"
                      inManagedObjectContext:context];
        }
        
        [upsert populateFromApiJSONDictionary:dict];
        upsert.channel = [CoreDataHelper fetchPublicChannelFromCoreDataContext:context]; 
    }

    [CoreDataHelper saveAndReleaseContext:context];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedBroadcastsAndStoredInCoreData" 
                                                        object:[DataApi class]];
}

+ (void)fetchBroadcastsAndReturnJSON
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: kBroadcastsUrl, [ShelbyApp sharedApp].userSessionHelper.currentUserPublicChannel.shelbyId]];    
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    [DataApi makeRequest:req withProcessResponseSelector:@selector(processGetBroadcastsResponseAndReturnJSON:)];
}

+ (void)processGetBroadcastsResponseAndReturnJSON:(NSArray *)array
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedBroadcastsAndReturnedJSON" 
                                                        object:[DataApi class] 
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:array, @"jsonDictionariesArray", nil]];
}

@end
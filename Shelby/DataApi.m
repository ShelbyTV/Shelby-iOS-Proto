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
#import "PlatformHelper.h"

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
        // XXX sigh, silently ignoring errors probably isn't good...
        // [NSException raise:@"unexpected" format:@"Data API request error! error: %@", error];
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
    
    [[ShelbyApp sharedApp].userSessionHelper updateCurrentUserInCoreData];

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

+ (void)storeNewBroadcastsInCoreData:(NSArray *) array
{   
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    
    /*
     * We have to make sure that we respect maxVideos in 3 spots and only examing the maxVideos most recent videos.
     * Those spots are where we save videos to CoreData (here), where we calculate how many new videos there are, and
     * where we actually populate our data in-memory data structures.
     *
     * By having all 3 locations all reference the maxVideos most recent videos, we can make sure that occasional blips
     * or odd behaviors server-side don't cause any problems client-side (e.g. if a recently added CoreData video is missing
     * from an API update).
     */
    
    int numToKeep = [PlatformHelper maxVideos];
 
    NSArray *newBroadcastsSortedByDate = [array sortedArrayUsingComparator:(NSComparator)^(id dict1, id dict2) {
        
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        NSDate *date1;
        NSDate *date2;
        
        if (NOT_NULL([dict1 objectForKey:@"created_at"])) {
            date1 = [dateFormatter dateFromString:[dict1 objectForKey: @"created_at"]];
        }
        if (NOT_NULL([dict2 objectForKey:@"created_at"])) {
            date2 = [dateFormatter dateFromString:[dict2 objectForKey: @"created_at"]];
        }

        return [date2 compare:date1];
    }];
     
    int upserted = 0;

    for (NSDictionary *dict in newBroadcastsSortedByDate)
    {        
        if (upserted >= numToKeep) {
            break;
        }
                
        Broadcast *upsert = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast" withShelbyId:[dict objectForKey:@"_id"] inContext:context];
        
        if (IS_NULL(upsert)) {
            upsert = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Broadcast"
                      inManagedObjectContext:context];
        }
        
        [upsert populateFromApiJSONDictionary:dict];
        upsert.channel = [CoreDataHelper fetchPublicChannelFromCoreDataContext:context];
        
        upserted++;
    }
    
    [CoreDataHelper saveAndReleaseContext:context]; 
}

+ (void)processGetBroadcastsResponseAndStoreInCoreData:(NSArray *)array
{
    [DataApi storeNewBroadcastsInCoreData:array];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedBroadcastsAndStoredInCoreData" 
                                                        object:[DataApi class]];
}

+ (void)fetchPollingBroadcastsAndStoreInCoreData
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: kBroadcastsUrl, [ShelbyApp sharedApp].userSessionHelper.currentUserPublicChannel.shelbyId]];    
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"GET"];
    [DataApi makeRequest:req withProcessResponseSelector:@selector(processPollBroadcastsResponseAndStoreInCoreData:)];
}

+ (void)processPollBroadcastsResponseAndStoreInCoreData:(NSArray *)array
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [DataApi storeNewBroadcastsInCoreData:array];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedPollingBroadcastsAndStoredInCoreData" 
                                                                object:[DataApi class]];
        });
        
    });
}

@end
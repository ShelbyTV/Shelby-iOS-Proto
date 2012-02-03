//
//  VideoData.m
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

// Globals
#import "ShelbyApp.h"

// Video 
#import "VideoData.h"
#import "VideoCoreDataInterface.h"
#import "Video.h"

// Core Data
#import "Broadcast.h"

// Content URL Support
#import "VideoGetter.h"

@implementation VideoData

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:3];
        
        videoDupeDict = [[NSMutableDictionary alloc] init];
        
        uniqueVideoKeys = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

#pragma mark - Utility

- (NSString *)dupeKeyWithProvider:(NSString *)provider 
                           withId:(NSString *)providerId
{
    return [NSString stringWithFormat:@"%@%@", provider, providerId];
}

#pragma mark - Video Info

- (NSArray *)videoDupes:(Video *)video
{
//    @synchronized(tableVideos)
//    {
//        return [[[videoDupeDict objectForKey:[self dupeKeyWithProvider:video.provider withId:video.providerId]] retain] autorelease];
//    } 
    return nil;
}

- (NSURL *)getVideoContentURL:(Video *)video
{
    if (video.contentURL == nil) {
        [[VideoGetter singleton] processVideo:video];
    }
    
    return video.contentURL;
}

#pragma mark - Core Data Broadcast Processing

- (void)processBroadcastArray:(NSArray *)broadcasts
{
    for (Broadcast *broadcast in broadcasts) {
        Video *video = [[[Video alloc] initWithBroadcast:broadcast] autorelease];
        
        NSMutableArray *dupeArray = [videoDupeDict objectForKey:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
        if (NOT_NULL(dupeArray)) {
            [dupeArray insertObject:video atIndex:0];
        } else {
            dupeArray = [[[NSMutableArray alloc] init] autorelease];
            [dupeArray addObject:video];
            [videoDupeDict setObject:dupeArray forKey:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            [uniqueVideoKeys addObject:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            
            [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(checkPlayable:) object:video] autorelease]];
        }
        
//        // need the sharerImage even for dupes
//        if (IS_NULL(broadcast.sharerImage)) {
//            [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadSharerImage:) object:video] autorelease]];
//        } else {
//            [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadSharerImageFromCoreData:) object:video] autorelease]];
//        }
//        
//        // could optimize to not re-download for dupes, but don't bother for now...
//        if (IS_NULL(broadcast.thumbnailImage)) {
//            [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadVideoThumbnail:) object:video] autorelease]];
//        } else {
//            [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadVideoThumbnailFromCoreData:) object:video] autorelease]];
//        }
    }
}

- (void)loadFromCoreData
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil]; // don't need undo, and this speeds things up / requires less memory
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    [context setPersistentStoreCoordinator:psCoordinator];
    
    NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
    [broadcasts addObjectsFromArray:[[VideoCoreDataInterface singleton] fetchBroadcastsFromCoreDataContext:context]];
    [self processBroadcastArray:broadcasts];
    
    [context release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewVideoDataAvailable" object:self];
}

#pragma mark - Like Status

- (void)updateLikeStatusForVideo:(Video *)video withStatus:(BOOL)status
{
    video.isLiked = status;
    [[VideoCoreDataInterface singleton] storeLikeStatus:video];
}

- (void)likeVideoSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        [self updateLikeStatusForVideo:[notification.userInfo objectForKey:@"video"] withStatus:TRUE];
    }
}

- (void)dislikeVideoSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        [self updateLikeStatusForVideo:[notification.userInfo objectForKey:@"video"] withStatus:FALSE];
    }
}

#pragma mark - Watch Later Status

- (void)updateWatchLaterStatusForVideo:(Video *)video withStatus:(BOOL)status
{
    video.isWatchLater = status;
    [[VideoCoreDataInterface singleton] storeWatchLaterStatus:video];
}

- (void)watchLaterSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        [self updateWatchLaterStatusForVideo:[notification.userInfo objectForKey:@"video"] withStatus:TRUE];
    }
}

- (void)unwatchLaterSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        [self updateWatchLaterStatusForVideo:[notification.userInfo objectForKey:@"video"] withStatus:FALSE];
    }
}

#pragma mark - Watch Status

- (void)watchVideoSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        Video *video = [notification.userInfo objectForKey:@"video"];
        video.isWatched = TRUE;
        [[VideoCoreDataInterface singleton] storeWatchStatus:video];
        //[self updateVideoTableCell:video];
    }
}

#pragma mark - Unorganized

- (NSDictionary *)createBroadcastShelbyIdentDict:(NSArray *)broadcasts
{
    NSMutableDictionary *returnDict = [[[NSMutableDictionary alloc] initWithCapacity:[broadcasts count]] autorelease];
    
    for (Broadcast *broadcast in broadcasts) {
        [returnDict setObject:broadcast forKey:broadcast.shelbyId];
    }
    
    return returnDict;
}

- (BOOL)providerPassesBasicChecks:(NSString *)provider withId:(NSString *)providerId
{
    if (IS_NULL(provider) || !([provider isEqualToString: @"youtube"] ||
                               [provider isEqualToString: @"vimeo"])) {
        return FALSE;
    }
    
    if (IS_NULL(providerId) || [providerId isEqualToString:@""]) {
        return FALSE;;
    }
    
    if ([provider isEqualToString: @"vimeo"] &&
        ![providerId isEqualToString:[NSString stringWithFormat:@"%d", [providerId intValue]]])
    {
        return FALSE;
    }
    
    return TRUE;
}

- (NSDictionary *)addOrUpdateBroadcasts:(NSMutableArray *)broadcasts 
                            withNewJSON:(NSArray *)jsonDictionariesArray 
                            withChannel:(Channel *)jsonChannel
                            withContext:(NSManagedObjectContext *)context
{
    NSMutableDictionary *jsonBroadcasts = [[[NSMutableDictionary alloc] init] autorelease];
    
    // create lookup dictionary of shelbyID => old broadast
    NSDictionary *existingBroadcastShelbyIDs = [self createBroadcastShelbyIdentDict:broadcasts];
    
    for (NSDictionary *dict in jsonDictionariesArray)
    {
        // easy checks, should do now rather than later
        NSString *provider = [dict objectForKey:@"video_provider_name"];
        NSString *providerId = [dict objectForKey:@"video_id_at_provider"];
        
        if (![self providerPassesBasicChecks:provider withId:providerId]) {
            continue;
        }
        
        Broadcast *upsert = [existingBroadcastShelbyIDs objectForKey:[dict objectForKey:@"_id"]];
        
        if (IS_NULL(upsert)) {
            upsert = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Broadcast"
                      inManagedObjectContext:context];
            
            [broadcasts addObject:upsert];
        }
        
        [jsonBroadcasts setObject:upsert forKey:[dict objectForKey:@"_id"]];
        [upsert populateFromApiJSONDictionary:dict];
        
        if (jsonChannel) {
            upsert.channel = jsonChannel; 
        }
    }
    
    return jsonBroadcasts;
}

- (void)receivedBroadcastsNotification:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(loadNewBroadcastsFromJSON:) userInfo:notification.userInfo repeats:NO];
}








@end

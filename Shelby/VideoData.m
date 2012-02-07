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
#import "VideoDataProcessor.h"
#import "VideoHelper.h"

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
        videoDupeDict = [[NSMutableDictionary alloc] init];
        
        uniqueVideoKeys = [[NSMutableArray alloc] init];
        
        dataProcessor = [[VideoDataProcessor alloc] init];
        dataProcessor.delegate = self;
        
        videoDataDelegates = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedBroadcastsNotification:)
                                                     name: @"ReceivedBroadcasts"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(likeVideoSucceeded:)
                                                     name:@"LikeBroadcastSucceeded"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dislikeVideoSucceeded:)
                                                     name:@"DislikeBroadcastSucceeded"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(watchLaterSucceeded:)
                                                     name:@"WatchLaterBroadcastSucceeded"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(unwatchLaterSucceeded:)
                                                     name:@"UnwatchLaterBroadcastSucceeded"
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(watchVideoSucceeded:)
                                                     name:@"WatchBroadcastSucceeded"
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Utility



#pragma mark - Video Info

- (NSArray *)videoDupesForVideo:(Video *)video
{
    return [[[videoDupeDict objectForKey:[video dupeKey]] retain] autorelease];
}


- (NSArray *)videoDupesForKey:(NSString *)videoKey
{
    return [[[videoDupeDict objectForKey:videoKey] retain] autorelease];
}

- (NSURL *)getVideoContentURL:(Video *)video
{
    if (video.contentURL == nil) {
        [[VideoGetter singleton] processVideo:video];
    }
    
    return video.contentURL;
}

- (NSArray *)uniqueVideoKeys
{
    return uniqueVideoKeys;
}

#pragma mark - Core Data Broadcast Processing

- (void)processBroadcastArray:(NSArray *)broadcasts
{
    for (Broadcast *broadcast in broadcasts) {
        Video *video = [[[Video alloc] initWithBroadcast:broadcast] autorelease];
        
        NSMutableArray *dupeArray = [videoDupeDict objectForKey:[VideoHelper dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
        if (NOT_NULL(dupeArray)) {
            [dupeArray insertObject:video atIndex:0];
        } else {
            dupeArray = [[[NSMutableArray alloc] init] autorelease];
            [dupeArray addObject:video];
            [videoDupeDict setObject:dupeArray forKey:[VideoHelper dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            [uniqueVideoKeys addObject:[VideoHelper dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            
            [dataProcessor scheduleCheckPlayable:video];
            
            NSLog(@"added checkPlayable Op");
        }
        
        [dataProcessor scheduleImageAcquisition:video];
    }
}

- (void)loadInitialVideosFromCoreData
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil]; // don't need undo, and this speeds things up / requires less memory
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    [context setPersistentStoreCoordinator:psCoordinator];
    
    NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
    [broadcasts addObjectsFromArray:[VideoCoreDataInterface fetchBroadcastsFromCoreDataContext:context]];
    [self processBroadcastArray:broadcasts];
    
    [context release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewVideoDataAvailable" object:self];
}

#pragma mark - Like Status

- (void)updateLikeStatusForVideo:(Video *)video withStatus:(BOOL)status
{
    video.isLiked = status;
    [VideoCoreDataInterface storeLikeStatus:video];
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
    [VideoCoreDataInterface storeWatchLaterStatus:video];
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
        [VideoCoreDataInterface storeWatchStatus:video];
        //[self updateVideoTableCell:video];
    }
}

#pragma mark - VideoDataProcessorDelegate Methods

- (void)newPlayableVideoAvailable:(Video *)video
{
    for (id <VideoDataDelegate> delegate in videoDataDelegates) {
        [delegate newPlayableVideoAvailable:video];
    }
}

- (void)updateVideoTableCell:(Video *)video
{
    for (id <VideoDataDelegate> delegate in videoDataDelegates) {
        [delegate updateVideoTableCell:video];
    }
}

- (void)storePlayableStatus:(Video *)video
{
    
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

- (void)loadInitialVideosFromAPI
{
//    [[ShelbyApp sharedApp].loginHelper fetchBroadcasts];
}

- (void)addDelegate:(id<VideoDataDelegate>)consumer
{
    [videoDataDelegates addObject:consumer];
}

@end

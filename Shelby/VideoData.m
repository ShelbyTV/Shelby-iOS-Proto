//
//  VideoData.m
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

// Kitchen Sink
#import "ShelbyApp.h"
#import "UserSessionHelper.h"
#import "CoreDataHelper.h"

// Video 
#import "VideoData.h"
#import "VideoCoreDataInterface.h"
#import "Video.h"
#import "VideoDataProcessor.h"
#import "VideoHelper.h"
#import "VideoDataPoller.h"
#import "VideoDupeArray.h"

// Core Data
#import "Broadcast.h"
#import "SharerImage.h"
#import "ThumbnailImage.h"

// API
#import "DataApi.h"

// Content URL Support
#import "VideoContentURLGetter.h"

#import "PlatformHelper.h"
#import "Enums.h"

@implementation VideoData

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        videoDupeDict = [[NSMutableDictionary alloc] init];
        videoDupeArraysSorted = [[NSMutableArray alloc] init];
        videoDataDelegates = [[NSMutableArray alloc] init];
        knownShelbyIds = [[NSMutableDictionary alloc] init];
        
        dataProcessor = [[VideoDataProcessor alloc] init];
        dataProcessor.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedBroadcastsAndStoredInCoreDataNotification:)
                                                     name: @"ReceivedBroadcastsAndStoredInCoreData"
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
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedNewDataFromAPI:)
                                                     name: @"NewDataAvailableFromAPI"
                                                   object: nil];
    }
    
    return self;
}

#pragma mark - Video Info

- (NSArray *)videoDupesForVideo:(Video *)video
{
    return [[((VideoDupeArray *)[videoDupeDict objectForKey:[video dupeKey]]) copyOfVideoArray] autorelease];
}

- (NSArray *)videoDupesForKey:(NSString *)videoKey
{
    return [[((VideoDupeArray *)[videoDupeDict objectForKey:videoKey]) copyOfVideoArray] autorelease];
}

- (NSURL *)getVideoContentURL:(Video *)video
{
    if (video.contentURL == nil) {
        [[VideoContentURLGetter singleton] processVideo:video];
    }
    
    return video.contentURL;
}

- (NSArray *)videoDupeArraysSorted
{
    NSArray *toReturn;
    
    @synchronized(videoDupeArraysSorted) {
        toReturn = [[videoDupeArraysSorted copy] autorelease];
    }
    
    return toReturn;
}

#pragma mark - Core Data Broadcast Processing

- (void)processBroadcastArray:(NSMutableArray *)broadcasts withContext:(NSManagedObjectContext *)context
{  
    /*
     * We have to make sure that we respect maxVideos in 3 spots and only examing the maxVideos most recent videos.
     * Those spots are where we save videos to CoreData, where we calculate how many new videos there are, and
     * where we actually populate our data in-memory data structures (here).
     *
     * By having all 3 locations all reference the maxVideos most recent videos, we can make sure that occasional blips
     * or odd behaviors server-side don't cause any problems client-side (e.g. if a recently added CoreData video is missing
     * from an API update).
     */
    
    int numBroadcasts = [broadcasts count];
    int numToKeep = [PlatformHelper maxVideos];

    int numToRemove = numBroadcasts - numToKeep;
    int numRemoved = 0;

    if (numToRemove > 0) {
        
        NSMutableArray *discardedBroadcasts = [[[NSMutableArray alloc] initWithCapacity:numToRemove] autorelease];

        for (Broadcast *broadcast in [broadcasts reverseObjectEnumerator]) {
            if (numRemoved >= numToRemove) {
                break;
            }
            
            [discardedBroadcasts addObject:broadcast];
            numRemoved++;
        }
        
        for (Broadcast *broadcast in discardedBroadcasts) {
            
            @synchronized(videoDupeArraysSorted) { // probably need a more appropriate lock entity...
                VideoDupeArray *dupeArray = [videoDupeDict objectForKey:[VideoHelper dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
                [dupeArray removeVideoWithShelbyId:broadcast.shelbyId];
                if ([dupeArray isEmpty]) {
                    [videoDupeDict removeObjectForKey:[VideoHelper dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
                    [videoDupeArraysSorted removeObject:dupeArray];
                }
            }
            
            if (NOT_NULL(broadcast.sharerImage)) {
                [context deleteObject:broadcast.sharerImage];
            }
            if (NOT_NULL(broadcast.thumbnailImage)) {
                [context deleteObject:broadcast.thumbnailImage];
            }
            [context deleteObject:broadcast];
            [broadcasts removeObject:broadcast];
        }
    }

    for (Broadcast *broadcast in broadcasts) {
        Video *video = [[[Video alloc] initWithBroadcast:broadcast] autorelease];
        
        if (IS_NULL([knownShelbyIds objectForKey:video.shelbyId])) {
            [knownShelbyIds setObject:[NSValue valueWithPointer:nil] forKey:video.shelbyId];
        } else {
            continue;
        }
        
        VideoDupeArray *dupeArray = [videoDupeDict objectForKey:[VideoHelper dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
        if (NOT_NULL(dupeArray)) {
            [dupeArray addVideo:video];
            @synchronized(videoDupeArraysSorted) {
                [videoDupeArraysSorted sortUsingSelector:@selector(compareByCreationTime:)];
            }
            [self updateVideoTableCell:[[[dupeArray copyOfVideoArray] autorelease] objectAtIndex:0]];
        } else {
            dupeArray = [[[VideoDupeArray alloc] init] autorelease];
            [dupeArray addVideo:video];
            [videoDupeDict setObject:dupeArray forKey:[VideoHelper dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            @synchronized(videoDupeArraysSorted) {
                [videoDupeArraysSorted addObject:dupeArray];
                [videoDupeArraysSorted sortUsingSelector:@selector(compareByCreationTime:)];
            }
        }
        
        [dataProcessor scheduleCheckPlayable:video];
        [dataProcessor scheduleImageAcquisitionWithBroadcast:broadcast withVideo:video];
    }

    
    [self videoTableNeedsUpdate];
}

- (void)loadInitialVideosFromCoreData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _isLoading = TRUE;
        
        NSManagedObjectContext *context = [CoreDataHelper createContext];
        
        NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
        [broadcasts addObjectsFromArray:[VideoCoreDataInterface fetchBroadcastsFromCoreDataContext:context]];
        [self processBroadcastArray:broadcasts withContext:context];
        
        [CoreDataHelper saveAndReleaseContext:context];
        
        _isLoading = FALSE;
    });
}

#pragma mark - API Broadcast Processing

- (void)loadInitialVideosFromAPI
{
    [DataApi fetchBroadcastsAndStoreInCoreData];
}

- (void)receivedBroadcastsAndStoredInCoreDataNotification:(NSNotification *)notification
{
    [self loadInitialVideosFromCoreData];
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
        [self updateVideoTableCell:video];
    }
}

#pragma mark - VideoDataProcessorDelegate Methods

- (void)videoTableNeedsUpdate
{
    for (id <VideoDataDelegate> delegate in videoDataDelegates) {
        [delegate videoTableNeedsUpdate];
    }
}

- (void)updateVideoTableCell:(Video *)video
{
    for (id <VideoDataDelegate> delegate in videoDataDelegates) {
        [delegate updateVideoTableCell:video];
    }
}

#pragma mark - Delegate Registration

- (void)addDelegate:(id<VideoDataDelegate>)consumer
{
    [videoDataDelegates addObject:consumer];
}

#pragma mark - Uncategorized

- (BOOL)isKnownVideoKey:(NSString *)key
{
    return NOT_NULL([videoDupeDict objectForKey:key]);
}

- (BOOL)isKnownShelbyId:(NSString *)shelbyId
{
    return NOT_NULL([knownShelbyIds objectForKey:shelbyId]);
}

- (void)loadAnyAdditionalVideos
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _isLoading = TRUE;
        
        // if no pending changes, query the API with the table refresh spinner going the whole time...
        if (_newVideos + _newCommentsOnExistingVideos <= 0) {
            [DataApi fetchBroadcastsAndStoreInCoreDataSynchronous];
        }
        
        NSManagedObjectContext *context = [CoreDataHelper createContext];
        
        NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
        [broadcasts addObjectsFromArray:[VideoCoreDataInterface fetchBroadcastsFromCoreDataContext:context]];
        [self processBroadcastArray:broadcasts withContext:context];
        
        [CoreDataHelper saveAndReleaseContext:context];
        
        [[ShelbyApp sharedApp].videoDataPoller recalculateImmediately];
        
        _isLoading = FALSE;
    });
}

- (BOOL)isLoading
{
    return _isLoading;
}

- (void)reloadTableVideos
{
    for (id <VideoDataDelegate> delegate in videoDataDelegates) {
        [delegate clearVideoTableData];
        [delegate updateTableVideos];
    }
}

- (void)reset
{
    [dataProcessor clearPendingOperations];
    [[ShelbyApp sharedApp].videoDataPoller clearPendingOperations];

    [videoDupeDict removeAllObjects];
    @synchronized(videoDupeArraysSorted) {
        [videoDupeArraysSorted removeAllObjects];
    }
    [knownShelbyIds removeAllObjects];
}

- (void)receivedNewDataFromAPI:(NSNotification *)notification
{
    _newVideos = [[notification.userInfo objectForKey:@"newVideos"] intValue];
    _newCommentsOnExistingVideos = [[notification.userInfo objectForKey:@"newCommentsOnExistingVideos"] intValue];
}

@end

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

// Core Data
#import "Broadcast.h"

// API
#import "DataApi.h"

// Content URL Support
#import "VideoContentURLGetter.h"

@implementation VideoData

@synthesize lastFetchBroadcasts;

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        videoDupeDict = [[NSMutableDictionary alloc] init];
        uniqueVideosSorted = [[NSMutableArray alloc] init];
        videoDataDelegates = [[NSMutableArray alloc] init];
        videoDataPoller = [[VideoDataPoller alloc] init];
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
    }
    
    return self;
}

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
        [[VideoContentURLGetter singleton] processVideo:video];
    }
    
    return video.contentURL;
}

- (NSArray *)uniqueVideosSorted
{
    return uniqueVideosSorted;
}

#pragma mark - Core Data Broadcast Processing

- (void)processBroadcastArray:(NSArray *)broadcasts
{       
    for (Broadcast *broadcast in broadcasts) {
        Video *video = [[[Video alloc] initWithBroadcast:broadcast] autorelease];
        
        if (IS_NULL([knownShelbyIds objectForKey:video.shelbyId])) {
            [knownShelbyIds setObject:[NSValue valueWithPointer:nil] forKey:video.shelbyId];
        } else {
            continue;
        }
        
        NSMutableArray *dupeArray = [videoDupeDict objectForKey:[VideoHelper dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
        if (NOT_NULL(dupeArray)) {
            [dupeArray addObject:video];
            [self updateVideoTableCell:[dupeArray objectAtIndex:0]];
        } else {
            dupeArray = [[[NSMutableArray alloc] init] autorelease];
            [dupeArray addObject:video];
            [videoDupeDict setObject:dupeArray forKey:[VideoHelper dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            @synchronized(uniqueVideosSorted) {
                [uniqueVideosSorted addObject:video];
                [uniqueVideosSorted sortUsingSelector:@selector(compareByCreationTime:)];
            }
            
            [dataProcessor scheduleCheckPlayable:video];
        }
        
        [dataProcessor scheduleImageAcquisition:video];
    }
    
    lastFetchBroadcasts = [NSDate date];
}

- (void)loadInitialVideosFromCoreData
{
    _isLoading = TRUE;
    
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    
    NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
    [broadcasts addObjectsFromArray:[VideoCoreDataInterface fetchBroadcastsFromCoreDataContext:context]];
    [self processBroadcastArray:broadcasts];
    
    [context release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewVideoDataAvailable" object:self];
    
    _isLoading = FALSE;
}

#pragma mark - API Broadcast Processing

- (void)loadInitialVideosFromAPI
{
    [DataApi fetchBroadcastsAndStoreInCoreData];
}

- (void)receivedBroadcastsAndStoredInCoreDataNotification:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval:0 
                                     target:self
                                   selector:@selector(loadInitialVideosFromAPIAfterBroadcastsFetched:) 
                                   userInfo:notification.userInfo 
                                    repeats:NO];
}

- (void)loadInitialVideosFromAPIAfterBroadcastsFetched:(NSTimer*)timer
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

- (void)loadAdditionalVideosFromCoreData
{
    _isLoading = TRUE;

    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    
    NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
    [broadcasts addObjectsFromArray:[VideoCoreDataInterface fetchBroadcastsFromCoreDataContext:context]];
    [self processBroadcastArray:broadcasts];
    
    [context release];
    
    [videoDataPoller recalculateImmediately];
    
    _isLoading = FALSE;
}

- (BOOL)isLoading
{
    return _isLoading;
}

@end

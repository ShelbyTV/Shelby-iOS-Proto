//
//  VideoDataPoller.m
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoDataPoller.h"
#import "DataApi.h"
#import "VideoDataProcessor.h"
#import "CoreDataHelper.h"
#import "Broadcast.h"
#import "VideoCoreDataInterface.h"
#import "Video.h"
#import "Enums.h"
#import "ShelbyApp.h"
#import "VideoHelper.h"
#import "VideoData.h"
#import "UserSessionHelper.h"
#import "PlatformHelper.h"

@implementation VideoDataPoller

#pragma mark - Init

- (id)init
{
    self = [super init];
    
    if (self) {
        dataProcessor = [[VideoDataProcessor alloc] init];
        dataProcessor.delegate = self;
        
        lastApiPollIntervalSeconds = 10;
        [NSTimer scheduledTimerWithTimeInterval:lastApiPollIntervalSeconds
                                         target:self
                                       selector:@selector(updateCoreDataAndIssuePlayabilityChecksTimer) 
                                       userInfo:nil 
                                        repeats:NO];
        
        [NSTimer scheduledTimerWithTimeInterval:5
                                         target:self
                                       selector:@selector(updateNewVideosAndCommentsCountersTimer) 
                                       userInfo:nil 
                                        repeats:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedPollingBroadcastsAndStoredInCoreDataNotification:)
                                                     name: @"ReceivedPollingBroadcastsAndStoredInCoreData"
                                                   object: nil];
    }
    
    return self;    
}

#pragma mark - Miscellaneous

- (void)receivedPollingBroadcastsAndStoredInCoreDataNotification:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval:0 
                                     target:self
                                   selector:@selector(processPollingBroadcastsStoredInCoreData:) 
                                   userInfo:notification.userInfo 
                                    repeats:NO];
}

- (void)updateCoreDataAndIssuePlayabilityChecks
{
    if (![[ShelbyApp sharedApp].userSessionHelper loggedIn]) {
        return;
    }
        
    [DataApi fetchPollingBroadcastsAndStoreInCoreData];
}

- (void)updateCoreDataAndIssuePlayabilityChecksTimer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateCoreDataAndIssuePlayabilityChecks];
    });
    
    lastApiPollIntervalSeconds = MIN((lastApiPollIntervalSeconds * 2), 120);
    [NSTimer scheduledTimerWithTimeInterval:lastApiPollIntervalSeconds
                                     target:self
                                   selector:@selector(updateCoreDataAndIssuePlayabilityChecksTimer) 
                                   userInfo:nil 
                                    repeats:NO];
}

- (void)processPollingBroadcastsStoredInCoreDataInt
{
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    
    NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
    [broadcasts addObjectsFromArray:[VideoCoreDataInterface fetchBroadcastsFromCoreDataContext:context]];
        
    for (Broadcast *broadcast in broadcasts) {
        if ([broadcast.isPlayable intValue] == PLAYABLE_UNSET) {
            Video *video = [[[Video alloc] initWithBroadcast:broadcast] autorelease];
            
            [dataProcessor scheduleCheckPlayable:video];
        }
    }
        
    [context release];
}

- (void)processPollingBroadcastsStoredInCoreData:(NSTimer*)timer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self processPollingBroadcastsStoredInCoreDataInt];
    });
}


- (void)updateNewVideosAndCommentsCounters
{    
    if (![[ShelbyApp sharedApp].userSessionHelper loggedIn]) {
        return;
    }
    
    if (!newPlayableBroadcasts) {
        return;
    }
    
    newPlayableBroadcasts = FALSE;

    // calculate number of new videos and comments on existing videos
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    NSArray *broadcastDicts = [VideoCoreDataInterface fetchKeyBroadcastFieldDictionariesFromCoreDataContext:context];
    
    int newVideos = 0;
    int newCommentsOnExistingVideos = 0;
    
    NSMutableDictionary *alreadyCountedVideos = [[[NSMutableDictionary alloc] init] autorelease];
    
    /*
     * We have to make sure that we respect maxVideos in 3 spots and only examing the maxVideos most recent videos.
     * Those spots are where we save videos to CoreData, where we calculate how many new videos there are (here), and
     * where we actually populate our data in-memory data structures.
     *
     * By having all 3 locations all reference the maxVideos most recent videos, we can make sure that occasional blips
     * or odd behaviors server-side don't cause any problems client-side (e.g. if a recently added CoreData video is missing
     * from an API update).
     */
    int numToExamine = [PlatformHelper maxVideos];
    int numExamined = 0;
    
    for (NSDictionary *dict in broadcastDicts) {
        
        numExamined++;
        
        if (numExamined > numToExamine) {
            break;
        }
        
        if ([[dict objectForKey:@"isPlayable"] intValue] != IS_PLAYABLE) {
            continue;
        }
        
        if ([[ShelbyApp sharedApp].videoData isKnownShelbyId:[dict objectForKey:@"shelbyId"]]) {
            continue;
        }
        
        NSString *videoKey = [VideoHelper dupeKeyWithProvider:[dict objectForKey:@"provider"] 
                                                       withId:[dict objectForKey:@"providerId"]];
        
        if ([[ShelbyApp sharedApp].videoData isKnownVideoKey:videoKey])
        {
            newCommentsOnExistingVideos++;
            
        } else if (IS_NULL([alreadyCountedVideos objectForKey:videoKey])) {
            
            newVideos++;
            [alreadyCountedVideos setValue:dict forKey:videoKey];
        }
    }
    
    [context release];
    
    // need to dispatch update even if 0 newVideos, 0 newComments
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewDataAvailableFromAPI"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:newVideos], @"newVideos", 
                                                                    [NSNumber numberWithInt:newCommentsOnExistingVideos], @"newCommentsOnExistingVideos",
                                                                    nil]];
    });
}

- (void)updateNewVideosAndCommentsCountersTimer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateNewVideosAndCommentsCounters];
    });
}     

- (void)recalculateImmediately
{
    newPlayableBroadcasts = TRUE;
    [self updateNewVideosAndCommentsCounters];
}

#pragma mark - VideoDataProcessorDelegate Methods

- (void)videoTableNeedsUpdate
{
    newPlayableBroadcasts = TRUE;
}

- (void)updateVideoTableCell:(Video *)video
{
    // not necessary, not going to have new images available
}

- (void)clearPendingOperations
{
    [dataProcessor clearPendingOperations];
}

@end
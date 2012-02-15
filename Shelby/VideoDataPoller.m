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
                                       selector:@selector(updateCoreDataAndIssuePlayabilityChecks) 
                                       userInfo:nil 
                                        repeats:NO];
        
        [NSTimer scheduledTimerWithTimeInterval:5
                                         target:self
                                       selector:@selector(updateNewVideosAndCommentsCounters) 
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
    [DataApi fetchPollingBroadcastsAndStoreInCoreData];
    
    lastApiPollIntervalSeconds = MIN((lastApiPollIntervalSeconds * 2), 120);
    [NSTimer scheduledTimerWithTimeInterval:lastApiPollIntervalSeconds
                                     target:self
                                   selector:@selector(updateCoreDataAndIssuePlayabilityChecks) 
                                   userInfo:nil 
                                    repeats:NO];
}

- (void)processPollingBroadcastsStoredInCoreData:(NSTimer*)timer
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

- (void)updateNewVideosAndCommentsCounters
{
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
    
    for (NSDictionary *dict in broadcastDicts) {
                
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
    
    if (newVideos != 0 || newCommentsOnExistingVideos != 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewDataAvailableFromAPI"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:newVideos], @"newVideos", 
                                                                                                              [NSNumber numberWithInt:newCommentsOnExistingVideos], @"newCommentsOnExistingVideos",
                                                                                                              nil]];
    }
    
    // XXX don't really need to "save" here, just release.
    [CoreDataHelper saveAndReleaseContext:context];
}

#pragma mark - VideoDataProcessorDelegate Methods

- (void)newPlayableVideoAvailable:(Video *)video
{
    newPlayableBroadcasts = TRUE;
}

- (void)updateVideoTableCell:(Video *)video
{
    // not necessary, not going to have new images available
}

@end
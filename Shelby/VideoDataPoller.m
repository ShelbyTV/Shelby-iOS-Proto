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
    }
    
    return self;    
}

#pragma mark - Miscellaneous

- (void)updateCoreDataAndIssuePlayabilityChecks
{
    NSLog(@"Inside updateCoreDataAndIssuePlayabilityChecks");
    [DataApi fetchBroadcastsAndStoreInCoreData];
    NSLog(@"Done with fetchBroadcastsAndStoreInCoreData");
    
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    
    NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
    [broadcasts addObjectsFromArray:[VideoCoreDataInterface fetchBroadcastsFromCoreDataContext:context]];
    
    NSLog(@"Iterating through CoreData broadcasts");

    for (Broadcast *broadcast in broadcasts) {
        if ([broadcast.isPlayable intValue] == PLAYABLE_UNSET) {
            Video *video = [[[Video alloc] initWithBroadcast:broadcast] autorelease];
        
            [dataProcessor scheduleCheckPlayable:video];
        }
    }
    
    NSLog(@"Done iterating through CoreData broadcasts");

    [context release];
    
    NSLog(@"Context released");
    
    lastApiPollIntervalSeconds = MIN((lastApiPollIntervalSeconds * 2), 120);
    [NSTimer scheduledTimerWithTimeInterval:lastApiPollIntervalSeconds
                                     target:self
                                   selector:@selector(updateCoreDataAndIssuePlayabilityChecks) 
                                   userInfo:nil 
                                    repeats:NO];
    
    NSLog(@"Rescheduled");

}

- (void)updateNewVideosAndCommentsCounters
{
    NSLog(@"Inside updateNewVideosAndCommentsCounters");

    if (!newPlayableBroadcasts) {
        NSLog(@"No newPlayableBroadcasts");
        return;
    }
    
    newPlayableBroadcasts = FALSE;
    
    // calculate number of new videos and comments on existing videos
    NSManagedObjectContext *context = [CoreDataHelper allocateContext];
    NSArray *broadcastDicts = [VideoCoreDataInterface fetchKeyBroadcastFieldDictionariesFromCoreDataContext:context];
    
    if (IS_NULL(broadcastDicts) || [broadcastDicts count] <= 0) {
        NSLog(@"Uh oh. something screwed up with broadcastDicts.");
    }
    
    NSLog(@"Iterating through all broadcasts");
    
    int newVideos = 0;
    int newCommentsOnExistingVideos = 0;
    
    NSMutableDictionary *alreadyCountedVideos = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSDictionary *dict in broadcastDicts) {
        
        if ([[dict objectForKey:@"isPlayable"] intValue] == IS_PLAYABLE) {
//            if (![ShelbyApp sharedApp].videoData isKnownVideoKey) {
//                newVideos++;
//            } else {
//                if (![ShelbyApp sharedApp].videoData isKnownShelbyId) {
//                    newCommentsOnExistingVideos++;
//                }
//            }
        }
        
        //NSLog(@"dict is %@", dict);
    }
    
    NSLog(@"Done iterating through all broadcasts");

    // XXX don't really need to "save" here, just release.
    [CoreDataHelper saveAndReleaseContext:context];
    
    NSLog(@"Finished saveAndReleaseContext");

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
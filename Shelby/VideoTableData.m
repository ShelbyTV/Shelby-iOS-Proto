//
//  VideoTableData.m
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoTableData.h"

#import "Broadcast.h"
#import "ThumbnailImage.h"
#import "SharerImage.h"

#import "ShelbyApp.h"
#import "NSURLConnection+AsyncBlock.h"
#import "Video.h"
#import "UserSessionHelper.h"
#import "CoreDataHelper.h"
#import "VideoContentURLGetter.h"
#import "PlatformHelper.h"
#import "Enums.h"
#import "VideoData.h"

#import "Foundation/Foundation.h"

#pragma mark - VideoTableData

@interface VideoTableData ()

@property (readwrite) NSInteger networkCounter;
@property (readwrite) NSUInteger numItemsInserted;

@end

@implementation VideoTableData

@synthesize delegate;
@synthesize networkCounter;
@synthesize numItemsInserted;

- (Video *)videoAtIndex:(NSUInteger)index
{    
    @synchronized(tableVideos)
    {
        if (index >= [tableVideos count])
        {
            // something racy happened, and our index is no longer valid
            return nil;
        }
        return [[(Video *)[tableVideos objectAtIndex:index] retain] autorelease];
    }
}

- (NSURL *)videoContentURLAtIndex:(NSUInteger)index
{
    Video *video = nil;

    @synchronized(tableVideos)
    {
        if (index >= [tableVideos count])
        {
            // something racy happened, and our index is no longer valid
            return nil;
        }
        video = [[[tableVideos objectAtIndex:index] retain] autorelease];
    }
    
    if (IS_NULL(video.contentURL) && ![ShelbyApp sharedApp].demoModeEnabled) {
        [[ShelbyApp sharedApp].videoData getVideoContentURL:video];
    }

    return [[video.contentURL retain] autorelease];
}

#pragma mark - Table Updates

- (void)updateVideoTableCell:(Video *)video
{    
    UITableViewCell *cell;
    
    @synchronized(tableVideos)
    {
        int videoIndex = [tableVideos indexOfObject:video];
        if (videoIndex == NSNotFound) {
            return;
        }
        
        cell = [[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(videoIndex) inSection:0]] retain] autorelease];
    }
    
    [cell performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

#pragma mark - Image Downloading


#pragma mark - Clearing

/*
 * Clear the existing video table, and update the table view to delete all entries
 */

- (void)clearVideoTableWithArrayLockHeld
{
    [tableVideos removeAllObjects];
    
    NSIndexSet *indexSet = [[[NSIndexSet alloc] initWithIndex:0] autorelease];

    [tableView beginUpdates];        
    
    [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    self.numItemsInserted = 0;

    [tableView endUpdates];
}

- (void)clearVideoTableData
{
//    @synchronized(tableVideos)
//    {
//        [videoDupeDict removeAllObjects];
//        [uniqueVideoKeys removeAllObjects];
//        [self clearVideoTableWithArrayLockHeld];
//    }
}

- (BOOL)shouldIncludeVideo:(NSArray *)dupeArray
{
    // implemented in subclass
    return FALSE;
}

- (void)insertTableVideos
{    
    int videoTableIndex = 0;
    
    for (NSString *key in [ShelbyApp sharedApp].videoData.uniqueVideoKeys)
    {
        NSArray *dupeArray = [[ShelbyApp sharedApp].videoData videoDupesForKey:key];
        Video *video = [dupeArray objectAtIndex:0];
        
        if (video.isPlayable != IS_PLAYABLE) {
            continue;
        }
        
        if (![self shouldIncludeVideo:dupeArray]) {
            continue;
        }
        
        if ([tableVideos count] > videoTableIndex) 
        {
            Video *videoAtTableIndex = [tableVideos objectAtIndex:videoTableIndex];
            NSString *videoAtTableIndexDupeKey = [videoAtTableIndex dupeKey];
            
            if ([[video dupeKey] isEqualToString:videoAtTableIndexDupeKey])
            {
                videoTableIndex++;
                continue;
            }
        }
        
        [tableVideos insertObject:video atIndex:videoTableIndex];
        
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:videoTableIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        self.numItemsInserted = [tableVideos count];
        [tableView endUpdates];
        
        videoTableIndex++;
    }
}

- (void)loadNewTableVideos
{
    @synchronized(tableVideos)
    {
        [self insertTableVideos];
    }
    [self.delegate videoTableDataDidFinishRefresh:self];
}

- (void)reloadTableVideosInt
{
    @synchronized(tableVideos)
    {
        [self clearVideoTableWithArrayLockHeld];
        [self insertTableVideos];
//        if (self.numItemsInserted > 1) {
//            [tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:1 inSection: 0]
//                             atScrollPosition: UITableViewScrollPositionTop
//                                     animated: NO];
//        }
    }
}

- (void)reloadTableVideos
{
    [self performSelectorOnMainThread:@selector(reloadTableVideosInt) withObject:nil waitUntilDone:NO];
}
- (void)clearTempDataStructuresForNewBroadcasts
{
//    [videoDupeDict removeAllObjects];
//    [uniqueVideoKeys removeAllObjects];
//    [playableVideoKeys removeAllObjects];
//    [self clearVideoTableWithArrayLockHeld];
}




#pragma mark - Notifications


#pragma mark - Initialization

- (id)initWithUITableView:(UITableView *)linkedTableView
{
    self = [super init];
    
    if (self) {
        // we use this to gracefully insert new entries into the UITableView
        tableView = linkedTableView;

        self.numItemsInserted = 0;
        tableVideos = [[NSMutableArray alloc] init];

        playableVideoKeys = [[NSMutableDictionary alloc] init];

        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:3];
        
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerCallback) userInfo:nil repeats:YES];
        
        [[ShelbyApp sharedApp] addNetworkObject:self];
        
        [[ShelbyApp sharedApp].videoData addDelegate:self];
    }
    
    return self;
}

- (void)updateTimerCallback
{
    self.networkCounter = [operationQueue operationCount];
    
    if (videoTableNeedsUpdate) {
        videoTableNeedsUpdate = FALSE;
        [self performSelectorOnMainThread:@selector(loadNewTableVideos) withObject:nil waitUntilDone:NO];
    }
}

- (void)newPlayableVideoAvailable:(Video *)video
{
    videoTableNeedsUpdate = TRUE;
}

@end

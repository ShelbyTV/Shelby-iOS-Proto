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
#import "VideoDupeArray.h"

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
        if (index >= [tableVideos count]) {
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
        if (index >= [tableVideos count]) {
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


#pragma mark - Clearing

- (void)clearVideoTableData
{
    @synchronized(tableVideos)
    {
        [tableVideos removeAllObjects];
        
        NSIndexSet *indexSet = [[[NSIndexSet alloc] initWithIndex:0] autorelease];
        
        [tableView beginUpdates];        
        
        [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
        self.numItemsInserted = 0;
        
        [tableView endUpdates];
    }
}

- (BOOL)shouldIncludeVideo:(NSArray *)dupeArray
{
    NSAssert(FALSE, @"Should only be called in the subclass");
    return FALSE;
}

- (void)updateTableVideosLockedWithAnimation:(UITableViewRowAnimation)animation
{    
    int videoTableIndex = 0;
    
    NSMutableDictionary *alreadyVisitedVideos = [[[NSMutableDictionary alloc] init] autorelease];
        
    for (VideoDupeArray *dupeArray in [ShelbyApp sharedApp].videoData.videoDupeArraysSorted)
    {
        NSArray *videos = [dupeArray copyOfVideoArray];
        Video *video = [videos objectAtIndex:0];
                
        if (video.isPlayable != IS_PLAYABLE) {
            continue;
        }
        
        if (![self shouldIncludeVideo:videos]) {
            continue;
        }
        
        if ([tableVideos count] > videoTableIndex) {
            
            Video *videoAtTableIndex = [tableVideos objectAtIndex:videoTableIndex];
            NSString *videoAtTableIndexDupeKey = [videoAtTableIndex dupeKey];
            
            while (NOT_NULL([alreadyVisitedVideos objectForKey:videoAtTableIndexDupeKey])) {
                [tableVideos removeObjectAtIndex:videoTableIndex];
                
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:videoTableIndex inSection:0]] withRowAnimation:animation];
                self.numItemsInserted = [tableVideos count];
                [tableView endUpdates];
                
                // go on to next vid
                if ([tableVideos count] > videoTableIndex) {
                    videoAtTableIndex = [tableVideos objectAtIndex:videoTableIndex];
                    videoAtTableIndexDupeKey = [videoAtTableIndex dupeKey];
                } else {
                    break;
                }
            }
        }
        
        if ([tableVideos count] > videoTableIndex) {
            
            Video *videoAtTableIndex = [tableVideos objectAtIndex:videoTableIndex];
            NSString *videoAtTableIndexDupeKey = [videoAtTableIndex dupeKey];
            
            if ([[video dupeKey] isEqualToString:videoAtTableIndexDupeKey]) {
                videoTableIndex++;
                [alreadyVisitedVideos setObject:dupeArray forKey:[video dupeKey]];
                continue;
            }
        }
        
        [tableVideos insertObject:video atIndex:videoTableIndex];
        
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:videoTableIndex inSection:0]] withRowAnimation:animation];
        self.numItemsInserted = [tableVideos count];
        [tableView endUpdates];
        
        [alreadyVisitedVideos setObject:dupeArray forKey:[video dupeKey]];
        videoTableIndex++;
    }
    
    while ([tableVideos count] > videoTableIndex) {
        [tableVideos removeObjectAtIndex:videoTableIndex];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:videoTableIndex inSection:0]] withRowAnimation:animation];
        self.numItemsInserted = [tableVideos count];
        [tableView endUpdates];
    }
}

- (void)updateTableVideos
{
    @synchronized(tableVideos)
    {
        [self updateTableVideosLockedWithAnimation:UITableViewRowAnimationFade];
    }
    [self.delegate videoTableDataDidFinishRefresh:self];
}

- (void)updateTableVideosNoAnimation
{
    @synchronized(tableVideos)
    {
        [self updateTableVideosLockedWithAnimation:UITableViewRowAnimationNone];
    }
    [tableView reloadData];
    [self.delegate videoTableDataDidFinishRefresh:self];
}

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
        
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateTimerCallback) userInfo:nil repeats:YES];
        
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
        [self performSelectorOnMainThread:@selector(updateTableVideos) withObject:nil waitUntilDone:NO];
    }
}

- (void)videoTableNeedsUpdate
{
    videoTableNeedsUpdate = TRUE;
}

@end

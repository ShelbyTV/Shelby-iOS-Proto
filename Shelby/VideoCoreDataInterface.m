//
//  VideoCoreDataInterface.m
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoCoreDataInterface.h"
#import "Video.h"
#import "ShelbyApp.h"
#import "UserSessionHelper.h"
#import "ThumbnailImage.h"
#import "SharerImage.h"
#import "Broadcast.h"
#import "PlatformHelper.h"
#import "CoreDataHelper.h"

@implementation VideoCoreDataInterface

#pragma mark - Video Status Storage

+ (void)storeLikeStatus:(Video *)video
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
        
            NSManagedObjectContext *context = [CoreDataHelper allocateContext];
            
            Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                                withShelbyId:video.shelbyId
                                                                   inContext:context];
            if (NOT_NULL(broadcast)) {
                broadcast.liked = [NSNumber numberWithBool:video.isLiked];
            }
            
            [CoreDataHelper saveAndReleaseContext:context];

        }
    });
}

+ (void)storeWatchLaterStatus:(Video *)video
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            NSManagedObjectContext *context = [CoreDataHelper allocateContext];
            
            Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                                withShelbyId:video.shelbyId
                                                                   inContext:context];
            if (NOT_NULL(broadcast)) {
                broadcast.watchLater = [NSNumber numberWithBool:video.isWatchLater];
            }
            
            [CoreDataHelper saveAndReleaseContext:context];
        }
    
    });
}

+ (void)storeWatchStatus:(Video *)video
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            NSManagedObjectContext *context = [CoreDataHelper allocateContext];
            
            Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                                withShelbyId:video.shelbyId
                                                                   inContext:context];
            if (NOT_NULL(broadcast)) {
                broadcast.watched = [NSNumber numberWithBool:video.isWatched];
            }
            
            [CoreDataHelper saveAndReleaseContext:context];
        }
        
    });
}

+ (void)storePlayableStatus:(Video *)video
{
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    @autoreleasepool {
        NSManagedObjectContext *context = [CoreDataHelper allocateContext];
        
        Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                            withShelbyId:video.shelbyId
                                                               inContext:context];
        if (NOT_NULL(broadcast)) {
            broadcast.isPlayable = [NSNumber numberWithBool:video.isPlayable];
        }
        
        [CoreDataHelper saveAndReleaseContext:context];
    }
}

#pragma mark - Video Image Storage

+ (void)storeSharerImage:(NSData *)sharerImage
                forVideo:(Video *)video
{
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    @autoreleasepool {        
        NSManagedObjectContext *context = [CoreDataHelper allocateContext];
        
        Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                            withShelbyId:video.shelbyId
                                                               inContext:context];
        
        if (NOT_NULL(broadcast)) {
            
            if (IS_NULL(broadcast.sharerImage)) {
                broadcast.sharerImage = [NSEntityDescription
                                         insertNewObjectForEntityForName:@"SharerImage"
                                         inManagedObjectContext:context];
            }
            
            broadcast.sharerImage.imageData = sharerImage;
        }
        
        [CoreDataHelper saveAndReleaseContext:context];
    }
}

+ (void)storeThumbnailImage:(NSData *)thumbnail
                   forVideo:(Video *)video
{
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    @autoreleasepool {
        NSManagedObjectContext *context = [CoreDataHelper allocateContext];
        
        Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                            withShelbyId:video.shelbyId
                                                               inContext:context];
        
        if (NOT_NULL(broadcast)) {
            
            if (IS_NULL(broadcast.thumbnailImage)) {
                broadcast.thumbnailImage = [NSEntityDescription
                                            insertNewObjectForEntityForName:@"ThumbnailImage"
                                            inManagedObjectContext:context];
            }
            
            broadcast.thumbnailImage.imageData = thumbnail;
        }
        
        [CoreDataHelper saveAndReleaseContext:context];
    }
}

#pragma mark - Unorganized

+ (NSArray *)fetchBroadcastsFromCoreDataContext:(NSManagedObjectContext *)context
{
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Broadcast" 
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel.public=0"];
    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sorter]];
    
    NSError *error = nil;
    NSArray *broadcasts = [context executeFetchRequest:fetchRequest error:&error];
    
    [fetchRequest release];
    [sorter release];
    
    return broadcasts;
}

+ (NSArray *)fetchKeyBroadcastFieldDictionariesFromCoreDataContext:(NSManagedObjectContext *)context
{
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Broadcast" 
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    NSDictionary *attributes = [entity attributesByName];
    
    NSArray *propertiesToFetch = [[[NSArray alloc] initWithObjects:
                                  [attributes objectForKey:@"provider"],
                                  [attributes objectForKey:@"providerId"],
                                  [attributes objectForKey:@"isPlayable"],
                                  [attributes objectForKey:@"shelbyId"],
                                  [attributes objectForKey:@"createdAt"],
                                  nil] autorelease];
    
    [fetchRequest setPropertiesToFetch:propertiesToFetch];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sorter]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel.public=0"];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *broadcasts = [context executeFetchRequest:fetchRequest error:&error];
    
    [fetchRequest release];
    [sorter release];
    
    return broadcasts;
}

+ (void)storeVideoThumbnail:(Video *)video
{
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    if (NOT_NULL(video.thumbnailImage)) 
    {
        [self storeThumbnailImage:UIImagePNGRepresentation(video.thumbnailImage) forVideo:video];
    }
}

+ (void)loadVideoThumbnailFromCoreData:(Video *)video
{
    @autoreleasepool {
    
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setUndoManager:nil];
        [context setPersistentStoreCoordinator:psCoordinator];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        ThumbnailImage *thumbnailImage = [CoreDataHelper fetchExistingUniqueEntity:@"ThumbnailImage" withBroadcastShelbyId:video.shelbyId inContext:context];
        
        if (IS_NULL(thumbnailImage)) 
        {
            NSLog(@"Couldn't find CoreData thumbnailImage entry for video %@; aborting load of thumbnailImage", video.shelbyId);
        } else {
            video.thumbnailImage = [UIImage imageWithData:thumbnailImage.imageData];
            //[self updateVideoTableCell:video];
        }
        
        [context release];

    }
}

+ (void)storeSharerImage:(Video *)video
{
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    if (NOT_NULL(video.sharerImage)) 
    {
        [VideoCoreDataInterface storeSharerImage:UIImagePNGRepresentation(video.sharerImage) forVideo:video];
    }
}

+ (void)loadSharerImageFromCoreData:(Video *)video
{
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    @autoreleasepool {
        
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setUndoManager:nil];
        [context setPersistentStoreCoordinator:psCoordinator];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        SharerImage *sharerImage = [CoreDataHelper fetchExistingUniqueEntity:@"SharerImage" withBroadcastShelbyId:video.shelbyId inContext:context];
        
        if (IS_NULL(sharerImage)) 
        {
            NSLog(@"Couldn't find CoreData sharerImage entry for video %@; aborting load of sharerImage", video.shelbyId);
        } else {
            video.sharerImage = [UIImage imageWithData:sharerImage.imageData];
        }
        
        [context release];
    
    }
}

+ (void)removeExtraBroadcasts:(NSMutableArray *)broadcasts 
                  withNewJSON:(NSDictionary *)jsonBroadcasts
                  withContext:(NSManagedObjectContext *)context
{
    // This method takes a long time to execute, and it should never be called from the main thread.
    NSAssert(![NSThread isMainThread], @"Method called on main thread! Should be in the background!");
    
    int numBroadcasts = [broadcasts count];
    int numToKeep;
    
    int minRAM = [PlatformHelper minimumRAM];
    if (minRAM <= 128) {
        numToKeep = 60;
    } else if (minRAM <= 256) {
        numToKeep = 200;
    } else {
        numToKeep = 300;
    }
    
    int numToRemove = numBroadcasts - numToKeep;
    int numRemoved = 0;
    
    if (numToRemove <= 0) {
        return;
    }
    
    NSMutableArray *discardedBroadcasts = [[[NSMutableArray alloc] initWithCapacity:numToRemove] autorelease];
    
    int jsonBroadcastsCount = [jsonBroadcasts count];
    
    for (Broadcast *broadcast in [broadcasts reverseObjectEnumerator]) {
        if (numRemoved >= numToRemove) {
            break;
        }
        
        if ((numToKeep > jsonBroadcastsCount) && NOT_NULL([jsonBroadcasts objectForKey:broadcast.shelbyId])) {
            continue; // don't remove anything Shelby just told us about
        }
        
        [discardedBroadcasts addObject:broadcast];
        numRemoved++;
    }
    
    [broadcasts removeObjectsInArray:discardedBroadcasts];
    
    for (Broadcast *broadcast in discardedBroadcasts) {
        if (NOT_NULL(broadcast.sharerImage)) {
            [context deleteObject:broadcast.sharerImage];
        }
        if (NOT_NULL(broadcast.thumbnailImage)) {
            [context deleteObject:broadcast.thumbnailImage];
        }
        [context deleteObject:broadcast];
    }
}


@end

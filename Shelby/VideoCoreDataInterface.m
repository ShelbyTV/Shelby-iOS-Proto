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
#import "LoginHelper.h"
#import "ThumbnailImage.h"
#import "SharerImage.h"
#import "Broadcast.h"
#import "PlatformHelper.h"
#import "CoreDataHelper.h"

@implementation VideoCoreDataInterface

#pragma mark - Context Helpers

+ (NSManagedObjectContext *)allocateContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil];
    [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    [context setPersistentStoreCoordinator:psCoordinator];
    
    return context;
}

+ (BOOL)contextHasChanges:(NSManagedObjectContext *)context
{
    return (context.insertedObjects.count != 0 ||
            context.deletedObjects.count != 0 ||
            context.updatedObjects.count != 0);
}

+ (void)saveAndReleaseContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    
    if ([self contextHasChanges:context] && ![context save:&error]) {
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@"  DetailedError: %@", [detailedError userInfo]);
            }
        } else {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
    
    [context release];
}

#pragma mark - Video Status Storage

+ (void)storeLikeStatus:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSManagedObjectContext *context = [self allocateContext];
    
    Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                        withShelbyId:video.shelbyId
                                                           inContext:context];
    if (NOT_NULL(broadcast)) {
        broadcast.liked = [NSNumber numberWithBool:video.isLiked];
    }
    
    [self saveAndReleaseContext:context];
    [pool release];
}

+ (void)storeWatchLaterStatus:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSManagedObjectContext *context = [self allocateContext];
    
    Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                        withShelbyId:video.shelbyId
                                                           inContext:context];
    if (NOT_NULL(broadcast)) {
        broadcast.watchLater = [NSNumber numberWithBool:video.isWatchLater];
    }
    
    [self saveAndReleaseContext:context];
    [pool release];
}

+ (void)storeWatchStatus:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSManagedObjectContext *context = [self allocateContext];
    
    Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                        withShelbyId:video.shelbyId
                                                           inContext:context];
    if (NOT_NULL(broadcast)) {
        broadcast.watched = [NSNumber numberWithBool:video.isWatched];
    }
    
    [self saveAndReleaseContext:context];
    [pool release];
}

+ (void)storePlayableStatus:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSManagedObjectContext *context = [self allocateContext];
    
    Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                        withShelbyId:video.shelbyId
                                                           inContext:context];
    if (NOT_NULL(broadcast)) {
        broadcast.isPlayable = [NSNumber numberWithBool:video.isPlayable];
    }
    
    [self saveAndReleaseContext:context];
    [pool release];
}

#pragma mark - Video Image Storage

+ (void)storeSharerImage:(NSData *)sharerImage
                forVideo:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSManagedObjectContext *context = [self allocateContext];
    
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
    
    [self saveAndReleaseContext:context];
    [pool release];
}

+ (void)storeThumbnailImage:(NSData *)thumbnail
                   forVideo:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSManagedObjectContext *context = [self allocateContext];
    
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
    
    [self saveAndReleaseContext:context];
    [pool release];
}

#pragma mark - Unorganized

+ (Channel *)fetchPublicChannelFromCoreDataContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Channel" 
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"public=0"];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *channels = [context executeFetchRequest:fetchRequest error:&error];
    
    [fetchRequest release];
    
    return [channels objectAtIndex:0];
}

+ (NSArray *)fetchBroadcastsFromCoreDataContext:(NSManagedObjectContext *)context
{
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

+ (void)storeVideoThumbnail:(Video *)video
{
    if (NOT_NULL(video.sharerImage)) 
    {
        [self storeThumbnailImage:UIImagePNGRepresentation(video.thumbnailImage) forVideo:video];
        
    }
}

+ (void)loadVideoThumbnailFromCoreData:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
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
    [pool release];
}




+ (void)storeSharerImage:(Video *)video
{ 
    if (NOT_NULL(video.sharerImage)) 
    {
        [VideoCoreDataInterface storeSharerImage:UIImagePNGRepresentation(video.sharerImage) forVideo:video];
    }
}

+ (void)loadSharerImageFromCoreData:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
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
    [pool release];
}

+ (void)sortBroadcasts:(NSMutableArray *)broadcasts 
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [broadcasts sortUsingDescriptors:sortDescriptors];
}

+ (void)removeExtraBroadcasts:(NSMutableArray *)broadcasts 
                  withNewJSON:(NSDictionary *)jsonBroadcasts
                  withContext:(NSManagedObjectContext *)context
{
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

//
//  CoreDataHelper.m
//  Shelby
//
//  Created by Mark Johnson on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataHelper.h"
#import "ShelbyApp.h"
#import "Channel.h"

@implementation CoreDataHelper

+ (id)fetchExistingUniqueEntity:(NSString *)entityName 
                   withShelbyId:(NSString *)shelbyId 
                      inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName 
                                        inManagedObjectContext:context]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"shelbyId=%@", shelbyId]];
    
    NSError *error = NULL;
    NSArray *existingEntities = [context executeFetchRequest:fetchRequest error:&error];
    
    if (NOT_NULL(existingEntities) && [existingEntities count] == 1) {
        return [existingEntities objectAtIndex:0];
    } else {
        assert(IS_NULL(existingEntities) || [existingEntities count] == 0);
    }
    
    return nil;
}

+ (id)fetchExistingUniqueEntity:(NSString *)entityName 
          withBroadcastShelbyId:(NSString *)shelbyId 
                      inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName 
                                        inManagedObjectContext:context]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"broadcast.shelbyId=%@", shelbyId]];
    
    NSError *error = NULL;
    NSArray *existingEntities = [context executeFetchRequest:fetchRequest error:&error];
    
    if (NOT_NULL(existingEntities) && [existingEntities count] == 1) {
        return [existingEntities objectAtIndex:0];
    } else {
        assert(IS_NULL(existingEntities) || [existingEntities count] == 0);
    }
    
    return nil;
}

+ (void)saveContextAndLogErrors:(NSManagedObjectContext *)context
{
    NSError *error;
    if (![context save:&error]) {
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@"  DetailedError: %@", [detailedError userInfo]);
            }
        } else {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        //[NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
}

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
    if ([CoreDataHelper contextHasChanges:context]) {
        [CoreDataHelper saveContextAndLogErrors:context];
    }
    
    [context release];
}

+ (void)deleteEntityType:(NSString *)entityName withContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *allEntities = [[NSFetchRequest alloc] init];
    [allEntities setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    [allEntities setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error;
    NSArray *entities = [context executeFetchRequest:allEntities error:&error];
    [allEntities release];
    
    for (NSManagedObject *entity in entities) {
        [context deleteObject:entity];
    }
}

+ (void)deleteAllData
{
    
    @autoreleasepool {
        NSManagedObjectContext *context = [CoreDataHelper allocateContext];
        
        [self deleteEntityType:@"User" withContext:context];
        [self deleteEntityType:@"Channel" withContext:context];
        [self deleteEntityType:@"Broadcast" withContext:context];
        [self deleteEntityType:@"ThumbnailImage" withContext:context];
        [self deleteEntityType:@"SharerImage" withContext:context];
        
        [CoreDataHelper saveContextAndLogErrors:context];
        
        [CoreDataHelper saveAndReleaseContext:context];
    }

}

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
    
    return (NOT_NULL(channels) && [channels count] > 0) ? [channels objectAtIndex:0] : nil;
}

+ (User *)fetchUserFromCoreDataContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    return (NOT_NULL(objects) && [objects count] > 0) ? [objects objectAtIndex:0] : nil;
}

@end

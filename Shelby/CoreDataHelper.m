//
//  CoreDataHelper.m
//  Shelby
//
//  Created by Mark Johnson on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataHelper.h"

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
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
}

@end

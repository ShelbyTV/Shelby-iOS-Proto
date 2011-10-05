//
//  CoreDataHelper.m
//  Shelby
//
//  Created by Mark Johnson on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


+ (id)fetchExistingUniqueEntity:(NSString *)entityName withShelbyId:(NSString *)shelbyId inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shelbyId=%@", shelbyId];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = NULL;
    NSArray *existingEntities = [context executeFetchRequest:fetchRequest error:&error];
    
    [fetchRequest release];
    
    id toReturn = NULL;
    
    if (NOT_NULL(existingEntities) && [existingEntities count] == 1) {
        toReturn = [existingEntities objectAtIndex:0];
    } else {
        NSAssert(existingEntities == nil || [existingEntities count] == 0, @"Found > 1 existing entities with same ID");
    }
    
    return toReturn;
}

@end

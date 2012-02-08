//
//  CoreDataHelper.h
//  Shelby
//
//  Created by Mark Johnson on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Channel;
@class User;

@interface CoreDataHelper : NSObject

+ (id)fetchExistingUniqueEntity:(NSString *)entityName 
                   withShelbyId:(NSString *)shelbyId 
                      inContext:(NSManagedObjectContext *)context;

+ (id)fetchExistingUniqueEntity:(NSString *)entityName 
          withBroadcastShelbyId:(NSString *)shelbyId 
                      inContext:(NSManagedObjectContext *)context;


+ (NSManagedObjectContext *)allocateContext;
+ (BOOL)contextHasChanges:(NSManagedObjectContext *)context;
+ (void)saveAndReleaseContext:(NSManagedObjectContext *)context;

+ (void)deleteAllData;

+ (Channel *)fetchPublicChannelFromCoreDataContext:(NSManagedObjectContext *)context;
+ (User *)fetchUserFromCoreDataContext:(NSManagedObjectContext *)context;

@end

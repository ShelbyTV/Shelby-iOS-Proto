//
//  CoreDataHelper.h
//  Shelby
//
//  Created by Mark Johnson on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataHelper : NSObject

+ (id)fetchExistingUniqueEntity:(NSString *)entityName withShelbyId:(NSString *)shelbyId inContext:(NSManagedObjectContext *)context;

@end

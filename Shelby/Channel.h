//
//  Channel.h
//  Shelby
//
//  Created by David Kay on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Channel : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * shelbyId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * public;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *broadcasts;
@end

@interface Channel (CoreDataGeneratedAccessors)

- (void)addBroadcastsObject:(NSManagedObject *)value;
- (void)removeBroadcastsObject:(NSManagedObject *)value;
- (void)addBroadcasts:(NSSet *)values;
- (void)removeBroadcasts:(NSSet *)values;
@end

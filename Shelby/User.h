//
//  User.h
//  Shelby
//
//  Created by David Kay on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * shelbyId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSSet *channels;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addChannelsObject:(NSManagedObject *)value;
- (void)removeChannelsObject:(NSManagedObject *)value;
- (void)addChannels:(NSSet *)values;
- (void)removeChannels:(NSSet *)values;
@end

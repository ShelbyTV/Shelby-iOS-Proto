//
//  User.h
//  Shelby
//
//  Created by David Kay on 9/28/11.
//  Copyright (c) 2011 Gargoyle Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface User : NSManagedObject {
@private
}
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * shelbyId;
@property (nonatomic, retain) NSNumber * auth_twitter;
@property (nonatomic, retain) NSNumber * auth_facebook;
@property (nonatomic, retain) NSNumber * auth_tumblr;
@property (nonatomic, retain) NSSet *channels;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addChannelsObject:(Channel *)value;
- (void)removeChannelsObject:(Channel *)value;
- (void)addChannels:(NSSet *)values;
- (void)removeChannels:(NSSet *)values;
@end

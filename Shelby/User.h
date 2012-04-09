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
}

@property (nonatomic, retain) NSData   *image;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *shelbyId;
@property (nonatomic, retain) NSNumber *auth_twitter;
@property (nonatomic, retain) NSNumber *auth_facebook;
@property (nonatomic, retain) NSNumber *auth_tumblr;
@property (nonatomic, retain) NSSet    *channels;

- (void)populateFromApiJSONDictionary:(NSDictionary *)dict;

@end

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
}

@property (nonatomic, copy) NSString *shelbyId;
@property (nonatomic, copy) NSString *name;
@property (strong, nonatomic) NSNumber *public;
@property (strong, nonatomic) User     *user;
@property (strong, nonatomic) NSSet    *broadcasts;

- (void)populateFromApiJSONDictionary:(NSDictionary *)dict;

@end
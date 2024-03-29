//
//  Channel.m
//  Shelby
//
//  Created by David Kay on 9/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Channel.h"
#import "User.h"

@implementation Channel

@dynamic shelbyId;
@dynamic name;
@dynamic public;
@dynamic user;
@dynamic broadcasts;

- (void)populateFromApiJSONDictionary:(NSDictionary *)dict
{
    NSNumber *public = [dict objectForKey:@"public"];
    if (NOT_NULL(public)) {
        self.public = [NSNumber numberWithBool:[public boolValue]];
    }

    SET_IF_NOT_NULL(self.name,              [dict objectForKey:@"name"])
    SET_IF_NOT_NULL(self.shelbyId,          [dict objectForKey:@"_id"])
}

@end
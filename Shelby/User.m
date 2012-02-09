//
//  User.m
//  Shelby
//
//  Created by David Kay on 9/28/11.
//  Copyright (c) 2011 Gargoyle Software. All rights reserved.
//

#import "User.h"
#import "Channel.h"

@implementation User

@dynamic image;
@dynamic imageUrl;
@dynamic name;
@dynamic nickname;
@dynamic shelbyId;
@dynamic auth_twitter;
@dynamic auth_facebook;
@dynamic auth_tumblr;
@dynamic channels;

- (void)populateFromApiJSONDictionary:(NSDictionary *)dict;
{   
    SET_IF_NOT_NULL(self.name, [dict objectForKey:@"name"])
    SET_IF_NOT_NULL(self.nickname, [dict objectForKey:@"nickname"])
    SET_IF_NOT_NULL(self.imageUrl, [dict objectForKey:@"user_image"])
    SET_IF_NOT_NULL(self.shelbyId, [dict objectForKey:@"_id"])
}


@end

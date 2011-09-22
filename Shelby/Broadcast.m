//
//  Broadcast.m
//  Shelby
//
//  Created by David Kay on 9/22/11.
//  Copyright (c) 2011 Gargoyle Software. All rights reserved.
//

#import "Broadcast.h"
#import "Channel.h"


@implementation Broadcast
@dynamic liked;
@dynamic origin;
@dynamic provider;
@dynamic providerId;
@dynamic sharerComment;
@dynamic sharerImage;
@dynamic sharerImageUrl;
@dynamic sharerName;
@dynamic shelbyId;
@dynamic thumbnailImage;
@dynamic thumbnailImageUrl;
@dynamic title;
@dynamic url;
@dynamic channel;

- (NSString *)description {

    NSMutableArray *array = [NSMutableArray array];
    [array addObject: [NSString stringWithFormat: @"title: %@", self.title]];
    [array addObject: [NSString stringWithFormat: @"url: %@", self.url]];
    [array addObject: [NSString stringWithFormat: @"shelbyId: %@", self.shelbyId]];
    [array addObject: [NSString stringWithFormat: @"liked: %d", [self.liked boolValue]]];

    NSString *complete = @"";
    for (NSString *string in array) {
        complete = [complete stringByAppendingString: string];
    }
    return complete;
}

@end

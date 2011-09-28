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

@dynamic channel;

@dynamic createdAt;
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

- (void)populateFromApiJSONDictionary:(NSDictionary *)dict;
{
    //API sends us dates in this format, basically UTC / GMT format
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
    //self.channel filled in elsewhere, references NSMangedObject in CoreData
    if (NOT_NULL([dict objectForKey: @"created_at"])) {
        self.createdAt =                    [dateFormatter dateFromString:[dict objectForKey: @"created_at"]];
    }
    
    NSNumber *liked = [dict objectForKey: @"liked_by_owner"];
    if (NOT_NULL(liked) && [liked boolValue]) {
        self.liked = [NSNumber numberWithBool: YES];
    } else {
        self.liked = [NSNumber numberWithBool: NO];
    }
                      
    SET_IF_NOT_NULL(self.origin,            [dict objectForKey: @"video_origin"])
    SET_IF_NOT_NULL(self.provider,          [dict objectForKey: @"video_provider_name"])
    SET_IF_NOT_NULL(self.providerId,        [dict objectForKey: @"video_id_at_provider"])
    SET_IF_NOT_NULL(self.sharerComment,     [dict objectForKey: @"description"])
    //self.sharerImage not provided by API
    SET_IF_NOT_NULL(self.sharerImageUrl,    [dict objectForKey: @"video_originator_user_image"])
    SET_IF_NOT_NULL(self.sharerName,        [dict objectForKey: @"video_originator_user_nickname"])
    SET_IF_NOT_NULL(self.shelbyId,          [dict objectForKey: @"_id"])
    //self.thumbnailImage not provided by API
    SET_IF_NOT_NULL(self.thumbnailImageUrl, [dict objectForKey: @"video_thumbnail_url"])
    SET_IF_NOT_NULL(self.title,             [dict objectForKey: @"video_title"])
}

@end

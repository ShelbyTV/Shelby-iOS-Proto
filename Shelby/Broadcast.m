//
//  Broadcast.m
//  Shelby
//
//  Created by David Kay on 9/22/11.
//  Copyright (c) 2011 Gargoyle Software. All rights reserved.
//

#import "Broadcast.h"
#import "Enums.h"

@implementation Broadcast

@dynamic channel;
@dynamic sharerImage;
@dynamic thumbnailImage;

@dynamic createdAt;
@dynamic liked;
@dynamic watchLater;
@dynamic origin;
@dynamic provider;
@dynamic providerId;
@dynamic sharerComment;
@dynamic sharerImageUrl;
@dynamic sharerName;
@dynamic shelbyId;
@dynamic shortPermalink;
@dynamic thumbnailImageUrl;
@dynamic title;
@dynamic watched;
@dynamic isPlayable;

// initialize isPlayable state only on object creation
- (void) awakeFromInsert
{
    [super awakeFromInsert];
    
    self.isPlayable = [NSNumber numberWithInt:PLAYABLE_UNSET];
}

- (void)populateFromApiJSONDictionary:(NSDictionary *)dict;
{    
    //API sends us dates in this format, basically UTC / GMT format
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
   
    if (NOT_NULL([dict objectForKey:@"created_at"])) {
        self.createdAt = [dateFormatter dateFromString:[dict objectForKey: @"created_at"]];
    }
    
    NSNumber *liked = [dict objectForKey:@"liked_by_owner"];
    if (NOT_NULL(liked)) {
        self.liked = [NSNumber numberWithBool:[liked boolValue]];
    }
    
    NSNumber *watched = [dict objectForKey:@"watched_by_owner"];
    if (NOT_NULL(watched)) {
        self.watched = [NSNumber numberWithBool:[watched boolValue]];
    }
    
    NSNumber *watchLater = [dict objectForKey:@"owner_watch_later"];
    if (NOT_NULL(watchLater)) {
        self.watchLater = [NSNumber numberWithBool:[watchLater boolValue]];
    }
                      
    SET_IF_NOT_NULL(self.origin,            [dict objectForKey:@"video_origin"])
    SET_IF_NOT_NULL(self.provider,          [dict objectForKey:@"video_provider_name"])
    SET_IF_NOT_NULL(self.providerId,        [dict objectForKey:@"video_id_at_provider"])
    SET_IF_NOT_NULL(self.sharerComment,     [dict objectForKey:@"description"])
    SET_IF_NOT_NULL(self.sharerImageUrl,    [dict objectForKey:@"video_originator_user_image"])
    SET_IF_NOT_NULL(self.sharerName,        [dict objectForKey:@"video_originator_user_nickname"])
    SET_IF_NOT_NULL(self.shelbyId,          [dict objectForKey:@"_id"])
    SET_IF_NOT_NULL(self.thumbnailImageUrl, [dict objectForKey:@"video_thumbnail_url"])
    SET_IF_NOT_NULL(self.title,             [dict objectForKey:@"video_title"])
}

@end

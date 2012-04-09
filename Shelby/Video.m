//
//  Video.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "Video.h"
#import "Broadcast.h"
#import "VideoTableViewCellConstants.h"
#import "VideoHelper.h"

@implementation Video

@synthesize provider;
@synthesize providerId;
@synthesize contentURL;
@synthesize thumbnailURL;
@synthesize thumbnailImage;
@synthesize title;
@synthesize sharer;
@synthesize sharerComment;
@synthesize sharerImageURL;
@synthesize sharerImage;
@synthesize source;
@synthesize createdAt;
@synthesize shelbyId;
@synthesize isLiked;
@synthesize isWatchLater;
@synthesize isWatched;
@synthesize cellHeightAllComments;
@synthesize allComments;
@synthesize cellHeightCurrent;
@synthesize currentlyPlaying;
@synthesize isPlayable;

- (id)initWithBroadcast:(Broadcast *)broadcast
{
    self = [super init];
    
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.cellHeightCurrent = IPAD_CELL_HEIGHT;
        } else {
            self.cellHeightCurrent = IPHONE_CELL_HEIGHT;
        }

        NSString *sharerName = [broadcast.sharerName uppercaseString];
        if ([broadcast.origin isEqualToString:@"twitter"]) {
            sharerName = [NSString stringWithFormat:@"@%@", sharerName];
        }
        
        if (NOT_NULL(broadcast.thumbnailImageUrl)) self.thumbnailURL = [NSURL URLWithString:broadcast.thumbnailImageUrl];
        if (NOT_NULL(broadcast.sharerImageUrl)) self.sharerImageURL = [NSURL URLWithString:broadcast.sharerImageUrl];

        SET_IF_NOT_NULL(self.provider, broadcast.provider);
        SET_IF_NOT_NULL(self.providerId, broadcast.providerId);
        SET_IF_NOT_NULL(self.shelbyId, broadcast.shelbyId);
        SET_IF_NOT_NULL(self.title, broadcast.title)
        SET_IF_NOT_NULL(self.sharer, sharerName)
        SET_IF_NOT_NULL(self.sharerComment, broadcast.sharerComment)
        SET_IF_NOT_NULL(self.source, broadcast.origin)
        SET_IF_NOT_NULL(self.createdAt, broadcast.createdAt)
        
        if (NOT_NULL(broadcast.liked)) self.isLiked = [broadcast.liked boolValue];
        if (NOT_NULL(broadcast.watchLater)) self.isWatchLater = [broadcast.watchLater boolValue];
        if (NOT_NULL(broadcast.watched)) self.isWatched = [broadcast.watched boolValue];
        if (NOT_NULL(broadcast.isPlayable)) self.isPlayable = [broadcast.isPlayable intValue];
    }
    
    return self;
}

- (NSString *)dupeKey
{
    return [VideoHelper dupeKeyWithProvider:self.provider withId:self.providerId];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@""
            "provider: %@\n"
            "providerId: %@\n"
            "contentURL: %@\n"
            "thumbnailURL: %@\n"
            "thumbnailImage: not displaying\n"
            "title: %@\n"
            "sharer: %@\n"
            "sharerComment: %@\n"
            "sharerImageURL: %@\n"
            "sharerImage: not displaying\n"
            "source: %@\n"
            "shelbyId: %@\n"
            "createdAt: not displaying\n"
            "isLiked: %@\n"
            "isWatchLater: %@\n"
            "isWatched: %@\n"
            "cellHeightAllComments: %f\n"
            "allComments: %@\n"
            "cellHeightCurrent: %f\n",
            self.provider, 
            self.providerId, 
            [self.contentURL description], 
            [self.thumbnailURL description],
            self.title,
            self.sharer,
            self.sharerComment,
            [self.sharerImageURL description],
            self.source,
            self.shelbyId,
            self.isLiked ? @"TRUE" : @"FALSE",
            self.isWatchLater ?  @"TRUE" : @"FALSE",
            self.isWatched ? @"TRUE" : @"FALSE",
            self.cellHeightAllComments,
            self.allComments ? @"TRUE" : @"FALSE",
            self.cellHeightCurrent]; 
}

- (NSComparisonResult)compareByCreationTime:(Video *)otherVideo
{
	return [self.createdAt compare:otherVideo.createdAt];
}

@end

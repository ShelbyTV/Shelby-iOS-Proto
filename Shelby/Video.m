//
//  Video.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "Video.h"


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
@synthesize shortPermalink;
@synthesize isLiked;
@synthesize isWatchLater;
@synthesize isWatched;
@synthesize cellHeightAllComments;
@synthesize allComments;
@synthesize cellHeightCurrent;
@synthesize currentlyPlaying;

- (void) dealloc
{
    provider = nil;
    providerId = nil;
    contentURL = nil;
    thumbnailURL = nil;
    thumbnailImage = nil;
    title = nil;
    sharer = nil;
    sharerComment = nil;
    sharerImageURL = nil;
    sharerImage = nil;
    source = nil;
    shelbyId = nil;
    shortPermalink = nil;
    createdAt = nil;
    
    [super dealloc];
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
            "shortPermalink: %@\n"
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
            self.shortPermalink,
            self.isLiked ? @"TRUE" : @"FALSE",
            self.isWatchLater ?  @"TRUE" : @"FALSE",
            self.isWatched ? @"TRUE" : @"FALSE",
            self.cellHeightAllComments,
            self.allComments ? @"TRUE" : @"FALSE",
            self.cellHeightCurrent]; 
}

@end

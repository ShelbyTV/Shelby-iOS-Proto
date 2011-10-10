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
@synthesize hasBeenDisplayed;
@synthesize allComments;
@synthesize cellHeightCurrent;

- (void) dealloc
{
    [provider release];    
    [providerId release];
    [contentURL release];
    [thumbnailURL release];
    [thumbnailImage release];
    [title release];
    [sharer release];
    [sharerComment release];
    [sharerImageURL release];
    [sharerImage release];
    [source release];
    [createdAt release];
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"provider: %@\nproviderId: %@\ncontentURL: %@\nthumbnailURL: %@\nthumbnailImage: not displaying\ntitle: %@\nsharer: %@\nsharerComment: %@\nsharerImageURL: %@\nsharerImage: not displaying\nsource: %@\nshelbyId: %@\nshortPermalink: %@\ncreatedAt: not displaying\nisLiked: %@\nisWatched: %@\ncellHeightAllComments: %f\nhasBeenDisplayed: %@\nallComments: %@\ncellHeightCurrent: %f\n", self.provider, self.providerId, [self.contentURL description], [self.thumbnailURL description], self.title, self.sharer, self.sharerComment, [self.sharerImageURL description], self.source, self.shelbyId, self.shortPermalink, self.isLiked ? @"TRUE" : @"FALSE", self.isWatched ? @"TRUE" : @"FALSE", self.cellHeightAllComments, self.hasBeenDisplayed ? @"TRUE" : @"FALSE", self.allComments ? @"TRUE" : @"FALSE",  self.cellHeightCurrent]; 
}

@end

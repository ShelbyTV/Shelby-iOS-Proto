//
//  Video.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "Video.h"


@implementation Video

@synthesize youTubeVideoInfoURL, contentURL, thumbnailURL, thumbnailImage, title, sharer, sharerComment, sharerImageURL, sharerImage, source, createdAt, shelbyId, isLiked, isWatched;

- (void) dealloc
{
    [youTubeVideoInfoURL release];
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

@end

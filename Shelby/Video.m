//
//  Video.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "Video.h"


@implementation Video

@synthesize youTubeVideoInfoURL;
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
@synthesize isWatched;
@synthesize arrayGeneration;


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

//
//  VideoDataPoller.m
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoDataPoller.h"

@implementation VideoDataPoller

- (id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;    
}










/*
 * This is probably the most complicated piece of the entire iOS app.
 * Basically what we're trying to do here is process any new videos, make
 * sure we try not to download anything we don't have to, make sure any
 * videos we show are playable on mobile devices, and try to update the UI
 * as quickly and incrementally as possible for low latency.
 *
 * One thing we have to keep in mind through all of this is that accessing
 * CoreData for hundreds 
 */ 





@end

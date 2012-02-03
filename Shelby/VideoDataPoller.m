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
- (void)loadNewBroadcastsFromJSON:(NSTimer*)timer
{
//
//    
//    // new JSON data
//    NSArray *jsonDictionariesArray = [timer.userInfo objectForKey:@"jsonDictionariesArray"];
//    
//    @synchronized(tableVideos)
//    {
//        // get rid of old temporary data
//        [self clearTempDataStructuresForNewBroadcasts];
//        
//        // fetch old broadcasts from CoreData
//        NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
//        [broadcasts addObjectsFromArray:[self fetchBroadcastsFromCoreDataContext:context]];
//        
//        Channel *publicChannel = [self fetchPublicChannelFromCoreDataContext:context];
//        
//        // go through new JSON broadcast data and identify ones with same shelbyIDs as old broadcasts
//        // if shelbyID already exists, update old broadcast object with any new data
//        // if doesn't already exist, create new Broadcast in CoreData with new JSON data
//        NSDictionary *jsonBroadcasts = [self addOrUpdateBroadcasts:broadcasts 
//                                                       withNewJSON:jsonDictionariesArray 
//                                                       withChannel:publicChannel
//                                                       withContext:context];
//        
//        // sort array by createdAt date
//        [self sortBroadcasts:broadcasts];
//        
//        // determine numToKeep and numToDelete
//        // iterate through and delete broadcasts from CoreData and array somehow?
//        [self removeExtraBroadcasts:broadcasts withNewJSON:jsonBroadcasts withContext:context];
//        
//        [operationQueue setSuspended:TRUE];
//        
//        // iterate through sorted broadcast array, finding dupes, creating operationQueue jobs, etc.
//        [self processBroadcastArray:broadcasts];
//        
//        // save CoreData context
//        [CoreDataHelper saveContextAndLogErrors:context];
//        
//        [operationQueue setSuspended:FALSE];
//    }
//    
//    [context release];
}




@end

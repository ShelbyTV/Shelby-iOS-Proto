//
//  VideoData.h
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video;

@interface VideoData : NSObject
{
    NSOperationQueue *operationQueue;
    NSMutableDictionary *videoDupeDict;
    NSMutableArray *uniqueVideoKeys;
}

- (void)loadFromCoreData;

- (NSURL *)getVideoContentURL:(Video *)video;
- (NSArray *)videoDupes:(Video *)video;

@end

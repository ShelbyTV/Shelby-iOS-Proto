//
//  VideoCoreDataInterface.h
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video;

@interface VideoCoreDataInterface : NSObject

+ (NSArray *)fetchBroadcastsFromCoreDataContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchKeyBroadcastFieldDictionariesFromCoreDataContext:(NSManagedObjectContext *)context;

+ (void)storeLikeStatus:(Video *)video;
+ (void)storeWatchLaterStatus:(Video *)video;
+ (void)storeWatchStatus:(Video *)video;

+ (void)loadSharerImageFromCoreData:(Video *)video;
+ (void)loadVideoThumbnailFromCoreData:(Video *)video;

@end

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

+ (VideoCoreDataInterface *)singleton;

- (NSArray *)fetchBroadcastsFromCoreDataContext:(NSManagedObjectContext *)context;

- (void)storeLikeStatus:(Video *)video;
- (void)storeWatchLaterStatus:(Video *)video;
- (void)storeWatchStatus:(Video *)video;



@end

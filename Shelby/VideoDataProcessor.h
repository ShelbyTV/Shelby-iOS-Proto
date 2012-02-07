//
//  VideoDataProcessor.h
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video;

@protocol VideoDataProcessorDelegate

- (void)newPlayableVideoAvailable:(Video *)video;
- (void)storePlayableStatus:(Video *)video;

@end

@interface VideoDataProcessor : NSObject

@property (assign) id <VideoDataProcessorDelegate> delegate;

@end

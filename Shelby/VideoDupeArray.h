//
//  VideoDupeArray.h
//  Shelby
//
//  Created by Mark Johnson on 2/16/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video;

@interface VideoDupeArray : NSObject

@property (strong, nonatomic, readonly) NSDate *latestCreationDate;

- (void)removeVideoWithShelbyId:(NSString *)shelbyId;
- (void)addVideo:(Video *)video;
- (NSComparisonResult)compareByCreationTime:(VideoDupeArray *)otherVideoDupeArray;
- (NSArray *)copyOfVideoArray;
- (BOOL)isEmpty;

@end

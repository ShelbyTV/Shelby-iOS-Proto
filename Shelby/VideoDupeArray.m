//
//  VideoDupeArray.m
//  Shelby
//
//  Created by Mark Johnson on 2/16/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoDupeArray.h"
#import "Video.h"

@interface VideoDupeArray ()
@property (nonatomic, strong) NSMutableArray *array;
@property (strong, nonatomic, readwrite) NSDate *latestCreationDate;
@end

@implementation VideoDupeArray

@synthesize array;
@synthesize latestCreationDate;

- (id)init
{
    self = [super init];
    if (self) {
        array = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)addVideo:(Video *)video
{
    @synchronized (self) {
        [self.array addObject:video];
        [self.array sortUsingSelector:@selector(compareByCreationTime:)];
        self.latestCreationDate = ((Video *)[self.array lastObject]).createdAt;
    }
}

- (void)removeVideoWithShelbyId:(NSString *)shelbyId
{
    @synchronized (self) {
        for (Video *video in self.array) {
            if ([video.shelbyId isEqualToString:shelbyId]) {
                [self.array removeObject:video];
                [self.array sortUsingSelector:@selector(compareByCreationTime:)];
                self.latestCreationDate = ((Video *)[self.array lastObject]).createdAt;
                break;
            }
        }
    }
}

- (BOOL)isEmpty
{
    @synchronized(self) {
        return [self.array count] == 0;
    }
}

- (NSComparisonResult)compareByCreationTime:(VideoDupeArray *)otherVideoDupeArray
{
    @synchronized (self) {
        return [otherVideoDupeArray.latestCreationDate compare:self.latestCreationDate];
    }
}

- (NSArray *)copyOfVideoArray
{
    @synchronized (self) {
        return [self.array copy];
    }
}

@end
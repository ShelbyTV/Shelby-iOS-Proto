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
@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, retain, readwrite) NSDate *latestCreationDate;
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

- (void) dealloc
{
    [array release]; array = nil;
    [latestCreationDate release]; latestCreationDate = nil;
    
    [super dealloc];
}

// XXX need to handle removal methods (and updating earliest creation date)

- (void)addVideo:(Video *)video
{
    @synchronized (self) {
        [self.array addObject:video];
        [self.array sortUsingSelector:@selector(compareByCreationTime:)];
        self.latestCreationDate = ((Video *)[self.array lastObject]).createdAt;
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
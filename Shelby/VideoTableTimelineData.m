//
//  VideoTableTimelineData.m
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoTableTimelineData.h"
#import "Video.h"
#import "Enums.h"
#import "DemoMode.h"

@implementation VideoTableTimelineData

- (BOOL)shouldIncludeVideo:(NSArray *)dupeArray
{
    if (![DemoMode passesDemoModeIncludeCheck:dupeArray]) {
        return FALSE;
    }
    
    return ((Video *)[dupeArray objectAtIndex:0]).isPlayable == IS_PLAYABLE;
}

- (void)videosAvailable
{
    if (!postedNotificationOfNewVideosAfterLogin) {
        postedNotificationOfNewVideosAfterLogin = TRUE;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewVideoDataAvailableAfterLogin" object:self];
    }
}

- (void)reset
{
    [super reset];
    
    postedNotificationOfNewVideosAfterLogin = FALSE;
}

@end

//
//  VideoTableWatchLaterData.m
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoTableWatchLaterData.h"
#import "Video.h"
#import "Enums.h"
#import "DemoMode.h"

@implementation VideoTableWatchLaterData

- (BOOL)shouldIncludeVideo:(NSArray *)dupeArray
{
    if (![DemoMode passesDemoModeIncludeCheck:dupeArray]) {
        return FALSE;
    }
    
    if (((Video *)[dupeArray objectAtIndex:0]).isPlayable != IS_PLAYABLE) {
        return FALSE;
    }
    
    for (Video *video in dupeArray) {
        if (video.isWatchLater) {
            return TRUE;
        }
    }
    
    return FALSE;
}

@end

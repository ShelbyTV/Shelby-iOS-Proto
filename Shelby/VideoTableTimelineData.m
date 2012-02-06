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

@implementation VideoTableTimelineData

- (BOOL)shouldIncludeVideo:(NSArray *)dupeArray
{
//    if ([ShelbyApp sharedApp].demoModeEnabled) {
//        BOOL videoHasContentURL = FALSE;
//        NSURL *dupeContentURL = nil;
//        for (Video *video in dupeArray) {
//            if (video.contentURL != nil) {
//                videoHasContentURL = TRUE;
//                dupeContentURL = video.contentURL;
//                break;
//            }
//        }
//        
//        if (videoHasContentURL) {
//            for (Video *video in dupeArray) {
//                video.contentURL = dupeContentURL;
//            }
//        } else {
//            return FALSE;
//        }
//    }
//    

    return ((Video *)[dupeArray objectAtIndex:0]).isPlayable == IS_PLAYABLE;
}



@end

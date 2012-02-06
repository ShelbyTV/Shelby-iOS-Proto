//
//  VideoGuideSearchView.h
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoGuideView.h"

@class VideoTableSearchData;

@interface VideoGuideSearchView : VideoGuideView
{
    VideoTableSearchData *_videoTableSearchData;
}

- (void)performSearch:(NSString *)searchText;

@end

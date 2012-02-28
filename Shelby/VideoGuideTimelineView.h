//
//  VideoGuideTimelineView.h
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoGuideView.h"

@class VideoTableTimelineData;

@interface VideoGuideTimelineView : VideoGuideView
{
    VideoTableTimelineData *_videoTableTimelineData;
    
    UIView *_updatesContainer;
    UILabel *_updatesLabel;
    UIImageView *_updatesImageView;
    UIView *_colorSeparator;
    
    BOOL _updatesVisible;
}

@end

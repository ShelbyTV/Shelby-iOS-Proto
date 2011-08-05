//
//  VideoPlayerControlBar.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/5/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoProgressBar.h"

@class VideoProgressBar;
@class VideoPlayerControlBar;

@protocol VideoPlayerControlBarDelegate 

- (void)controlBarPlayButtonWasPressed:(VideoPlayerControlBar *)controlBar;
- (void)controlBarChangedTime:(VideoPlayerControlBar *)controlBar time:(float)time;

@end

@interface VideoPlayerControlBar : UIView <VideoProgressBarDelegate> {
    IBOutlet UIButton *_favoriteButton;
    IBOutlet UIButton *_shareButton;
    IBOutlet UIButton *_playButton;
    IBOutlet UIButton *_fullscreenButton;
    IBOutlet UIButton *_soundButton;
    
    IBOutlet VideoProgressBar *_progressBar;

}

@property (assign) id <VideoPlayerControlBarDelegate> delegate;
@property (readwrite) float progress;
@property (readwrite) float duration;

@end

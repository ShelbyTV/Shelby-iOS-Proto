//
//  VideoProgressBar.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoPlayerProgressBar;

@protocol VideoProgressBarDelegate

- (void)videoProgressBarWasAdjusted:(VideoPlayerProgressBar *)videoProgressBar value:(float)value;

@end

/*
 * Presents a visual progress bar of video playback to the user.
 */
@interface VideoPlayerProgressBar : UIView {
  // For now, let's just use the factory appearance.
  UISlider *_slider;
  UILabel *_label;
  // This lets us know that somebody is manipulating the slider by hand.
  BOOL _adjustingSlider;

}

@property(assign) id <VideoProgressBarDelegate> delegate;
@property(readwrite) float duration;

- (void)setProgress:(float)progress;
- (float)progress;

@end

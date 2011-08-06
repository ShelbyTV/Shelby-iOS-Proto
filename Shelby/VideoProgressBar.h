//
//  VideoProgressBar.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoProgressBar;

@protocol VideoProgressBarDelegate

- (void)videoProgressBarWasAdjusted:(VideoProgressBar *)videoProgressBar value:(float)value;

@end

/*
 * Presents a visual progress bar of playback to the user.
 */
@interface VideoProgressBar : UIView {
  // For now, let's just use the factory appearance.
  UISlider *_slider;
  // This lets us know that
  BOOL _adjustingSlider;
}

@property(assign) id <VideoProgressBarDelegate> delegate;
@property(readwrite) float duration;

- (void)setProgress:(float)progress;
- (float)progress;

@end

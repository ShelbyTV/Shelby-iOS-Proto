//
//  VideoProgressBar.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * Presents a visual progress bar of playback to the user.
 */
@interface VideoProgressBar : UIView {
  // For now, let's just use the factory appearance.
  UIProgressView *_progressView;
}

- (void)setProgress:(float)progress;
- (float)progress;

@end

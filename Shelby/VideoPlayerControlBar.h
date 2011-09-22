//
//  VideoPlayerControlBar.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/5/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayerProgressBar.h"

@class VideoPlayerProgressBar;
@class VideoPlayerControlBar;

@protocol VideoPlayerControlBarDelegate 

- (void)controlBarPlayButtonWasPressed:(VideoPlayerControlBar *)controlBar;
- (void)controlBarShareButtonWasPressed:(VideoPlayerControlBar *)controlBar;
- (void)controlBarFavoriteButtonWasPressed:(VideoPlayerControlBar *)controlBar;
- (void)controlBarFullscreenButtonWasPressed:(VideoPlayerControlBar *)controlBar;
- (void)controlBarSoundButtonWasPressed:(VideoPlayerControlBar *)controlBar;
- (void)controlBarChangedTime:(VideoPlayerControlBar *)controlBar time:(float)time;

@end

@interface VideoPlayerControlBar : UIView <VideoProgressBarDelegate> {
    IBOutlet UIButton *_favoriteButton;
    IBOutlet UIButton *_shareButton;
    IBOutlet UIButton *_playButton;
    IBOutlet UIButton *_fullscreenButton;
    IBOutlet UIButton *_soundButton;
    
    IBOutlet VideoPlayerProgressBar *_progressBar;

    BOOL _initialized;
}

@property (assign) id <VideoPlayerControlBarDelegate> delegate;
@property (readwrite) float progress;
@property (readwrite) float duration;

+ (VideoPlayerControlBar *)controlBarFromNib;

- (void)setPlayButtonIcon:(UIImage *)image;
- (IBAction)playButtonWasPressed:(id)sender;
- (IBAction)shareButtonWasPressed:(id)sender;
- (IBAction)fullscreenButtonWasPressed:(id)sender;
- (IBAction)favoriteButtonWasPressed:(id)sender;
- (IBAction)soundButtonWasPressed:(id)sender;

@end

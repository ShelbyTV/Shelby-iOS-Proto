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
- (void)controlBarWatchLaterButtonWasPressed:(VideoPlayerControlBar *)controlBar;
- (void)controlBarFullscreenButtonWasPressed:(VideoPlayerControlBar *)controlBar;
- (void)controlBarChangedTimeManually:(VideoPlayerControlBar *)controlBar time:(float)time;

@end

@interface VideoPlayerControlBar : UIView <VideoProgressBarDelegate> {
    IBOutlet UIButton *_watchLaterButton;
    IBOutlet UIButton *_favoriteButton;
    IBOutlet UIButton *_shareButton;
    IBOutlet UIButton *_playButton;
    IBOutlet UIButton *_fullscreenButton;
    
    IBOutlet VideoPlayerProgressBar *_progressBar;

    BOOL _initialized;
    BOOL _remoteModeButton;
}

@property (assign) id <VideoPlayerControlBarDelegate> delegate;
@property (readwrite) float progress;
@property (readwrite) float duration;
@property (readwrite) BOOL tv;

+ (VideoPlayerControlBar *)controlBarFromTVNib:(CGRect)screenBounds;
+ (VideoPlayerControlBar *)controlBarFromNib;

- (BOOL)isFavoriteButtonSelected;
- (void)setFavoriteButtonSelected:(BOOL)selected;
- (BOOL)isWatchLaterButtonSelected;
- (void)setWatchLaterButtonSelected:(BOOL)selected;
- (IBAction)playButtonWasPressed:(id)sender;
- (IBAction)shareButtonWasPressed:(id)sender;
- (IBAction)fullscreenButtonWasPressed:(id)sender;
- (IBAction)favoriteButtonWasPressed:(id)sender;
- (IBAction)watchLaterButtonWasPressed:(id)sender;

- (void)showPlayButtonIcon;
- (void)showPauseButtonIcon;

- (void)showFullscreenExpandButtonIcon;
- (void)showFullscreenContractButtonIcon;
- (void)showFullscreenRemoteModeButtonIcon;

- (void)adjustProgressBarForTV;

@end

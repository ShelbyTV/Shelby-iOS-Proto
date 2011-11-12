//
//  VideoPlayer.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoPlayerProgressBar.h"
#import "VideoPlayerControlBar.h"

@class VideoPlayer;
@class VideoPlayerProgressBar;
@class VideoPlayerTitleBar;
@class VideoPlayerFooterBar;
@class VideoPlayerControlBar;
@class Video;

@protocol VideoPlayerDelegate

- (void)videoPlayerFullscreenButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerNextButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerPrevButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerLikeButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerWatchLaterButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerShareButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerVideoDidFinish:(VideoPlayer *)videoPlayer;
- (void)updateVideoTableCell:(Video *)video;


@end

@interface VideoPlayer : UIView <VideoPlayerControlBarDelegate, UIGestureRecognizerDelegate>
{
    // Current video's duration.
    float _duration;
    // Is the user currently changing the video?
    BOOL _changingVideo;
    // Are the controls currently visible?
    BOOL _controlsVisible;
    // When did the controls last become visible?
    double _lastButtonPressOrControlsVisible;
    
    double _lastTouchesBegan;
    double _lastPlayVideo;
    double _lastDidFinish;
    
    bool _wasPlayingBeforeShare;
    
    UIButton *_nextButton;
    UIButton *_prevButton;
    
    UIView *_gestureView;
    UISwipeGestureRecognizer *leftSwipeRecognizer;
    UISwipeGestureRecognizer *rightSwipeRecognizer;
    
    BOOL _fullscreen;
    BOOL _paused;
    BOOL _stoppedIntentionally;
    
    BOOL _touchOccurring;
    
    VideoPlayerControlBar *_controlBar;
    MPMoviePlayerController *_moviePlayer;

    NSArray *_controls;
    
    UIView *_bgView;
    
    Video *_currentVideo;
    BOOL _currentVideoWatchLaterAtStart;
    BOOL _currentVideoUnwatchLaterSent;
}

@property (assign) id <VideoPlayerDelegate> delegate;
@property (readonly) BOOL isIdle;
@property (nonatomic, retain) IBOutlet VideoPlayerTitleBar *titleBar;
@property (nonatomic, retain) IBOutlet VideoPlayerFooterBar *footerBar;
@property (nonatomic, readonly) MPMoviePlayerController *moviePlayer;
@property (nonatomic, readwrite, retain) Video *currentVideo;

- (void)setCurrentVideo:(Video *)currentVideo;
- (Video *)getCurrentVideo;

- (void)play;
- (void)pause;
- (void)stop;
- (void)playVideo:(Video *)video;
- (void)reset;
- (void)setFullscreen:(BOOL)fullscreen;
- (BOOL)isFavoriteButtonSelected;
- (BOOL)isWatchLaterButtonSelected;
- (void)resumeAfterCloseShareView;

@end

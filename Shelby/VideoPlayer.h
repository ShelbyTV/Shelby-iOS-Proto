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
- (void)videoPlayerVideoDidFinish:(VideoPlayer *)videoPlayer;

@end

@interface VideoPlayer : UIView <VideoPlayerControlBarDelegate, UIGestureRecognizerDelegate> {
    // Current video's duration.
    float _duration;
    // Is the user currently changing the video?
    BOOL _changingVideo;
    // Are the controls currently visible?
    BOOL _controlsVisible;

    // UI
    UIButton *_nextButton;
    UIButton *_prevButton;

    VideoPlayerControlBar *_controlBar;
    MPMoviePlayerController *_moviePlayer;

    NSArray *_controls;
}

@property (assign) id<VideoPlayerDelegate> delegate;
@property (nonatomic, retain) IBOutlet VideoPlayerTitleBar *titleBar;
@property (nonatomic, retain) IBOutlet VideoPlayerFooterBar *footerBar;
@property (nonatomic, readonly) MPMoviePlayerController *moviePlayer;

- (void)play;
- (void)pause;
- (void)stop;
- (void)playVideo:(Video *)video;

@end

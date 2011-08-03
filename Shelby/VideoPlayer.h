//
//  VideoPlayer.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h> 
#import "VideoProgressBar.h"

@class VideoPlayer;
@class VideoProgressBar;
@class VideoPlayerTitleBar;
@class VideoPlayerControlBar;

@protocol VideoPlayerDelegate 

- (void)videoPlayerPlayButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerNextButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerPrevButtonWasPressed:(VideoPlayer *)videoPlayer;

@end

@interface VideoPlayer : UIView <VideoProgressBarDelegate> {
    // State
    float _duration;

    // UI
    UIButton *_playButton;
    UIButton *_nextButton;
    UIButton *_prevButton;

    VideoProgressBar *_progressBar;
    VideoPlayerControlBar *_controlBar;

    MPMoviePlayerController *_moviePlayer;
}

@property (assign) id<VideoPlayerDelegate> delegate;
@property (nonatomic, retain) IBOutlet VideoPlayerTitleBar *titleBar;

- (void)play;
- (void)pause;
- (void)playContentURL:(NSURL *)url;

@end

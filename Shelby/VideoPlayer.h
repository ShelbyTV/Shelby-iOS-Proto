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
@class VideoPlayerControlBar;

@protocol VideoPlayerDelegate 

- (void)videoPlayerNextButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerPrevButtonWasPressed:(VideoPlayer *)videoPlayer;

@end

@interface VideoPlayer : UIView <VideoPlayerControlBarDelegate> {
    // State
    float _duration;

    // UI
    UIButton *_nextButton;
    UIButton *_prevButton;

    VideoPlayerControlBar *_controlBar;

    MPMoviePlayerController *_moviePlayer;
}

@property (assign) id<VideoPlayerDelegate> delegate;
@property (nonatomic, retain) IBOutlet VideoPlayerTitleBar *titleBar;

- (void)play;
- (void)pause;
- (void)playContentURL:(NSURL *)url;

@end

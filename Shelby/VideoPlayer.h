//
//  VideoPlayer.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h> 

@class VideoPlayer;
@class VideoProgressBar;

@protocol VideoPlayerDelegate 

- (void)videoPlayerPlayButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerNextButtonWasPressed:(VideoPlayer *)videoPlayer;
- (void)videoPlayerPrevButtonWasPressed:(VideoPlayer *)videoPlayer;

@end

@interface VideoPlayer : UIView {
    UIButton *_playButton;
    UIButton *_nextButton;
    UIButton *_prevButton;

    VideoProgressBar *_progressBar;

    MPMoviePlayerController *_moviePlayer;
}

@property (assign) id<VideoPlayerDelegate> delegate;

- (void)play;
- (void)pause;
- (void)playContentURL:(NSURL *)url;

@end

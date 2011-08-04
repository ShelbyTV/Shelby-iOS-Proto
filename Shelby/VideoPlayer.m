//
//  VideoPlayer.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "VideoPlayer.h"
#import "VideoProgressBar.h"

@implementation VideoPlayer

@synthesize delegate;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Buttons.
        _playButton = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
        [_playButton setImage: [UIImage imageNamed: @"ButtonPlay.png"]
                     forState: UIControlStateNormal];
        [_playButton addTarget: self
                        action: @selector(playButtonWasPressed:)
              forControlEvents: UIControlEventTouchUpInside];
        _nextButton = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
        [_nextButton setImage: [UIImage imageNamed: @"ButtonNext.png"]
                     forState: UIControlStateNormal];
        [_nextButton addTarget: self
                        action: @selector(nextButtonWasPressed:)
              forControlEvents: UIControlEventTouchUpInside];
        _prevButton = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
        [_prevButton setImage: [UIImage imageNamed: @"ButtonPrevious.png"]
                     forState: UIControlStateNormal];
        [_prevButton addTarget: self
                        action: @selector(prevButtonWasPressed:)
              forControlEvents: UIControlEventTouchUpInside];
        // Progress Bar.
        _progressBar = [[VideoProgressBar alloc] init];

        // Movie Player.
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: nil]; 

        _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;  // Uniform scale until one dimension fits
        //MPMovieScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
        //MPMovieScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds

        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        
        [self addSubview: _moviePlayer.view];

        [self addSubview: _playButton];
        [self addSubview: _nextButton];
        [self addSubview: _prevButton];
        [self addSubview: _progressBar];

        // Timer.
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - Public Methods

- (void)playContentURL:(NSURL *)url {
    _moviePlayer.contentURL = url;
    [_moviePlayer play];
}

- (void)play {
    [_moviePlayer play];
}

- (void)pause {
    [_moviePlayer pause];
}

- (void)toggleFullscreen {
    [_moviePlayer setFullscreen: !_moviePlayer.isFullscreen
                       animated: YES];
}

#pragma mark - Tick Methods

- (void)updateProgress {
    float currentTime = [_moviePlayer currentPlaybackTime];
    NSLog(@"Current time: %f", currentTime);
}

- (void)timerAction:(NSTimer *)timer {
  [self updateProgress];
}

#pragma mark - Delegate Callbacks

- (IBAction)playButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate videoPlayerPlayButtonWasPressed: self];
    }
    if (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self pause];
    } else {
        [self play];
    }
}

- (IBAction)nextButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate videoPlayerNextButtonWasPressed: self];
    }
}

- (IBAction)prevButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate videoPlayerPrevButtonWasPressed: self];
    }
}

#pragma mark - Layout

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews {
    CGRect frame = self.frame;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;

    const float buttonWidth = 40.0f;
    const float buttonHeight = 40.0f;
    
    self.backgroundColor = [UIColor redColor];
    
    _moviePlayer.view.frame = self.frame;

    // Place next/prev buttons at the sides.
    _prevButton.frame = CGRectMake(0, height / 2, buttonWidth, buttonHeight);
    _nextButton.frame = CGRectMake(width - buttonWidth, height / 2, buttonWidth, buttonHeight);

    // Place playbutton at the bottom center.
    _playButton.frame = CGRectMake(width / 2, height / 2, buttonWidth, buttonHeight);
    
    // Place progressBar at the bottom center.
    _progressBar.frame = CGRectMake(width / 2, height - buttonHeight, 4 * buttonWidth, buttonHeight);
}

#pragma mark - Cleanup

- (void)dealloc {
    //[_playButton removeFromSuperview];
    //[_nextButton removeFromSuperview];
    //[_prevButton removeFromSuperview];

    [_playButton release];
    [_nextButton release];
    [_prevButton release];
    
    [_moviePlayer release];
    [super dealloc];
}

@end

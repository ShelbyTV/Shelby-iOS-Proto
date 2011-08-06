//
//  VideoPlayer.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "VideoPlayer.h"
#import "VideoProgressBar.h"
#import "VideoPlayerTitleBar.h"
#import "VideoPlayerControlBar.h"

@implementation VideoPlayer

@synthesize delegate;
@synthesize titleBar;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Buttons
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

        // Control Bar
        _controlBar = [[VideoPlayerControlBar alloc] init];
        _controlBar.delegate = self;
        
        // Title Bar
        self.titleBar = [[VideoPlayerTitleBar alloc] init];

        // Movie Player
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: nil];
        // Uniform scale until one dimension fits
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;  
        // Hide controls so we can render custom ones.
        _moviePlayer.controlStyle = MPMovieControlStyleNone; 

        // Listen for duration updates.
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(movieDurationAvailable:)
                   name:MPMovieDurationAvailableNotification
                 object:nil];

        // Add views.
        [self addSubview: _moviePlayer.view];

        [self addSubview: self.titleBar];
        [self addSubview: _nextButton];
        [self addSubview: _prevButton];
        [self addSubview: _controlBar];

        // Timer to update the progressBar after each second.
        // TODO: Shut this down when we're not playing a video.
        [NSTimer scheduledTimerWithTimeInterval: 1.0f target: self selector: @selector(timerAction: ) userInfo: nil repeats: YES];
    
    }
    return self;
}

#pragma mark - Public Methods

- (void)playContentURL:(NSURL *)url {
    // Reset our duration.
    _duration = 0.0f;
    // Load the video and play it.
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

#pragma mark - Notification Handlers

- (void) movieDurationAvailable:(NSNotification*)notification {
    _duration = [_moviePlayer duration];
    _controlBar.duration = _duration;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    LOG(@"[VideoPlayer observeValueForKeyPath: %@]", keyPath);
}

#pragma mark - Tick Methods

- (void)updateProgress {
  float currentTime = [_moviePlayer currentPlaybackTime];
  LOG(@"Current time: %f", currentTime);
  _controlBar.progress = currentTime;
}

- (void)timerAction:(NSTimer *)timer {
  [self updateProgress];
}

#pragma mark - VideoProgressBarDelegate Methods

- (void)controlBarChangedTime:(VideoPlayerControlBar *)controlBar time:(float)time {
    LOG(@"videoProgressBarWasAdjusted: %f", time);
    // Update playback time.
    _moviePlayer.currentPlaybackTime = time;

    // Update the progress bar.
    [self updateProgress];
}

#pragma mark - ControlBarDelegate Callbacks

- (void)controlBarPlayButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    if (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self pause];
    } else {
        [self play];
    }
}

#pragma mark - Delegate Callbacks

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
    //CGRect frame = self.frame;
    CGRect frame = self.superview.bounds;
    self.frame = frame;
    LOG(@"[VideoPlayer layoutSubviews]: %@", frame);
    LogRect(@"VideoPlayer", frame);
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;

    const float buttonWidth = 81.0f;
    const float buttonHeight = 81.0f;

    self.backgroundColor = [UIColor redColor];

    _moviePlayer.view.frame = self.frame;

    // Place titleBar at the top center.
    self.titleBar.frame = CGRectMake(width / 8, 0, width * 3 / 4, buttonHeight);

    // Place next/prev buttons at the sides.
    _prevButton.frame = CGRectMake(0, height / 2, buttonWidth, buttonHeight);
    _nextButton.frame = CGRectMake(width - buttonWidth, height / 2, buttonWidth, buttonHeight);

    // Place controlBar at the bottom center.
    _controlBar.frame = CGRectMake(width / 8, height - buttonHeight, width * 3 / 4, buttonHeight);
}

#pragma mark - Cleanup

- (void)dealloc {
    [_nextButton release];
    [_prevButton release];

    [_controlBar release];
    [_moviePlayer release];
    [super dealloc];
}

@end

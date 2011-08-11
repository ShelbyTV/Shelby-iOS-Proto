//
//  VideoPlayer.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "VideoPlayer.h"
#import "VideoPlayerProgressBar.h"
#import "VideoPlayerTitleBar.h"
#import "VideoPlayerControlBar.h"
#import "Video.h"

@implementation VideoPlayer

@synthesize delegate;
@synthesize titleBar;

#pragma mark - Notification Handling

- (void)addNotificationListeners {
    // Listen for duration updates.
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(movieDurationAvailable:)
               name:MPMovieDurationAvailableNotification
             object:nil];

    // Listen for the end of the video.
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(movieDidFinish:)
               name:MPMoviePlayerPlaybackDidFinishNotification
             object:nil];
}

- (void)removeNotificationListeners {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieDurationAvailableNotification object:nil];
}

#pragma mark - Initialization

- (void)initViews {
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
    _controlBar = [VideoPlayerControlBar controlBarFromNib];
    _controlBar.delegate = self;

    // Title Bar
    self.titleBar = [VideoPlayerTitleBar titleBarFromNib];

    // Movie Player
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: nil];
    // Uniform scale until one dimension fits
    _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    // Hide controls so we can render custom ones.
    _moviePlayer.controlStyle = MPMovieControlStyleNone;

    // Add views.
    [self addSubview: _moviePlayer.view];

    [self addSubview: self.titleBar];
    [self addSubview: _nextButton];
    [self addSubview: _prevButton];
    [self addSubview: _controlBar];

    // Timer to update the progressBar after each second.
    // TODO: Shut this down when we're not playing a video.
    [NSTimer scheduledTimerWithTimeInterval: 1.0f target: self selector: @selector(timerAction: ) userInfo: nil repeats: YES];

    [self addNotificationListeners];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // initialise ourselves normally
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - Public Methods

- (void)playVideo:(Video *)video {
    // Set internal lock so our notification doesn't go haywire.
    _changingVideo = YES;

    // Change our titlebar
    self.titleBar.title.text = video.title;
    self.titleBar.sharerPic.image = video.sharerImage;

    // Reset our duration.
    _duration = 0.0f;
    // Load the video and play it.
    _moviePlayer.contentURL = video.contentURL;
    [_moviePlayer play];

    _changingVideo = NO;
}

- (void)play {
    [_moviePlayer play];
}

- (void)pause {
    [_moviePlayer pause];
}

- (void)stop {
    [_moviePlayer stop];
}

- (void)toggleFullscreen {
    [_moviePlayer setFullscreen: !_moviePlayer.isFullscreen
                       animated: YES];
}

#pragma mark - Notification Handlers

- (void)movieDurationAvailable:(NSNotification*)notification {
    _duration = [_moviePlayer duration];
    _controlBar.duration = _duration;
}

- (void)movieDidFinish:(NSNotification*)notification {
    // As long as the user didn't stop the movie intentionally, inform our delegate.
    if (_changingVideo == YES) return;

    if (_moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
        return;
    }

    if (self.delegate) {
        [self.delegate videoPlayerVideoDidFinish: self];
    }
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

/*
 * Currently just a mockup.
 */
- (void)controlBarShareButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    // Show an action sheet for now.
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:nil cancelButtonTitle:@"Cancel Button" destructiveButtonTitle:@"Facebook" otherButtonTitles:@"Twitter", @"Tumblr", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView: self];
    [popupQuery release];
}

/*
 * Currently just a mockup.
 */
- (void)controlBarFavoriteButtonWasPressed:(VideoPlayerControlBar *)controlBar {
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Favorited" message:@"Your friends will see you like this video!"
							delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];

}

- (void)controlBarFullscreenButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    if (self.delegate) {
        [self.delegate videoPlayerFullscreenButtonWasPressed: self];
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
    CGRect frame = self.bounds;
    LogRect(@"VideoPlayer", frame);
    const CGFloat width = frame.size.width;
    const CGFloat height = frame.size.height;

    const float titleBarHeight = 41.0f;
    const CGSize nextPrevSize = CGSizeMake(81, 81);
    const CGSize buttonSize = CGSizeMake(62, 62);

    //self.backgroundColor = [UIColor redColor];

    _moviePlayer.view.frame = self.bounds;

    // Place titleBar at the top center.
    float titleBarX = 20.0f;
    float titleBarWidth = width;
    self.titleBar.frame = CGRectMake(
            titleBarX,
            0,
            titleBarWidth - (2 * titleBarX),
            titleBarHeight
            );

    // Place next/prev buttons at the sides.
    _prevButton.frame = CGRectMake(
            0,
            height / 2 - (nextPrevSize.height / 2),
            nextPrevSize.width,
            nextPrevSize.height
            );
    _nextButton.frame = CGRectMake(
            width - nextPrevSize.width,
            height / 2 - (nextPrevSize.height / 2),
            nextPrevSize.width,
            nextPrevSize.height);

    // Place controlBar at the bottom center.
    float controlBarX = 20.0f;
    float controlBarWidth = width;
    _controlBar.frame = CGRectMake(
            controlBarX,
            height - buttonSize.width,
            controlBarWidth - (2 * controlBarX),
            buttonSize.height
            );
    [_controlBar setNeedsLayout];
}

#pragma mark - Cleanup

- (void)dealloc {

    [self removeNotificationListeners];

    [_nextButton release];
    [_prevButton release];

    [_controlBar release];
    [_moviePlayer release];
    [super dealloc];
}

@end

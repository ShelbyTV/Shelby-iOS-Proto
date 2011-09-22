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
#import "VideoPlayerFooterBar.h"
#import "VideoPlayerControlBar.h"
#import "Video.h"

#import <QuartzCore/QuartzCore.h>

static const float kProgressUpdateInterval = 1.0f;

static const float kProgressUpdateBuffer = 0.25f;

static const float kHideControlsStall = 1.0f;
static const float kHideControlsInterval = 5.0f;
static const float kHideControlsDuration = 0.5f;

static const float kControlBarHeightIpad   = 44.0f;
static const float kControlBarHeightIphone = 88.0f;
static const float kControlBarX            =  0.0f;
static const float kNextPrevXOffset        =  0.0f;

@interface VideoPlayer ()

- (void)drawControls;
- (void)hideControls;

- (void)resetTimer;
- (void)stopTimer;
- (void)beginTimer;

@end

@implementation VideoPlayer

@synthesize delegate;
@synthesize titleBar;
@synthesize footerBar;
@synthesize moviePlayer = _moviePlayer;

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

    // Footer Bar
    self.footerBar = [VideoPlayerFooterBar footerBarFromNib];

    // Movie Player
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: nil];
    // Uniform scale until one dimension fits
    _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    // Hide controls so we can render custom ones.
    _moviePlayer.controlStyle = MPMovieControlStyleNone;

    // Add views.
    [self addSubview: _moviePlayer.view];

    [self addSubview: self.titleBar];
    [self addSubview: self.footerBar];
    [self addSubview: _nextButton];
    [self addSubview: _prevButton];
    [self addSubview: _controlBar];

    _controls = [[NSArray alloc] initWithObjects:
        _nextButton,
        _prevButton,
        _controlBar,
        self.titleBar,
        self.footerBar,
        nil];

    // Timer to update the progressBar after each second.
    // TODO: Shut this down when we're not playing a video. Or replace it with KVO.
    [NSTimer scheduledTimerWithTimeInterval: kProgressUpdateInterval target: self selector: @selector(timerAction: ) userInfo: nil repeats: YES];

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

- (BOOL)isIdle {
    MPMoviePlaybackState state = self.moviePlayer.playbackState;
    if (state == MPMoviePlaybackStateStopped) {
        return YES;
    } else {
        return NO;
    }
}

- (void)fitTitleBarText
{
    /* 
     * These constants are derived from the .xib file.
     */
    const CGFloat textOriginX = 68;
    const CGFloat textOriginY = 15;
    const CGFloat textRightBorder = 20;
    const CGFloat maxTextHeight = 35;
    const CGFloat iPadShelbyLogoOverhang = 68;
    
    CGFloat maxTextWidth = self.titleBar.frame.size.width - textOriginX - textRightBorder;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        /*
         * Right now the iPad app can either be in fullscreen mode OR have a little Shelby logo
         * if a user touched the Shelby logo to slide away the video table. But hopefully
         * we'll consolidate those views to be more like the Shelby-logo-slide and get rid of
         * the fullscreen case.
         *
         * But this doesn't look too bad even if we do keep the fullscreen mode, and just doing
         * this keeps the logic simpler.
         */
        maxTextWidth -= iPadShelbyLogoOverhang;
    }
   
    CGSize textSize = [self.titleBar.title.text sizeWithFont:self.titleBar.title.font
                                           constrainedToSize:CGSizeMake(maxTextWidth, maxTextHeight)
                                               lineBreakMode:UILineBreakModeTailTruncation];
    
    self.titleBar.title.frame = CGRectMake(textOriginX, 
                                           textOriginY, 
                                           textSize.width, 
                                           textSize.height);
}

- (void)playVideo:(Video *)video {
    if (NOTNULL(video)) {
        // Set internal lock so our notification doesn't go haywire.
        _changingVideo = YES;

        // Change our titleBar
        //self.titleBar.title.text = video.sharerComment;
        self.titleBar.title.text = [NSString stringWithFormat: @"%@: %@",
            video.sharer,
            video.sharerComment
                ];
        self.titleBar.sharerPic.image = video.sharerImage;
        [self fitTitleBarText];

        // Change our footerBar.
        self.footerBar.title.text = video.title;

        // Reset our duration.
        _duration = 0.0f;
        // Load the video and play it.
        _moviePlayer.contentURL = video.contentURL;
        [_moviePlayer play];
        [_controlBar setPlayButtonIcon:[UIImage imageNamed:@"ButtonPause"]];

        _changingVideo = NO;

        [self resetTimer];
        //[self beginTimer];
        //[self maintainControls];
        //[self hideControlsWithDelay];
    }
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

#pragma mark - Touch Handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Reset timer.
    [self stopTimer];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // Reset timer.
    [self stopTimer];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Begin timer.
    [self beginTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Begin timer.
    [self beginTimer];
}

#pragma mark - Controls Visibility

- (void)hideControlsWithDelay {
    [NSTimer scheduledTimerWithTimeInterval: kHideControlsInterval target: self selector: @selector(checkHideTime) userInfo: nil repeats: NO];
    _stopTimer = NO;
}

- (void)checkHideTime {
    if (_stopTimer) {
        return;
    }

    double now = CACurrentMediaTime();
    double delta = now - _lastTapTime;
    LOG(@"Hidetime. Now: %f. Then: %f. Delta: %f", now, _lastTapTime, delta);
    if (delta > kHideControlsInterval) {
        [self hideControls];
    } else {
        [NSTimer scheduledTimerWithTimeInterval: kHideControlsStall target: self selector: @selector(checkHideTime) userInfo: nil repeats: NO];
    }
}

- (void)hideControls {
    LOG(@"hideControls");
    //if (_controlsVisible) {
        [UIView animateWithDuration:kHideControlsDuration animations:^{
            for (UIView *control in _controls) {
                control.alpha = 0.0;
            }
        }
        completion:^(BOOL finished){
               if (finished) {
                   _controlsVisible = NO;
                   for (UIView *control in _controls) {
                      //[control setHidden:YES];
                      //control.userInteractionEnabled = NO;
                   }
               }
           }];
    //}
}

- (void)drawControlsWithClose:(BOOL)close {
    //if (!_controlsVisible) {
        for (UIView *control in _controls) {
           //[control setHidden:NO];
            //control.userInteractionEnabled = YES;
        }
        [UIView animateWithDuration:kHideControlsDuration animations:^{
            for (UIView *control in _controls) {
                control.alpha = 1.0;
            }
        }
        completion:^(BOOL finished){
           if (finished) {
               _controlsVisible = YES;
               if (close) {
                   // Set a timer to hide the controls in three seconds.
                   [self hideControlsWithDelay];
               }
           }
       }];
    //}
}

- (void)drawControls {
    LOG(@"drawControls");
    [self drawControlsWithClose: NO];
}

- (void)stopTimer {
    LOG(@"stopTimer");
    [self drawControls];
    _stopTimer = YES;
}

- (void)resetTimer {
    double now = CACurrentMediaTime();
    _lastTapTime = now;
    LOG(@"resetTimer : %f", _lastTapTime);
    if (_controlsVisible) {
    } else {
        [self drawControlsWithClose: YES];
    }
}

- (void)beginTimer {
    LOG(@"beginTimer");
    [self hideControlsWithDelay];
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
  // LOG(@"Current time: %f", currentTime);
  _controlBar.progress = currentTime;
}

- (void)timerAction:(NSTimer *)timer {
    double now = CACurrentMediaTime();
    if (now - _lastTapTime > kProgressUpdateBuffer) {
      [self updateProgress];
    }
}

#pragma mark - VideoProgressBarDelegate Methods

- (void)controlBarChangedTime:(VideoPlayerControlBar *)controlBar time:(float)time {
    LOG(@"videoProgressBarWasAdjusted: %f", time);

    float delta = fabs(time - _moviePlayer.currentPlaybackTime);
    if (delta > 1.0f) {
        // Update playback time.
        _moviePlayer.currentPlaybackTime = time;
        //// Update the progress bar.
        [self updateProgress];
    }

    [self resetTimer];
}

#pragma mark - ControlBarDelegate Callbacks

- (void)controlBarPlayButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    [self resetTimer];
    if (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self pause];
        [controlBar setPlayButtonIcon:[UIImage imageNamed:@"ButtonPlay"]];
    } else {
        [self play];
        [controlBar setPlayButtonIcon:[UIImage imageNamed:@"ButtonPause"]];
    }
}

/*
 * Currently just a mockup.
 */
- (void)controlBarShareButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    [self resetTimer];
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
    [self resetTimer];
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Liked" message:@"Your friends will see you like this video!"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];

}

- (void)controlBarFullscreenButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    [self resetTimer];
    if (self.delegate) {
        [self.delegate videoPlayerFullscreenButtonWasPressed: self];
    }
}

- (void)controlBarSoundButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    [self resetTimer];
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

- (float)nextPrevYOffset {
    float offset;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        offset = -12.0f;
    } else {
        offset = 0;
    }
    return offset;
}


- (float)controlBarHeight {
    float height;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        height = kControlBarHeightIphone;
    } else {
        height = kControlBarHeightIpad;
    }
    return height;
}

- (float)footerBarHeight {
    float height = [self controlBarHeight];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        height = height / 2;
    }

    return height;
}


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

    const float titleBarHeight = 75.0f;
    const CGSize nextPrevSize = CGSizeMake(81, 81);

    _moviePlayer.view.frame = self.bounds;

    self.titleBar.frame = CGRectMake(
            0,
            0,
            width,
            titleBarHeight
            );
    
    [self fitTitleBarText];

    // Place next/prev buttons at the sides.
    _prevButton.frame = CGRectMake(
            kNextPrevXOffset,
            [self nextPrevYOffset] + (height / 2 - (nextPrevSize.height / 2)),
            nextPrevSize.width,
            nextPrevSize.height
            );
    _nextButton.frame = CGRectMake(
            width - (nextPrevSize.width + kNextPrevXOffset),
            [self nextPrevYOffset] + (height / 2 - (nextPrevSize.height / 2)),
            nextPrevSize.width,
            nextPrevSize.height);

    // Place controlBar at the bottom left.
    float controlBarWidth = width;
    _controlBar.frame = CGRectMake(
            kControlBarX,
            height - [self controlBarHeight],
            controlBarWidth,
            [self controlBarHeight]
            );
    [_controlBar setNeedsLayout];

    // Place footerBar just above the controlBar.
    self.footerBar.frame = CGRectMake(
            kControlBarX,
            height - ([self footerBarHeight] + [self controlBarHeight]),
            controlBarWidth,
            [self footerBarHeight]
            );
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

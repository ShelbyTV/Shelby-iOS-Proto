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
#import "ShelbyApp.h"
#import "GraphiteStats.h"
#import "BroadcastApi.h"

#import <QuartzCore/QuartzCore.h>

static const float kCheckSharerImageInterval = 0.25f;

static const float kTapTime = 0.5f;

static const float kProgressUpdateInterval = 0.25f;
static const float kProgressUpdateBuffer = 0.25f;

static const float kHideControlsCheckLoop = 0.1f;
static const float kHideControlsInterval  = 6.0f;
static const float kFadeControlsDuration  = 0.5f;

static const float kControlBarHeightIpad   = 44.0f;
static const float kControlBarHeightIphone = 44.0f;
static const float kControlBarX            =  0.0f;
static const float kNextPrevXOffset        =  0.0f;

@interface VideoPlayer ()

- (void)drawControls;
- (void)hideControls;
- (void)fitTitleBarText;


@end

@implementation VideoPlayer

@synthesize currentVideo;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(likeVideoSucceeded:)
                                                 name:@"LikeBroadcastSucceeded"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dislikeVideoSucceeded:)
                                                 name:@"DislikeBroadcastSucceeded"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentURLAvailable:)
                                                 name:@"ContentURLAvailable"
                                               object:nil];
    
}

- (void)removeNotificationListeners {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieDurationAvailableNotification object:nil];
}

#pragma mark - Initialization

- (void)initViews {
    
    // this will be immediately set to false by the iPad NavigationViewController
    _fullscreen = TRUE;
    
    _touchOccurring = FALSE;
    _paused = FALSE;
    
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
        _controlBar,
        self.titleBar,
        self.footerBar,
        nil];
    
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    _lastPlayVideo = now;
    _controlsVisible = YES;

    // Timer to update the progressBar after each second.
    [NSTimer scheduledTimerWithTimeInterval: kProgressUpdateInterval target: self selector: @selector(timerAction: ) userInfo: nil repeats: YES];
    
    // Timer to check if we need to hide controls
    [NSTimer scheduledTimerWithTimeInterval:kHideControlsCheckLoop target:self selector:@selector(checkHideTime) userInfo:nil repeats:YES];
 
    // Timer to auto-skip video if we can't get a content URL
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkAutoSkip) userInfo:nil repeats:YES];
    
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

- (void)reset
{
    _changingVideo = YES;
    self.currentVideo = NULL;
    
    // Change our titleBar
    //self.titleBar.title.text = video.sharerComment;
    self.titleBar.title.text = @"";
    self.titleBar.sharerPic.image = NULL;
    [self fitTitleBarText];
    
    // Change our footerBar.
    self.footerBar.title.text = @"";
    
    // Reset our duration.
    _duration = 0.0f;

    [_controlBar setPlayButtonIcon:[UIImage imageNamed:@"ButtonPlay"]];
    [_controlBar setFavoriteButtonSelected:NO];
    _changingVideo = NO;
}

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
    const CGFloat iPadShelbyLogoOverhang = 95;
    
    CGFloat maxTextWidth = self.titleBar.frame.size.width - textOriginX - textRightBorder;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maxTextWidth -= iPadShelbyLogoOverhang;
    }
   
    CGSize textSize = [self.titleBar.title.text sizeWithFont:self.titleBar.title.font
                                           constrainedToSize:CGSizeMake(maxTextWidth, maxTextHeight)
                                               lineBreakMode:UILineBreakModeTailTruncation];
    [UIView setAnimationsEnabled:NO];
    self.titleBar.title.frame = CGRectMake(textOriginX, 
                                           textOriginY, 
                                           textSize.width, 
                                           textSize.height);
    [UIView setAnimationsEnabled:YES];
}

- (void)checkSharerImage
{
    if NOT_NULL(self.titleBar.sharerPic.image) {
        NSLog(@"something already set sharerPic");
        return;
    } else {
        if (NOT_NULL(self.currentVideo.sharerImage)) {
            NSLog(@"setting sharerPic");
            self.titleBar.sharerPic.image = self.currentVideo.sharerImage;
            return;
        }
    }
    
    NSLog(@"insider timer callback. still no sharer image. scheduling timer");
    [NSTimer scheduledTimerWithTimeInterval:kCheckSharerImageInterval target: self selector: @selector(checkSharerImage) userInfo:nil repeats:NO];
}

- (void)playVideo:(Video *)video
{
    @synchronized(self) {
        
        if (NOT_NULL(video)) {
            [self pause];
            
            double now = CACurrentMediaTime();
            _lastPlayVideo = now;
            
            self.currentVideo = video;
            
            // Set internal lock so our notification doesn't go haywire.
            _changingVideo = YES;
            
            
            // Change our titleBar
            //self.titleBar.title.text = video.sharerComment;
            self.titleBar.title.text = [NSString stringWithFormat: @"%@: %@",
                                        video.sharer,
                                        NOT_NULL(video.sharerComment) ? video.sharerComment : video.title
                                        ];
            if NOT_NULL(video.sharerImage) {
                self.titleBar.sharerPic.image = video.sharerImage;
            } else {
                NSLog(@"no sharer image. scheduling timer");
                self.titleBar.sharerPic.image = nil;
                [NSTimer scheduledTimerWithTimeInterval:kCheckSharerImageInterval target: self selector: @selector(checkSharerImage) userInfo:nil repeats:NO];
            }
            [self fitTitleBarText];
            
            // Change our footerBar.
            self.footerBar.title.text = video.title;
            [_controlBar setFavoriteButtonSelected:[video isLiked]];

            // Reset our duration.
            _duration = 0.0f;
            // Load the video and play it.
            if (video.contentURL) {
                [BroadcastApi watch:video];
                [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"watchVideo"];
                _moviePlayer.contentURL = video.contentURL;
                [self play];
                _changingVideo = NO;
            }
                        
            [self drawControls];
        }
    }
}

- (void)play {
    [_controlBar setPlayButtonIcon:[UIImage imageNamed:@"ButtonPause"]];
    [_moviePlayer play];
    _paused = FALSE;
}

- (void)pause {
    [_controlBar setPlayButtonIcon:[UIImage imageNamed:@"ButtonPlay"]];
    [_moviePlayer pause];
    _paused = TRUE;
}

- (void)stop {
    [_moviePlayer stop];
}

- (void)setFullscreen:(BOOL)fullscreen
{
    _fullscreen = fullscreen;
    [_controlBar setFullscreenButtonSelected:fullscreen];
    if (_controlsVisible && fullscreen) {
        _nextButton.alpha = 1.0;
        _prevButton.alpha = 1.0;
    } else if (_controlsVisible && !fullscreen) {
        _nextButton.alpha = 0.0;
        _prevButton.alpha = 0.0;
    }
}

- (BOOL)isFavoriteButtonSelected
{
    return [_controlBar isFavoriteButtonSelected];
}

- (void)resumeAfterCloseShareView
{
    if (_wasPlayingBeforeShare) {
        [self play];
    }
}

#pragma mark - Touch Handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        NSArray *array = touch.gestureRecognizers;
        for (UIGestureRecognizer *gesture in array) {
            if (gesture.enabled && [gesture isMemberOfClass:[UIPinchGestureRecognizer class]]) {
                gesture.enabled = NO;
            }
        }
    }
    
    _touchOccurring = TRUE;
    _lastTouchesBegan = CACurrentMediaTime();
    if (!_controlsVisible) {
        [self drawControls];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // nothing to do here
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchOccurring = FALSE;
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;

    // treat short presses as a tap and close controls if visible
    if (now - _lastTouchesBegan < kTapTime && !_paused) {
        if (_controlsVisible) {
            [self hideControls];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchOccurring = FALSE;
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    
    // treat short presses as a tap and close controls if visible
    if (now - _lastTouchesBegan < kTapTime) {
        if (_controlsVisible) {
            [self hideControls];
        }
    }
}

#pragma mark - Auto Skip

- (void)checkAutoSkip
{
    double now = CACurrentMediaTime();
    if (NOT_NULL(self.currentVideo) && IS_NULL(self.currentVideo.contentURL) && now - _lastPlayVideo >= 4) {
        if (self.delegate) {
            [self.delegate videoPlayerVideoDidFinish: self];
        }
    }
}

#pragma mark - Controls Visibility
- (void)checkHideTime {
    if (!_controlsVisible || _touchOccurring || _paused) {
        return;
    }
    double now = CACurrentMediaTime();
    double delta = now - _lastButtonPressOrControlsVisible;
    // LOG(@"Hidetime. Now: %f. Then: %f. Delta: %f", now, _lastButtonPressOrControlsVisible, delta);
    if (delta > kHideControlsInterval) {
        [self hideControls];
    }
}

- (void)hideControls {
    // LOG(@"hideControls");
    [UIView animateWithDuration:kFadeControlsDuration animations:^{
            for (UIView *control in _controls) {
                control.alpha = 0.0;
            }
            _nextButton.alpha = 0.0;
            _prevButton.alpha = 0.0;
        }
        completion:^(BOOL finished){
               if (finished) {
                   _controlsVisible = NO;
               }
        }];
}

- (void)drawControls {
    // LOG(@"drawControls");
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    
    [UIView animateWithDuration:kFadeControlsDuration animations:^{
        for (UIView *control in _controls) {
            control.alpha = 1.0;
        }
        if (_fullscreen) {
            _nextButton.alpha = 1.0;
            _prevButton.alpha = 1.0;
        }
    }
                     completion:^(BOOL finished){
                         if (finished) {
                             _controlsVisible = YES;
                         }
                     }];
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
    
    // ignore loading errors... just make users hit next if this happens
    if (NOT_NULL(notification.userInfo) && (NOT_NULL([notification.userInfo objectForKey:@"error"]))) {
        return;
    }
 
    double now = CACurrentMediaTime();
    if (self.delegate && (now - _lastDidFinish) > 1.0) {
        _lastDidFinish = now;
        [self.delegate videoPlayerVideoDidFinish: self];
    }
    
}

- (void)likeVideoSucceeded:(NSNotification *)notification
{
    @synchronized(self) {
        if (_changingVideo) {
            return;
        }
        
        if (NOT_NULL(self.currentVideo) &&
            NOT_NULL(notification.userInfo) &&
            [(NSString *)((Video *)[notification.userInfo objectForKey:@"video"]).shelbyId isEqualToString:self.currentVideo.shelbyId]) 
        {
            [_controlBar setFavoriteButtonSelected:YES];
        }
    }
}

- (void)dislikeVideoSucceeded:(NSNotification *)notification
{    
    @synchronized(self) {
        if (_changingVideo) {
            return;
        }
        
        if (NOT_NULL(self.currentVideo) &&
            NOT_NULL(notification.userInfo) &&
            [(NSString *)((Video *)[notification.userInfo objectForKey:@"video"]).shelbyId isEqualToString:self.currentVideo.shelbyId]) 
        {
            [_controlBar setFavoriteButtonSelected:NO];
        }
    }
}

- (void)contentURLAvailable:(NSNotification *)notification
{
    NSLog(@"getting ContentURLAvailable notification");

    if (NOT_NULL(self.currentVideo) &&
        NOT_NULL(notification.userInfo) && 
        self.currentVideo == [notification.userInfo objectForKey:@"video"]) 
    {
        [self playVideo:self.currentVideo];
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
      [self updateProgress];
}

#pragma mark - VideoProgressBarDelegate Methods

- (void)controlBarChangedTimeManually:(VideoPlayerControlBar *)controlBar time:(float)time {
    //LOG(@"videoProgressBarWasAdjusted: %f", time);
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    
    float delta = fabs(time - _moviePlayer.currentPlaybackTime);
    if (delta > 1.0f) {
        // Update playback time.
        _moviePlayer.currentPlaybackTime = time;
        //// Update the progress bar.
        [self updateProgress];
    }
}

#pragma mark - ControlBarDelegate Callbacks

- (void)controlBarPlayButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
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
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    // Inform our delegate
    _wasPlayingBeforeShare = !_paused;
    [self pause];
    if (self.delegate) {
        [self.delegate videoPlayerShareButtonWasPressed: self];
    }
}

/*
 * Currently just a mockup.
 */
- (void)controlBarFavoriteButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    // Inform our delegate
    if (self.delegate) {
        [self.delegate videoPlayerLikeButtonWasPressed: self];
    }
}

- (void)controlBarFullscreenButtonWasPressed:(VideoPlayerControlBar *)controlBar {
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    if (self.delegate) {
        [self.delegate videoPlayerFullscreenButtonWasPressed: self];
    }
}

#pragma mark - Delegate Callbacks

- (IBAction)nextButtonWasPressed:(id)sender {
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"nextButtonPressed"];
    if (self.delegate) {
        [self.delegate videoPlayerNextButtonWasPressed: self];
    }
}

- (IBAction)prevButtonWasPressed:(id)sender {
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"previousButtonPressed"];
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
    [_controlBar layoutSubviews];

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

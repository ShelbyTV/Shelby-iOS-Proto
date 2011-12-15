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

static const float kControlBarHeightIpad   = 98.0f;
static const float kControlBarHeightIphone = 75.0f;
static const float kControlBarX            =  0.0f;
static const float kNextPrevXOffset        =  0.0f;

@interface VideoPlayer ()

- (void)drawControls;
- (void)hideControls;
- (void)fitTitleBarText;

@end

@implementation VideoPlayer

@synthesize delegate;
@synthesize titleBar;
//@synthesize footerBar;
@synthesize moviePlayer = _moviePlayer;
@synthesize currentVideo = _currentVideo;

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
       shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UISlider class]]) {
        // prevent recognizing touches on the slider
        return NO;
    }
    return YES;
}

- (float)controlBarHeight
{
    float height;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        height = kControlBarHeightIphone;
    } else {
        height = kControlBarHeightIpad;
    }
    return height;
}

- (void)setCurrentVideo:(Video *)currentVideo
{
    if (currentVideo == _currentVideo) {
        return;
    }
    _currentVideo.currentlyPlaying = FALSE;
    if (self.delegate && NOT_NULL(_currentVideo)) {
        [self.delegate updateVideoTableCell:_currentVideo];
    }
    [_currentVideo release];
    _currentVideo = [currentVideo retain];
    _currentVideoWatchLaterAtStart = [_currentVideo isWatchLater];
    _currentVideoUnwatchLaterSent = FALSE;
    _currentVideo.currentlyPlaying = TRUE;
    if (self.delegate && NOT_NULL(_currentVideo)) {
        [self.delegate updateVideoTableCell:_currentVideo];
    }
}

- (Video *)getCurrentVideo
{
    return _currentVideo;
}

#pragma mark - Notification Handling

- (void)addNotificationListeners {
    // Listen for duration updates.
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(movieDurationAvailable:)
               name:MPMovieDurationAvailableNotification
             object:_moviePlayer];

    // Listen for the end of the video.
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(movieDidFinish:)
               name:MPMoviePlayerPlaybackDidFinishNotification
             object:_moviePlayer];
    
    // Listen for the end of the video.
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(movieStateChange:)
     name:MPMoviePlayerPlaybackStateDidChangeNotification
     object:_moviePlayer];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(likeVideoSucceeded:)
                                                 name:@"LikeBroadcastSucceeded"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dislikeVideoSucceeded:)
                                                 name:@"DislikeBroadcastSucceeded"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(watchLaterVideoSucceeded:)
                                                 name:@"WatchLaterBroadcastSucceeded"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unwatchLaterVideoSucceeded:)
                                                 name:@"UnwatchLaterBroadcastSucceeded"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentURLAvailable:)
                                                 name:@"ContentURLAvailable"
                                               object:nil];
    
}

- (void)removeNotificationListeners {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieDurationAvailableNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

#pragma mark - Initialization

- (void)initViews {
    
    // this will be immediately set to false by the iPad NavigationViewController
    _fullscreen = TRUE;
    
    _touchOccurring = FALSE;
    _paused = FALSE;
    
    _bgView = [[UIView alloc] initWithFrame:self.bounds];
    _bgView.backgroundColor = [UIColor blackColor];
    
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
    //self.footerBar = [VideoPlayerFooterBar footerBarFromNib];

    // Movie Player
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: nil];
    // Uniform scale until one dimension fits
    _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    // Hide controls so we can render custom ones.
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    if ([_moviePlayer respondsToSelector:@selector(setAllowsAirPlay:)]) {
        _moviePlayer.allowsAirPlay = YES;
    }

    _gestureView = [[UIView alloc] initWithFrame:self.bounds];

    // Add views.
    [self addSubview:_bgView];
    [self addSubview: _moviePlayer.view];

    [self addSubview:_gestureView];
    
    [self addSubview: self.titleBar];
    //[self addSubview: self.footerBar];
    [self addSubview: _controlBar];

    [self addSubview: _nextButton];
    [self addSubview: _prevButton];
    
    _controls = [[NSArray alloc] initWithObjects:
        _controlBar,
        self.titleBar,
       // self.footerBar,
        nil];
    
    [self recordButtonPressOrControlsVisible:NO];
    _lastPlayVideo = CACurrentMediaTime();
    _controlsVisible = YES;

    // Timer to update the progressBar after each second.
    [NSTimer scheduledTimerWithTimeInterval: kProgressUpdateInterval target: self selector: @selector(timerAction: ) userInfo: nil repeats: YES];
    
    // Timer to check if we need to hide controls
    [NSTimer scheduledTimerWithTimeInterval:kHideControlsCheckLoop target:self selector:@selector(checkHideTime) userInfo:nil repeats:YES];
 
    // Timer to auto-skip video if we can't get a content URL
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkAutoSkip) userInfo:nil repeats:YES];
    
    leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeRecognizer.delaysTouchesBegan = YES;
    
    rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeRecognizer.delaysTouchesBegan = YES;
    
    [_gestureView addGestureRecognizer:leftSwipeRecognizer];
    [_gestureView addGestureRecognizer:rightSwipeRecognizer];
    
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

- (id)initWithFrame:(CGRect)frame
{
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
    [self setCurrentVideo:NULL];
    
    // Change our titleBar
    self.titleBar.title.text = @"";
    self.titleBar.comment.text = @"";
    self.titleBar.sharerPic.image = NULL;
    [self fitTitleBarText];

    // Reset our duration.
    _duration = 0.0f;

    [_controlBar showPlayButtonIcon];
    [_controlBar setFavoriteButtonSelected:NO];
    [_controlBar setWatchLaterButtonSelected:NO];
    _changingVideo = NO;
}

- (BOOL)isIdle
{
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
    const CGFloat textOriginX = 56;
    const CGFloat textOriginY = 27;
    const CGFloat textRightBorder = 20;
    const CGFloat maxTextHeight = 35;
    const CGFloat iPadShelbyLogoOverhang = 95;
    
    CGFloat maxTextWidth = self.titleBar.frame.size.width - textOriginX - textRightBorder;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maxTextWidth -= iPadShelbyLogoOverhang;
    }
   
    CGSize textSize = [self.titleBar.comment.text sizeWithFont:self.titleBar.comment.font
                                           constrainedToSize:CGSizeMake(maxTextWidth, maxTextHeight)
                                               lineBreakMode:UILineBreakModeTailTruncation];
    [UIView setAnimationsEnabled:NO];
    self.titleBar.comment.frame = CGRectMake(textOriginX, 
                                           textOriginY, 
                                           textSize.width, 
                                           textSize.height);
    
    [UIView setAnimationsEnabled:YES];
}

- (void)checkSharerImage
{
    if (NOT_NULL(self.currentVideo.sharerImage)) {
        NSLog(@"setting sharerPic");
        self.titleBar.sharerPic.image = self.currentVideo.sharerImage;
        return;
    }
        
    NSLog(@"insider timer callback. still no sharer image. scheduling timer");
    [NSTimer scheduledTimerWithTimeInterval:kCheckSharerImageInterval target: self selector: @selector(checkSharerImage) userInfo:nil repeats:NO];
}

- (void)playVideo:(Video *)video
{
    @synchronized(self) {
        
        if (NOT_NULL(video)) {
            [self pause];
            _stoppedIntentionally = FALSE;
            
            double now = CACurrentMediaTime();
            _lastPlayVideo = now;
            
            [self setCurrentVideo:video];
            
            // Set internal lock so our notification doesn't go haywire.
            _changingVideo = YES;
            
            
            // Change our titleBar
            //self.titleBar.title.text = video.sharerComment;
            self.titleBar.comment.text = [NSString stringWithFormat: @"%@: %@",
                                        video.sharer,
                                        NOT_NULL(video.sharerComment) ? video.sharerComment : video.title
                                        ];
            if NOT_NULL(video.sharerImage) {
                self.titleBar.sharerPic.image = video.sharerImage;
            } else {
                NSLog(@"no sharer image. scheduling timer");
                self.titleBar.sharerPic.image = [UIImage imageNamed:@"PlaceholderFace"];
                [NSTimer scheduledTimerWithTimeInterval:kCheckSharerImageInterval target: self selector: @selector(checkSharerImage) userInfo:nil repeats:NO];
            }
            [self fitTitleBarText];
            
            self.titleBar.title.text = video.title;

            [_controlBar setFavoriteButtonSelected:[video isLiked]];
            [_controlBar setWatchLaterButtonSelected:[video isWatchLater]];

            // Reset our duration.
            _duration = 0.0f;
            // Load the video and play it.
            if (video.contentURL) {
                [BroadcastApi watch:video];
                [GraphiteStats incrementCounter:@"watchVideo"];
                _moviePlayer.contentURL = video.contentURL;
                NSLog(@"playVideo calling [self play]");
                [self play];
                _changingVideo = NO;
            }
                        
            [self drawControls];
        }
    }
}

- (void)play
{
    _lastDidFinish = CACurrentMediaTime(); // need better variable name
    [_controlBar showPauseButtonIcon];
    [_moviePlayer play];
    _paused = FALSE;
}

- (void)pause 
{
    [self recordButtonPressOrControlsVisible:NO];
    if (!_controlsVisible) {
        [self drawControls];
    }
    [_controlBar showPlayButtonIcon];
    [_moviePlayer pause];
    _paused = TRUE;
}

- (void)stop {
    _stoppedIntentionally = TRUE;
    [_moviePlayer stop];
}

- (void)setFullscreen:(BOOL)fullscreen
{
    _fullscreen = fullscreen;
    if (fullscreen) {
        [_controlBar showFullscreenContractButtonIcon];
    } else {
        [_controlBar showFullscreenExpandButtonIcon];
    }
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

- (BOOL)isWatchLaterButtonSelected
{
    return [_controlBar isWatchLaterButtonSelected];
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
    [self recordButtonPressOrControlsVisible:YES];

    // treat short presses as a tap and close controls if visible
    if (CACurrentMediaTime() - _lastTouchesBegan < kTapTime && !_paused) {
        if (_controlsVisible) {
            [self hideControls];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchOccurring = FALSE;
    [self recordButtonPressOrControlsVisible:YES];
    
    // treat short presses as a tap and close controls if visible
    if (CACurrentMediaTime() - _lastTouchesBegan < kTapTime) {
        if (_controlsVisible) {
            [self hideControls];
        }
    }
}

#pragma mark - Auto Skip

- (void)checkAutoSkip
{
    double now = CACurrentMediaTime();
    if (NOT_NULL(self.currentVideo) && IS_NULL(self.currentVideo.contentURL) && now - _lastPlayVideo >= 8.25) {
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

- (void)hideControls
{
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

- (void)drawControls
{
    [self recordButtonPressOrControlsVisible:NO];
    
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

- (void)movieDurationAvailable:(NSNotification*)notification
{
    _duration = [_moviePlayer duration];
    _controlBar.duration = _duration;
}

- (void)movieDidFinish:(NSNotification*)notification
{
    // As long as the user didn't stop the movie intentionally, inform our delegate.
    if (_changingVideo == YES) return;
    if (_stoppedIntentionally == YES) return;

    // ignore loading errors... just make users hit next if this happens
    if (NOT_NULL(notification.userInfo) && (NOT_NULL([notification.userInfo objectForKey:@"error"]))) {
        return;
    }
    
    NSLog(@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey: %@",
          [notification.userInfo objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"]);
    
    double now = CACurrentMediaTime();
    NSLog(@"now = %f", now);
    NSLog(@"lastDidFinish = %f", _lastDidFinish);
    if (self.delegate && (now - _lastDidFinish) > 5.0 && (now - _lastPlayVideo) > 5.0) {
        _lastDidFinish = now;
        [self.delegate videoPlayerVideoDidFinish: self];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(play) userInfo:nil repeats:NO];
    }
}

- (void)movieStateChange:(NSNotification*)notification
{
    MPMoviePlaybackState currentState = [_moviePlayer playbackState];
    if (currentState == MPMoviePlaybackStateInterrupted ||
        currentState == MPMoviePlaybackStatePaused) {
        [self pause];
    }
}

- (void)likeVideoResponse:(NSNotification *)notification selected:(BOOL)like
{
    @synchronized(self) {
        if (_changingVideo) {
            return;
        }
        
        if (NOT_NULL(self.currentVideo) &&
            NOT_NULL(notification.userInfo) &&
            [(NSString *)((Video *)[notification.userInfo objectForKey:@"video"]).shelbyId isEqualToString:self.currentVideo.shelbyId]) 
        {
            [_controlBar setFavoriteButtonSelected:like];
        }
    } 
}

- (void)likeVideoSucceeded:(NSNotification *)notification
{
    [self likeVideoResponse:notification selected:TRUE];
}

- (void)dislikeVideoSucceeded:(NSNotification *)notification
{    
    [self likeVideoResponse:notification selected:FALSE];
}

- (void)watchLaterVideoResponse:(NSNotification *)notification selected:(BOOL)like
{
    @synchronized(self) {
        if (_changingVideo) {
            return;
        }
        
        if (NOT_NULL(self.currentVideo) &&
            NOT_NULL(notification.userInfo) &&
            [(NSString *)((Video *)[notification.userInfo objectForKey:@"video"]).shelbyId isEqualToString:self.currentVideo.shelbyId]) 
        {
            [_controlBar setWatchLaterButtonSelected:like];
        }
    } 
}

- (void)watchLaterVideoSucceeded:(NSNotification *)notification
{
    [self watchLaterVideoResponse:notification selected:TRUE];
}

- (void)unwatchLaterVideoSucceeded:(NSNotification *)notification
{    
    [self watchLaterVideoResponse:notification selected:FALSE];
}

- (void)contentURLAvailable:(NSNotification *)notification
{
    NSLog(@"getting ContentURLAvailable notification");

    if (NOT_NULL(self.currentVideo) &&
        NOT_NULL(notification.userInfo) && 
        self.currentVideo == [notification.userInfo objectForKey:@"video"]) 
    {
        [self performSelectorOnMainThread:@selector(playVideo:) withObject:self.currentVideo waitUntilDone:NO];
    }
}

#pragma mark - Tick Methods

- (void)updateProgress
{
    if (!_paused && !_stoppedIntentionally && !_changingVideo) {
        float currentTime = [_moviePlayer currentPlaybackTime];
        _controlBar.progress = currentTime;
        
        if (NOT_NULL(_currentVideo) && _currentVideo.isWatchLater &&
            _currentVideoWatchLaterAtStart && !_currentVideoUnwatchLaterSent &&
            _duration != 0 && (currentTime / _duration > 0.75)) {
            
            [BroadcastApi unwatchLater:_currentVideo];
            _currentVideoUnwatchLaterSent = TRUE;
        }
    }
}

- (void)timerAction:(NSTimer *)timer {
      [self updateProgress];
}

#pragma mark - VideoProgressBarDelegate Methods

- (void)controlBarChangedTimeManually:(VideoPlayerControlBar *)controlBar
                                 time:(float)time
{
    [self recordButtonPressOrControlsVisible:YES];
    
    float delta = fabs(time - _moviePlayer.currentPlaybackTime);
    if (delta > 1.0f) {
        // Update playback time.
        _moviePlayer.currentPlaybackTime = time;
        //// Update the progress bar.
        [self updateProgress];
    }
}

#pragma mark - ControlBarDelegate Callbacks

- (void)controlBarPlayButtonWasPressed:(VideoPlayerControlBar *)controlBar
{
    [self recordButtonPressOrControlsVisible:YES];

    if (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self pause];
    } else {
        [self play];
    }
}

/*
 * Currently just a mockup.
 */
- (void)controlBarShareButtonWasPressed:(VideoPlayerControlBar *)controlBar 
{
    [self recordButtonPressOrControlsVisible:YES];

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
- (void)controlBarFavoriteButtonWasPressed:(VideoPlayerControlBar *)controlBar
{
    [self recordButtonPressOrControlsVisible:YES];

    // Inform our delegate
    if (self.delegate) {
        [self.delegate videoPlayerLikeButtonWasPressed: self];
    }
}

- (void)controlBarWatchLaterButtonWasPressed:(VideoPlayerControlBar *)controlBar
{
    [self recordButtonPressOrControlsVisible:YES];

    // Inform our delegate
    if (self.delegate) {
        [self.delegate videoPlayerWatchLaterButtonWasPressed: self];
    }
}

- (void)controlBarFullscreenButtonWasPressed:(VideoPlayerControlBar *)controlBar
{
    [self recordButtonPressOrControlsVisible:YES];

    if (self.delegate) {
        [self.delegate videoPlayerFullscreenButtonWasPressed: self];
    }
}


#pragma mark - Delegate Callbacks

- (IBAction)nextButtonWasPressed:(id)sender
{
    [self recordButtonPressOrControlsVisible:YES];

    [GraphiteStats incrementCounter:@"nextButtonPressed"];
    if (self.delegate) {
        [self.delegate videoPlayerNextButtonWasPressed: self];
    }
}

- (IBAction)prevButtonWasPressed:(id)sender
{
    [self recordButtonPressOrControlsVisible:YES];

    [GraphiteStats incrementCounter:@"previousButtonPressed"];
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



//
//- (float)footerBarHeight {
//    float height = [self controlBarHeight];
//
//    return height;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
// Drawing code
}
*/

- (void)layoutSubviews 
{    
    CGRect frame = self.bounds;
    LogRect(@"VideoPlayer", frame);
    const CGFloat width = frame.size.width;
    const CGFloat height = frame.size.height;

    const float titleBarHeight = 75.0f;
    const CGSize nextPrevSize = CGSizeMake(81, 81);
    
    _bgView.frame = self.bounds;
    _moviePlayer.view.frame = self.bounds;
    
    CGRect gestureRect = frame;
    gestureRect.origin.y = titleBarHeight;
    gestureRect.size.height = height - titleBarHeight;
    
    _gestureView.frame = gestureRect;
    
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
    
    float controlBarMinWidth;
    float controlBarMaxWidth;
    float controlBarDesiredMargin;
    float controlBarOffsetFromBottom;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controlBarMinWidth = 406;
        controlBarMaxWidth = 612;
        controlBarDesiredMargin = 80;
        controlBarOffsetFromBottom = 140;
    } else {
        controlBarMinWidth = 286;
        controlBarMaxWidth = 376;
        controlBarDesiredMargin = 57;
        controlBarOffsetFromBottom = 95;
    }
    
    float controlBarWidth = width - (controlBarDesiredMargin * 2);
    
    controlBarWidth = MIN(controlBarWidth, controlBarMaxWidth);
    controlBarWidth = MAX(controlBarWidth, controlBarMinWidth);

    CGRect newControlBarFrame = CGRectMake(
                                   (width / 2 - (controlBarWidth / 2)),
                                   height - controlBarOffsetFromBottom,
                                   controlBarWidth,
                                   [self controlBarHeight]
                                   );
    
    _controlBar.frame = newControlBarFrame;
    [_controlBar layoutSubviews];
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


#pragma mark - Swipe Handling

- (void)swipeLeft:(UIGestureRecognizer *)gestureRecognizer
{
    [self recordButtonPressOrControlsVisible:YES];

    if (self.delegate) {
        [self.delegate videoPlayerNextButtonWasPressed: self];
    }
}

- (void)swipeRight:(UIGestureRecognizer *)gestureRecognizer
{
    [self recordButtonPressOrControlsVisible:YES];

    if (self.delegate) {
        [self.delegate videoPlayerPrevButtonWasPressed: self];
    }
}

- (BOOL)isVideoPlaying
{
    MPMoviePlaybackState state = self.moviePlayer.playbackState;
    if (state == MPMoviePlaybackStatePlaying) {
        return YES;
    } else {
        return NO;
    }
}

- (void)recordButtonPressOrControlsVisible:(BOOL)informDelegate
{
    double now = CACurrentMediaTime();
    _lastButtonPressOrControlsVisible = now;
    
    if (delegate && informDelegate) {
        [delegate videoPlayerWasTouched];
    }
}

@end

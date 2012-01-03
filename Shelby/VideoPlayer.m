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
- (void)fitTitleBars;

- (void)setTitleBarTitle:(NSString *)title;
- (void)setTitleBarComment:(NSString *)comment;
- (void)setSharerImage:(UIImage *)image;

@end

@implementation VideoPlayer

@synthesize delegate;
@synthesize titleBar;
@synthesize tvTitleBar;
@synthesize moviePlayer = _moviePlayer;
@synthesize currentVideo = _currentVideo;
@synthesize fullscreen = _fullscreen;

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
    
    [self addSubview:_bgView];
      
    // Title Bar
    self.titleBar = [VideoPlayerTitleBar titleBarFromNib];
    
    // Add views.
    [self addSubview: _moviePlayer.view];
    [self addSubview: self.titleBar];
        
    [self addSubview:_gestureView];

    [self addSubview: _controlBar];

    [self addSubview: _nextButton];
    [self addSubview: _prevButton];
    
    _controls = [[NSMutableArray alloc] initWithObjects:
        _controlBar,
        self.titleBar,
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
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinchRecognizer.delaysTouchesBegan = NO;
    
    [_gestureView addGestureRecognizer:leftSwipeRecognizer];
    [_gestureView addGestureRecognizer:rightSwipeRecognizer];
    [_gestureView addGestureRecognizer:pinchRecognizer];
    
    [self addNotificationListeners];
    
    _initialized = TRUE;
    
    if ([[UIScreen screens] count] > 1)
    {
        [self screenDidConnect];
    }
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
    [self setTitleBarTitle:@""];
    [self setTitleBarComment:@""];
    [self setSharerImage:NULL];
    [self fitTitleBars];

    // Reset our duration.
    _duration = 0.0f;

    [_controlBar showPlayButtonIcon];
    [_controlBar setFavoriteButtonSelected:NO];
    [_controlBar setWatchLaterButtonSelected:NO];
    if (NOT_NULL(_tvControlBar)) {
        [_tvControlBar setFavoriteButtonSelected:NO];
        [_tvControlBar setWatchLaterButtonSelected:NO];
    }
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

- (void)fitTitleBar:(VideoPlayerTitleBar *)titleBarToSize
        withOriginX:(CGFloat)originX
        withOriginY:(CGFloat)originY
   withMaxTextWidth:(CGFloat)maxTextWidth
  withMaxTextHeight:(CGFloat)maxTextHeight
{
    CGSize textSize = [titleBarToSize.comment.text sizeWithFont:titleBarToSize.comment.font
                                              constrainedToSize:CGSizeMake(maxTextWidth, maxTextHeight)
                                                  lineBreakMode:UILineBreakModeTailTruncation];
    [UIView setAnimationsEnabled:NO];
    titleBarToSize.comment.frame = CGRectMake(originX, 
                                              originY, 
                                              textSize.width, 
                                              textSize.height);
    
    [UIView setAnimationsEnabled:YES];
}

- (void)fitTitleBars
{
    if (!IS_NULL(self.titleBar)) {
        
        CGFloat textOriginX = 56;
        CGFloat textOriginY = 27;
        CGFloat textRightBorder = 20;
        CGFloat maxTextHeight = 35;
        CGFloat maxTextWidth = self.titleBar.frame.size.width - textOriginX - textRightBorder;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            maxTextWidth -= 95; // iPadShelbyLogoOverhang
        }
        
        [self fitTitleBar:self.titleBar
              withOriginX:textOriginX 
              withOriginY:textOriginY 
         withMaxTextWidth:maxTextWidth 
        withMaxTextHeight:maxTextHeight];
    }
   
    if (!IS_NULL(self.tvTitleBar)) {
        
        CGFloat textOriginX = 170;
        CGFloat textOriginY = 85;
        CGFloat textRightBorder = 30;
        CGFloat maxTextHeight = 65;
        CGFloat maxTextWidth = self.tvTitleBar.frame.size.width - textOriginX - textRightBorder;
        
        [self fitTitleBar:self.tvTitleBar
              withOriginX:textOriginX 
              withOriginY:textOriginY   
         withMaxTextWidth:maxTextWidth
        withMaxTextHeight:maxTextHeight
         ];
    }
}

- (void)setTitleBarTitle:(NSString *)title
{
    self.titleBar.title.text = title;
    
    if (!IS_NULL(self.tvTitleBar)) {
        self.tvTitleBar.title.text = title;
    } 
}

- (void)setTitleBarComment:(NSString *)comment
{
    self.titleBar.comment.text = comment;
    
    if (!IS_NULL(self.tvTitleBar)) {
        self.tvTitleBar.comment.text = comment;
    } 
}

- (void)setSharerImage:(UIImage *)image
{
    self.titleBar.sharerPic.image = image;
    
    if (!IS_NULL(self.tvTitleBar)) {
        self.tvTitleBar.sharerPic.image = image;
    }
}

- (void)checkSharerImage
{
    if (NOT_NULL(self.currentVideo.sharerImage)) 
    {
        [self setSharerImage:self.currentVideo.sharerImage];
        return;
    }
        
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
            [self setTitleBarComment:[NSString stringWithFormat: @"%@: %@",
                                        video.sharer,
                                        NOT_NULL(video.sharerComment) ? video.sharerComment : video.title
                                        ]];
            if NOT_NULL(video.sharerImage) {
                [self setSharerImage:video.sharerImage];
            } else {
                NSLog(@"no sharer image. scheduling timer");
                self.titleBar.sharerPic.image = [UIImage imageNamed:@"PlaceholderFace"];
                [NSTimer scheduledTimerWithTimeInterval:kCheckSharerImageInterval target: self selector: @selector(checkSharerImage) userInfo:nil repeats:NO];
            }
            [self fitTitleBars];
            
            [self setTitleBarTitle:video.title];

            [_controlBar setFavoriteButtonSelected:[video isLiked]];
            [_controlBar setWatchLaterButtonSelected:[video isWatchLater]];

            if (NOT_NULL(_tvControlBar)) {
                [_tvControlBar setFavoriteButtonSelected:[video isLiked]];
                [_tvControlBar setWatchLaterButtonSelected:[video isWatchLater]];
            }
            
            // Reset our duration.
            _duration = 0.0f;
            // Load the video and play it.
            if (video.contentURL) {
                if ([ShelbyApp sharedApp].demoModeEnabled) {
                    NSError *error = nil;
                    NSString *data = [NSData dataWithContentsOfURL:video.contentURL options:0 error:&error];
                    NSLog(@"########## Error: %@", [error localizedDescription]);
                    NSLog(@"########## Data in MB: %.2f", (float)([data length] / 1024.0 / 1024.0));
                }
                [BroadcastApi watch:video];
                [GraphiteStats incrementCounter:@"broadcast.watch" withAction:@"watch"];
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
    if ([[UIScreen screens] count] == 1) {
        if (fullscreen) {
            [_controlBar showFullscreenContractButtonIcon];
        } else {
            [_controlBar showFullscreenExpandButtonIcon];
        }
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
            if (gesture != pinchRecognizer && gesture.enabled && [gesture isMemberOfClass:[UIPinchGestureRecognizer class]]) {
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
    if (!_controlsVisible) {
        return;
    }
    
    [UIView animateWithDuration:kFadeControlsDuration animations:^{
            for (UIView *control in _controls) {
                if ([[UIScreen screens] count] > 1 &&
                    (control == _controlBar ||
                     control == self.titleBar)) {
                    continue;
                }
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
    if (_controlsVisible) {
        return;
    }
    
    [self recordButtonPressOrControlsVisible:NO];
    
    [UIView animateWithDuration:kFadeControlsDuration animations:^{
        for (UIView *control in _controls) {
            if (control == self.tvTitleBar) {
                NSLog(@"Setting tvTitleBar.alpha to 1.0!!!!!!!!!!!!!");
            }
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
    if (NOT_NULL(_tvControlBar)) {
        _tvControlBar.duration = _duration;
    }
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
            if (NOT_NULL(_tvControlBar)) {
                [_tvControlBar setFavoriteButtonSelected:like];
            }
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
            if (NOT_NULL(_tvControlBar)) {
                [_tvControlBar setWatchLaterButtonSelected:like];
            }
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
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
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
    if (NOT_NULL(_tvControlBar)) {
        _tvControlBar.progress = [_moviePlayer currentPlaybackTime];
    }
    
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

    BOOL currentlyLiked = _currentVideo.isLiked;

    // Inform our delegate
    if (self.delegate) {
        [self.delegate videoPlayerLikeButtonWasPressed: self];
    }
    
    _currentVideo.isLiked = !currentlyLiked;
    [_controlBar setFavoriteButtonSelected:!currentlyLiked];
    if (NOT_NULL(_tvControlBar)) {
        [_tvControlBar setFavoriteButtonSelected:!currentlyLiked];
    }
}

- (void)controlBarWatchLaterButtonWasPressed:(VideoPlayerControlBar *)controlBar
{
    [self recordButtonPressOrControlsVisible:YES];

    BOOL currentlyWatchLater = _currentVideo.isWatchLater;
    
    // Inform our delegate
    if (self.delegate) {
        [self.delegate videoPlayerWatchLaterButtonWasPressed: self];
    }
    
    _currentVideo.isWatchLater = !currentlyWatchLater;
    [_controlBar setWatchLaterButtonSelected:!currentlyWatchLater];
    if (NOT_NULL(_tvControlBar)) {
        [_tvControlBar setWatchLaterButtonSelected:!currentlyWatchLater];
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

    [GraphiteStats incrementCounter:@"ui.next_button_click" withAction:@"next_button_click"];
    if (self.delegate) {
        [self.delegate videoPlayerNextButtonWasPressed: self];
    }
}

- (IBAction)prevButtonWasPressed:(id)sender
{
    [self recordButtonPressOrControlsVisible:YES];

    [GraphiteStats incrementCounter:@"ui.prev_button_click" withAction:@"prev_button_click"];
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

    float titleBarHeight = 75.0f;
    
    const CGSize nextPrevSize = CGSizeMake(81, 81);
    
    _bgView.frame = self.bounds;
    if ([[UIScreen screens] count] > 1) {
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        _moviePlayer.view.frame = secondScreen.bounds;
    } else {
        _moviePlayer.view.frame = self.bounds;

    }
    
    CGRect gestureRect = frame;
    gestureRect.origin.y = titleBarHeight;
    gestureRect.size.height = height - titleBarHeight;
    
    _gestureView.frame = gestureRect;
    
    if ([[UIScreen screens] count] > 1 && !IS_NULL(self.tvTitleBar)) {
        
        NSLog(@"!!!!!!!!!!!!! setting the tvTitleBar frame"); 
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        self.tvTitleBar.frame = CGRectMake(
                                         0,
                                         0,
                                         secondScreen.bounds.size.width,
                                         180.0
                                         );
    }
    
    self.titleBar.frame = CGRectMake(
                                     0,
                                     0,
                                     width,
                                     titleBarHeight
                                     );
    
    [self fitTitleBars];

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
    
    if (NOT_NULL(_tvControlBar) && [[UIScreen screens] count] > 1) {
        
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        
        CGFloat tvControlBarWidth = 1000; 
        CGFloat tvControlBarHeight = 75; 

        _tvControlBar.frame = CGRectMake(secondScreen.bounds.size.width / 2 - (tvControlBarWidth / 2), 
                                         secondScreen.bounds.size.height - 105, 
                                         tvControlBarWidth, 
                                         tvControlBarHeight);

        [_tvControlBar layoutSubviews];
    }
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

#pragma mark - Pinch Handling

- (void)pinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if ([[UIScreen screens] count] < 2)
    {
        return;
    }
    
    if (gestureRecognizer.scale > 2 && gestureRecognizer.velocity > 1.0) {
        if (self.delegate) {
            [self.delegate videoPlayerShowRemoteView];
        }
    }
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

- (void)screenDidConnect
{
    if (!_initialized) {
        return;
    }
    
    if ([[UIScreen screens] count] > 1)
    {
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        
        UIWindow *secondScreenWindow = [ShelbyApp secondScreenWindow];
        secondScreenWindow.frame = secondScreen.bounds;
        
        if (IS_NULL(self.tvTitleBar)) {
            self.tvTitleBar = [VideoPlayerTitleBar titleBarFromTVNib];
            self.tvTitleBar.title.text = self.titleBar.title.text;
            self.tvTitleBar.comment.text = self.titleBar.comment.text;
            self.tvTitleBar.sharerPic.image = self.titleBar.sharerPic.image;
            
            [_controls addObject:self.tvTitleBar];
            [secondScreenWindow addSubview:self.tvTitleBar];
            
            [self fitTitleBars];
        }
        
        if (IS_NULL(_tvControlBar)) {
            _tvControlBar = [VideoPlayerControlBar controlBarFromTVNib];
            [_tvControlBar setFavoriteButtonSelected:[_controlBar isFavoriteButtonSelected]];
            [_tvControlBar setWatchLaterButtonSelected:[_controlBar isWatchLaterButtonSelected]];
            
            [_tvControlBar adjustProgressBarForTV];
            
            [_controls addObject:_tvControlBar];
            [secondScreenWindow addSubview:_tvControlBar];
        }
        
        if (_fullscreen) {
            [self controlBarFullscreenButtonWasPressed:_controlBar];
        }
        
        [_controlBar showFullscreenRemoteModeButtonIcon];
        
        [_moviePlayer.view removeFromSuperview];
        _moviePlayer.view.frame = secondScreenWindow.bounds;
        [secondScreenWindow insertSubview:_moviePlayer.view belowSubview:self.tvTitleBar];
        
        [secondScreenWindow setScreen:secondScreen];
        secondScreenWindow.hidden = NO;
    }
}

- (void)screenDidDisconnect
{
    if (!_initialized) {
        return;
    }
    
    if ([[UIScreen screens] count] == 1) {
        [_moviePlayer.view removeFromSuperview];
        _moviePlayer.view.frame = self.bounds;
        [self insertSubview: _moviePlayer.view aboveSubview:_bgView];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_controlBar showFullscreenExpandButtonIcon];
        }
    }
}

- (void)scanForward
{
    [self controlBarChangedTimeManually:_controlBar
                                   time:MIN(_moviePlayer.currentPlaybackTime + 10,
                                            _duration)];
}

- (void)scanBackward
{
    [self controlBarChangedTimeManually:_controlBar
                                   time:MAX(_moviePlayer.currentPlaybackTime - 10,
                                            0)];
}

- (void)hideControlsIfNotPaused
{
    if (!_paused) {
        [self hideControls];
    }
}

@end

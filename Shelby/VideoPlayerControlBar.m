//
//  VideoPlayerControlBar.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/5/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "VideoPlayerControlBar.h"
#import "VideoPlayerProgressBar.h"

@implementation VideoPlayerControlBar

@synthesize delegate;

static NSString *IPAD_NIB_NAME = @"VideoPlayerControlBar_iPad";
static NSString *IPHONE_NIB_NAME = @"VideoPlayerControlBar_iPhone";

static const float kProgressBarXOffsetIphone =  0.0f;
static const float kProgressBarXOffsetIpad   =  180.0f;
static const float kProgressBarYOffsetIphone =  42.0f;
static const float kProgressBarYOffsetIpad   =  0.0f;

#pragma mark - Factory

+ (VideoPlayerControlBar *)controlBarFromNib {
    NSString *nibName;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibName = IPHONE_NIB_NAME;
    } else {
        nibName = IPAD_NIB_NAME;
    }
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];

    return [objects objectAtIndex:0];
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // initialise ourselves normally
    self = [super initWithCoder:aDecoder];
    if(self) {
        // This is a dirty hack, because for some reason, the NIB variables aren't bound immediately, so the following code doesn't work alone:
        // _progressBar.delegate = self;
        // So instead, we pull the view out via its tag.
        _progressBar = (VideoPlayerProgressBar *) [self viewWithTag: 1];
        _progressBar.delegate = self;
    }
    return self;
}

- (void)handleInit {
    if (!_initialized) {

    }
}

#pragma mark - Properties

- (void)setProgress:(float)progress {
    _progressBar.progress = progress;
}

- (float)progress {
    return _progressBar.progress;
}

- (void)setDuration:(float)duration {
    _progressBar.duration = duration;
}

- (float)duration {
    return _progressBar.duration;
}

- (void)setPlayButtonIcon:(UIImage *)image
{
    [_playButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - VideoProgressBarDelegate Methods

- (void)videoProgressBarWasAdjusted:(VideoPlayerProgressBar *)videoProgressBar value:(float)value {
    if (self.delegate) {
        [self.delegate controlBarChangedTime: self time: value];
    }
}

#pragma mark - Delegate Callbacks

- (IBAction)playButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarPlayButtonWasPressed: self];
    }
}

- (IBAction)shareButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarShareButtonWasPressed: self];
    }
}

- (IBAction)favoriteButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarFavoriteButtonWasPressed: self];
    }
}

- (IBAction)fullscreenButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarFullscreenButtonWasPressed: self];
    }
}

- (IBAction)soundButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarSoundButtonWasPressed: self];
    }
}

#pragma mark - Layout

- (float)progressBarXOffset {
    float offset;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        offset = kProgressBarXOffsetIphone;
    } else {
        offset = kProgressBarXOffsetIpad;
    }
    return offset;
}

- (float)progressBarYOffset {
    float offset;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        offset = kProgressBarYOffsetIphone;
    } else {
        offset = kProgressBarYOffsetIpad;
    }
    return offset;
}

- (void)layoutSubviews {
    CGRect frame = self.bounds;
    
    _progressBar.frame = CGRectMake([self progressBarXOffset] - 1, 
                                    [self progressBarYOffset], 
                                    frame.size.width - [self progressBarXOffset] + 2,
                                    44);
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end

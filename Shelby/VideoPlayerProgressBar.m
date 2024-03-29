//
//  VideoProgressBar.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#define LABEL_OFFSET_X -20 // account for extra overlap for thumb slider transparent region
#define LABEL_OFFSET_Y -1

#import "VideoPlayerProgressBar.h"
#import <QuartzCore/QuartzCore.h>

static const float kProgressUpdateBuffer = 1.0f;

@implementation VideoPlayerProgressBar

@synthesize delegate;

#pragma mark - Initialization

- (void)initViews {
    // We currently use a slider for our progress bar. In the future, we can replace this with a custom UIView.
    _slider = [[UISlider alloc] init];
    
    // in case the parent view draws with a custom color or gradient, use a transparent color
    _slider.backgroundColor = [UIColor clearColor];
	
    //UIImage *stetchLeftTrack = [[UIImage imageNamed:@"orangeslide.png"]
    UIImage *stetchLeftTrack = [[UIImage imageNamed:@"SliderPurple.png"]
                   stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    //UIImage *stetchRightTrack = [[UIImage imageNamed:@"yellowslide.png"]
    UIImage *stetchRightTrack = [[UIImage imageNamed:@"SliderGray.png"]
                    stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    //[_slider setThumbImage: [UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
    [_slider setThumbImage: [UIImage imageNamed:@"SliderThumbLightGray.png"] forState:UIControlStateNormal];
    [_slider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [_slider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];

    _slider.continuous = YES;
    _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    _label = [[UILabel alloc] init];
    _label.textAlignment = UITextAlignmentRight;
    _label.textColor = [UIColor grayColor];
    _label.shadowColor = [UIColor clearColor];
    _label.font = [UIFont fontWithName: @"Thonburi-Bold" size: 14.0];
    _label.numberOfLines = 1;
    _label.backgroundColor = [UIColor clearColor];
    _label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    _blackLineStartOverlay = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 1, CGRectGetHeight(self.bounds))];
    _blackLineStartOverlay.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    _blackLineStartOverlay.backgroundColor = [UIColor blackColor];
    
    _blackLineEndOverlay = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 16, 0, 1, CGRectGetHeight(self.bounds))];
    _blackLineEndOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _blackLineEndOverlay.backgroundColor = [UIColor blackColor];
    
    _slider.frame = self.bounds;
    
    CGRect tempFrame = self.bounds;
    tempFrame.origin.x = LABEL_OFFSET_X;
    tempFrame.origin.y = LABEL_OFFSET_Y;
    _label.frame = tempFrame;
    
    self.autoresizesSubviews = YES;
    
    [self addSubview: _slider];
    [self addSubview: _label];
    [self addSubview: _blackLineStartOverlay];
    [self addSubview: _blackLineEndOverlay];

    // We use this to maintain a close eye on the slider value.
    [_slider addTarget: self
                action: @selector(sliderWasMoved:)
      forControlEvents: UIControlEventValueChanged];

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
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

#pragma mark - Helper Methods

- (NSString *)floatToMinutes:(float)value {
    // Use truncation to get to integers.
    int seconds = value;
    int minutes = seconds / 60;
    int remainder = seconds % 60;

    return [NSString stringWithFormat: @"%d:%02d", minutes, remainder];
}

#pragma mark - Public Methods

- (void)setProgress:(float)progress {
    if (progress >= 0.0f)  {

        // Only update the slider if we haven't touched it in a while
        CFTimeInterval now = CACurrentMediaTime();
        if (now - _lastTouchTime > kProgressUpdateBuffer) {
            // Set our slider, making sure that when we adjust it,
            // we don't send false events.
            _adjustingSlider = YES;
            _slider.value = progress;
            _adjustingSlider = NO;
        }

        // Set our label to M:SS format.
        _label.text = [NSString stringWithFormat: @"%@/%@", 
                            [self floatToMinutes: progress],
                            [self floatToMinutes: [self duration]]];
    }
}

- (float)progress {
    return _slider.value;
}

- (void)setDuration:(float)duration {
    _slider.maximumValue = duration;
}

- (float)duration {
    return _slider.maximumValue;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Notify

- (void)videoProgressBarWasAdjustedManually {
    _lastTouchTime = CACurrentMediaTime();
    //Notify our delegate that we've changed.
    if (self.delegate) {
        [self.delegate videoProgressBarWasAdjustedManually: self value: _slider.value];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    LOG(@"[VideoProgressBar observeValueForKeyPath: %@]", keyPath);
}

#pragma mark - Slider tracking

- (void)sliderWasMoved:(id)sender {
    if (!_adjustingSlider) {
        [self videoProgressBarWasAdjustedManually];
    }
}

#pragma mark - Cleanup

- (void)dealloc
{
    [_label release];
    [_slider release];
    [super dealloc];
}

- (void)adjustForTV
{
    UIImage *stretchLeftTrack;
    UIImage *stretchRightTrack;
    UIImage *thumbImage;

    CGRect tempFrame = self.bounds;
    
    if ([[UIScreen screens] count] > 1) {
        
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        
        if (secondScreen.bounds.size.height == 1080) {
            stretchLeftTrack = [[UIImage imageNamed:@"SliderPurple_TV_1080.png"]
                               stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
            stretchRightTrack = [[UIImage imageNamed:@"SliderGray_TV_1080.png"]
                                stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
            thumbImage = [UIImage imageNamed:@"SliderThumbLightGray_TV_1080.png"];
            
            _label.font = [UIFont fontWithName: @"Thonburi-Bold" size: 45.0];
            tempFrame.origin.y = 20;
            tempFrame.origin.x = -15;
        } else {
            stretchLeftTrack = [[UIImage imageNamed:@"SliderPurple_TV_720.png"]
                               stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
            stretchRightTrack = [[UIImage imageNamed:@"SliderGray_TV_720.png"]
                                stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
            thumbImage = [UIImage imageNamed:@"SliderThumbLightGray_TV_720.png"];
            
            _label.font = [UIFont fontWithName: @"Thonburi-Bold" size: 30.0];
            tempFrame.origin.y = 10;
            tempFrame.origin.x = -10;
        }
        
        [_slider setThumbImage:thumbImage forState:UIControlStateNormal];
        [_slider setMinimumTrackImage:stretchLeftTrack forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:stretchRightTrack forState:UIControlStateNormal];
        
        _blackLineStartOverlay.hidden = TRUE;
        _blackLineEndOverlay.hidden = TRUE;
        
        _label.frame = tempFrame;
    }
}

@end

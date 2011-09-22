//
//  VideoProgressBar.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#define LABEL_OFFSET 40
#define LABEL_HEIGHT 40

#import "VideoPlayerProgressBar.h"
#import <QuartzCore/QuartzCore.h>

static const float kProgressUpdateBuffer = 0.25f;

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
    [_slider setThumbImage: [UIImage imageNamed:@"SliderThumbWhite.png"] forState:UIControlStateNormal];
    [_slider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [_slider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];

    _slider.continuous = YES;

    //_slider.minimumValue = 0.0;
    //_slider.maximumValue = 100.0;
    //_slider.value = 50.0;

    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor whiteColor];
    _label.shadowColor = [UIColor blackColor];
    //_label.font = [UIFont fontWithName: @"Verdana" size: 17.0];
    //_label.font = [UIFont fontWithName: @"Helvetica-Bold" size: 17.0];
    _label.backgroundColor = [UIColor clearColor];
    
    [self addSubview: _slider];
    [self addSubview: _label];

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
    // Round down to zero. Helps catch a 0.0 duration bug.
    if (seconds == 1) seconds = 0;

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
        _label.text = [NSString stringWithFormat: @"%@ / %@", 
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

- (void)videoProgressBarWasAdjusted {
    _lastTouchTime = CACurrentMediaTime();
    //Notify our delegate that we've changed.
    if (self.delegate) {
        [self.delegate videoProgressBarWasAdjusted: self value: _slider.value];
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    CGRect frame = self.bounds;

    //const float sliderSplit = 0.7;
    //float sliderHeight = frame.size.height * sliderSplit;
    //float labelHeight = frame.size.height - sliderHeight;

    CGRect tempFrame = frame;
    _slider.frame = frame;
    
    NSLog(@"slider frame is %f, %f", frame.size.width, frame.size.height);

    //float labelHeight = LABEL_HEIGHT;
    float labelHeight = frame.size.height;
    tempFrame = frame;
    tempFrame.origin.x = LABEL_OFFSET;
    tempFrame.origin.y = (frame.size.height / 2) - (labelHeight / 2);
    //tempFrame.size.height = labelHeight;
    _label.frame = tempFrame;
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
        [self videoProgressBarWasAdjusted];
    }
}

#pragma mark - Cleanup

- (void)dealloc
{
    [_label release];
    [_slider release];
    [super dealloc];
}

@end

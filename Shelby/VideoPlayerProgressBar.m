//
//  VideoProgressBar.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "VideoPlayerProgressBar.h"


@implementation VideoPlayerProgressBar

@synthesize delegate;

#pragma mark - Initialization

- (void)initViews {
    // We currently use a slider for our progress bar. In the future, we can replace this with a custom UIView.
    _slider = [[UISlider alloc] init];
    [self addSubview: _slider];

    _label = [[UILabel alloc] init];
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

    int minutes = seconds / 60;
    int remainder = seconds % 60;

    return [NSString stringWithFormat: @"%d:%02d", minutes, remainder];
}

#pragma mark - Public Methods

- (void)setProgress:(float)progress {
    if (progress >= 0.0f)  {
        // Set our slider, making sure that when we adjust it, 
        // we don't send false events.
        _adjustingSlider = YES;
        _slider.value = progress;
        _adjustingSlider = NO;

        // Set our label to M:SS format.
        [_label setText: [self floatToMinutes: progress]];
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
    //Notify our delegate that we've changed.
    if (self.delegate) {
        [self.delegate videoProgressBarWasAdjusted: self value: _slider.value];
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    CGRect frame = self.bounds;

    const float sliderSplit = 0.7;
    float sliderHeight = frame.size.height * sliderSplit;
    float labelHeight = frame.size.height - sliderHeight;

    CGRect tempFrame = frame;
    tempFrame.size.height = sliderHeight;
    _slider.frame = tempFrame;

    tempFrame = frame;
    tempFrame.origin.y = sliderHeight;
    tempFrame.size.height = labelHeight;
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

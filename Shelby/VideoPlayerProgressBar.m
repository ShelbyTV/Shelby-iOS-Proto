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

#pragma mark - Public Methods

- (void)setProgress:(float)progress {
    if (progress >= 0.0f)  {
        _adjustingSlider = YES;
        _slider.value = progress;
        _adjustingSlider = NO;
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
    _slider.frame = self.bounds;
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
        LOG(@"slider MOVED!");
        [self videoProgressBarWasAdjusted];
    }
}

#pragma mark - Cleanup

- (void)dealloc
{
    [_slider release];
    [super dealloc];
}

@end
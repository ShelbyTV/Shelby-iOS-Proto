//
//  VideoProgressBar.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "VideoProgressBar.h"


@implementation VideoProgressBar

@synthesize delegate;

#pragma mark - Initialization

- (void)initViews {
    _slider = [[UISlider alloc] init];
    [self addSubview: _slider];

    [_slider addTarget: self
                action: @selector(sliderWasMoved:)
      forControlEvents: UIControlEventValueChanged];

    [self addObserver:self
           forKeyPath:@"_slider.value"
              options:0
              context:@"sliderChanged"
              ];

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
    if ([keyPath isEqualToString:@"_slider.value"]) {
        //if (!_adjustingSlider) {
        //    LOG(@"slider OBSERVED!");
        //    [self videoProgressBarWasAdjusted];
        //}
    }
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

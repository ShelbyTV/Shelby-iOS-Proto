//
//  VideoProgressBar.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "VideoProgressBar.h"


@implementation VideoProgressBar

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle: UIProgressViewStyleDefault];
        [self addSubview: _progressView];
    }
    return self;
}


#pragma mark - Public Methods

- (void)setProgress:(float)progress {
    _progressView.progress = progress;
}

- (float)progress {
    return _progressView.progress;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Layout

- (void)layoutSubviews {
    _progressView.frame = self.bounds;
}

#pragma mark - Cleanup

- (void)dealloc
{
    [_progressView release];
    [super dealloc];
}

@end

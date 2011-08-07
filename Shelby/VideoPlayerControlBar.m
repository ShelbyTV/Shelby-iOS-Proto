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

static NSString *NIB_NAME = @"VideoPlayerControlBar";

//- (void)loadViewFromNib {
//    // load everything in the XIB we created
//    NSArray *objects = [[NSBundle mainBundle] 
//        loadNibNamed:NIB_NAME owner:self options:nil];
//
//    // actually, we know there's only one thing in it, which is the
//    // view we want to appear within this one
//    //[self addSubview:[objects objectAtIndex:0]];
//    //self.view = [objects objectAtIndex:0];
//
//}
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self loadViewFromNib];
//    }
//    return self;
//}

#pragma mark - Factory

+ (VideoPlayerControlBar *)controlBarFromNib {
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:NIB_NAME owner:self options:nil];

    return [objects objectAtIndex:0];
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // initialise ourselves normally
    self = [super initWithCoder:aDecoder];
    if(self) {
        // This is a dirty hack, because for some reason, the NIB variables aren't bound at runtime, so the following code doesn't work alone:
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

#pragma mark - Layout

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

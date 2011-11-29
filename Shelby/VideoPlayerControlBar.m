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

- (BOOL)isFavoriteButtonSelected
{
    return _favoriteButton.selected;
}

- (void)setFavoriteButtonSelected:(BOOL)selected
{
    _favoriteButton.selected = selected;
}

- (BOOL)isWatchLaterButtonSelected
{
    return _watchLaterButton.selected;
}

- (void)setWatchLaterButtonSelected:(BOOL)selected
{
    _watchLaterButton.selected = selected;
}

- (void)setFullscreenButtonIcon:(UIImage *)image
{
    [_fullscreenButton setImage:image forState:UIControlStateNormal];
}

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

- (void)videoProgressBarWasAdjustedManually:(VideoPlayerProgressBar *)videoProgressBar value:(float)value {
    if (self.delegate) {
        [self.delegate controlBarChangedTimeManually: self time: value];
    }
}

#pragma mark - Delegate Callbacks

- (IBAction)playButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarPlayButtonWasPressed:self];
    }
}

- (IBAction)shareButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarShareButtonWasPressed:self];
    }
}

- (IBAction)favoriteButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarFavoriteButtonWasPressed:self];
    }
}

- (IBAction)watchLaterButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarWatchLaterButtonWasPressed:self];
    }
}

- (IBAction)fullscreenButtonWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate controlBarFullscreenButtonWasPressed: self];
    }
}

- (void)layoutSubviews 
{
    CGRect tempFrame = _playButton.frame;
    tempFrame.size.width = self.frame.size.width - (406 - 80);
    _playButton.frame = tempFrame;
    
    tempFrame = _shareButton.frame;
    tempFrame.origin.x = _playButton.frame.origin.x + _playButton.frame.size.width - 1;
    _shareButton.frame = tempFrame;
    
    tempFrame = _favoriteButton.frame;
    tempFrame.origin.x = _shareButton.frame.origin.x + _shareButton.frame.size.width - 1;
    _favoriteButton.frame = tempFrame;
    
    tempFrame = _progressBar.frame;
    tempFrame.size.width = self.frame.size.width;
    _progressBar.frame = tempFrame;
    
    [_progressBar layoutSubviews];
}

- (void)dealloc
{
    [super dealloc];
}

@end

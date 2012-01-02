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
@synthesize tv;

static NSString *IPAD_NIB_NAME = @"VideoPlayerControlBar_iPad";
static NSString *IPHONE_NIB_NAME = @"VideoPlayerControlBar_iPhone";
static NSString *TV_NIB_NAME = @"VideoPlayerControlBar_TV";

#pragma mark - Factory

+ (VideoPlayerControlBar *)controlBarFromTVNib 
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:TV_NIB_NAME owner:self options:nil];
    
    ((VideoPlayerControlBar *)[objects objectAtIndex:0]).tv = TRUE;
    
    return [objects objectAtIndex:0];
}

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

- (void)showFullscreenExpandButtonIcon
{
    NSLog(@"showFullscreenExpandButtonIcon");
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_fullscreenButton setImage:[UIImage imageNamed:@"fullscreenExpand_iPad"] 
                           forState:UIControlStateNormal];
    } else {
        // no reason to show this button ever on the iPhone right now...
//        [_fullscreenButton setImage:[UIImage imageNamed:@"fullscreenExpand_iPhone"] 
//                           forState:UIControlStateNormal];
    }
}

- (void)showFullscreenContractButtonIcon
{
    NSLog(@"showFullscreenContractButtonIcon");

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_fullscreenButton setImage:[UIImage imageNamed:@"fullscreenContract_iPad"] 
                           forState:UIControlStateNormal];
    } else {
        [_fullscreenButton setImage:[UIImage imageNamed:@"fullscreenContract_iPhone"] 
                           forState:UIControlStateNormal];
    }
}

- (void)showFullscreenRemoteModeButtonIcon
{
    NSLog(@"showFullscreenRemoteModeButtonIcon");

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_fullscreenButton setImage:[UIImage imageNamed:@"remoteMode_iPad"] 
                           forState:UIControlStateNormal];
    } else {
        // no reason to show this button ever on the iPhone right now...
        //        [_fullscreenButton setImage:[UIImage imageNamed:@"remoteMode_iPhone"] 
        //                           forState:UIControlStateNormal];
    }
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

- (void)showPlayButtonIcon
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_playButton setImage:[UIImage imageNamed:@"playIcon_iPad"] 
                           forState:UIControlStateNormal];
    } else {
        [_playButton setImage:[UIImage imageNamed:@"playIcon_iPhone"] 
                           forState:UIControlStateNormal];
    }
}

- (void)showPauseButtonIcon
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_playButton setImage:[UIImage imageNamed:@"pauseIcon_iPad"] 
                           forState:UIControlStateNormal];
    } else {
        [_playButton setImage:[UIImage imageNamed:@"pauseIcon_iPhone"] 
                           forState:UIControlStateNormal];
    }
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
    
    NSLog(@"VideoPlayerControlBar fullscreenButtonWasPressed");
    
    if (self.delegate) {
        
        NSLog(@"VideoPlayerControlBar calling self.delegate controlBarFullscreenButtonWasPressed");

        [self.delegate controlBarFullscreenButtonWasPressed: self];
    }
}

- (void)layoutSubviews 
{
    if (!self.tv) {
        
        CGRect tempFrame = _playButton.frame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            tempFrame.size.width = self.frame.size.width - (406 - 80);
        } else {
            tempFrame.size.width = self.frame.size.width - (286 - 56);
        }
        
        _playButton.frame = tempFrame;
        
        tempFrame = _shareButton.frame;
        tempFrame.origin.x = _playButton.frame.origin.x + _playButton.frame.size.width - 1;
        _shareButton.frame = tempFrame;
        
        tempFrame = _favoriteButton.frame;
        tempFrame.origin.x = _shareButton.frame.origin.x + _shareButton.frame.size.width - 1;
        _favoriteButton.frame = tempFrame;
        
        tempFrame = _progressBar.frame;
        tempFrame.size.width = self.frame.size.width + 30; // overlap for extra thumb slider space
        _progressBar.frame = tempFrame;
    
    }
    
    [_progressBar layoutSubviews];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)adjustProgressBarForTV
{
    [_progressBar adjustForTV];
}

@end

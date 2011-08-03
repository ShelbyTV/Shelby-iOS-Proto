//
//  VideoPlayerControlBar.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/5/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoProgressBar;

@interface VideoPlayerControlBar : UIView {
    IBOutlet UIButton *_favoriteButton;
    IBOutlet UIButton *_shareButton;
    IBOutlet UIButton *_playButton;
    IBOutlet UIButton *_fullscreenButton;
    IBOutlet UIButton *_soundButton;
    
    IBOutlet VideoProgressBar *_progressBar;
}

@end

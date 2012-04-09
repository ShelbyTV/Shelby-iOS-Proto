//
//  VideoPlayerTitleBar.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/5/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VideoPlayerTitleBar : UIView {
}

+ (VideoPlayerTitleBar *)titleBarFromTVNib:(CGRect)screenBounds;
+ (VideoPlayerTitleBar *)titleBarFromNib;

@property(strong, nonatomic) IBOutlet UILabel *title;
@property(strong, nonatomic) IBOutlet UILabel *comment;
@property(strong, nonatomic) IBOutlet UIImageView *sharerPic;

@property(strong, nonatomic) IBOutlet UIImageView *channelPic;

@end

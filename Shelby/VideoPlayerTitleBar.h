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

+ (VideoPlayerTitleBar *)titleBarFromTVNib;
+ (VideoPlayerTitleBar *)titleBarFromNib;

@property(nonatomic, retain) IBOutlet UILabel *title;
@property(nonatomic, retain) IBOutlet UILabel *comment;
@property(nonatomic, retain) IBOutlet UIImageView *sharerPic;

@end

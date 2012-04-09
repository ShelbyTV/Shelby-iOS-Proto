//
//  VideoPlayerFooterBar.h
//  Shelby
//
//  Created by David Kay on 9/15/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerFooterBar : UIView

@property(strong, nonatomic) IBOutlet UILabel *title;

+ (VideoPlayerFooterBar *)footerBarFromNib;

@end

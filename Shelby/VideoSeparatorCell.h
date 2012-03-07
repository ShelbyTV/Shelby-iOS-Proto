//
//  VideoSeparatorCell.h
//  Shelby
//
//  Created by Mark Johnson on 2/28/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoSeparatorCell : UITableViewCell
{
    UIView *_bgView;
    UIView *_topBar;
    UIView *_bottomBar;
    UILabel *_lastSyncTimeLabel;
}

@end
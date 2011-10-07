//
//  VideoTableViewCell.h
//  Shelby
//
//  Created by Mark Johnson on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Video;
@class VideoTableData;

@interface VideoTableViewCell : UITableViewCell
{
    UIImageView *_bgView;
    UIImageView *_videoView;
    UIImageView *_badgeView;
    UIView *_commentView;
    UIView *_videoFooterView;
    UIImageView *_sharerView;
    UILabel *_sharerComment;
    UILabel *_sharerName;
    UILabel *_shareTime;
    
    BOOL _selected;
}

@property (nonatomic, retain) Video* video;
@property (nonatomic, retain) VideoTableData* videoTableData;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

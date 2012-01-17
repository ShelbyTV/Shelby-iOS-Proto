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
@class VideoTableViewController;

@interface VideoTableViewCell : UITableViewCell
{
    UIImageView *_bgView;
    UIView *_clipView;
    
    UIImageView *_videoView;
    UIImageView *_badgeView;
    UIView *_commentView;
    UIView *_videoFooterView;
    UIImageView *_sharerView;
    UILabel *_sharerComment;
    UILabel *_sharerName;
    UILabel *_shareTime;
    
    UIButton *_expandButton;
    
    BOOL _selected;
    
    NSMutableArray *_dupeComments;
    NSMutableArray *_dupeSharerNames;
    NSMutableArray *_dupeSharerImages;
    NSMutableArray *_dupeShareTimes;
    int _dupeCount;
    
    Video* _video;
    
    CGFloat _kCellWidth;
    CGFloat _kCellHeight;
    CGFloat _kVideoWidth;
    CGFloat _kVideoHeight;
    CGFloat _kBadgeWidth;
    CGFloat _kBadgeHeight;
    CGFloat _kCommentViewOriginX;
    CGFloat _kCommentViewOriginY;
    CGFloat _kCommentViewWidth;
    CGFloat _kCommentViewHeight;
    CGFloat _kVideoFooterOriginX;
    CGFloat _kVideoFooterOriginY;
    CGFloat _kVideoFooterWidth;
    CGFloat _kVideoFooterHeight;
    CGFloat _kSharerOriginX;
    CGFloat _kSharerOriginY;
    CGFloat _kSharerWidth;
    CGFloat _kSharerHeight;
    CGFloat _kCommentOriginX;
    CGFloat _kCommentOriginY;
    CGFloat _kCommentWidth;
    CGFloat _kCommentHeight;
    CGFloat _kSharerNameOriginX;
    CGFloat _kSharerNameOriginY;
    CGFloat _kSharerNameWidth;
    CGFloat _kSharerNameHeight;
    CGFloat _kSharetimeOriginX;
    CGFloat _kSharetimeOriginY;
    CGFloat _kSharetimeWidth;
    CGFloat _kSharetimeHeight;
    CGFloat _kCellHorizontalMargin;
    CGFloat _kCellVerticalMargin;
}

@property (nonatomic, retain) VideoTableData* videoTableData;
@property (nonatomic, retain) VideoTableViewController* viewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setVideo:(Video *)video;

@end

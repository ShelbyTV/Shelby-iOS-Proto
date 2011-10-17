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
}

@property (nonatomic, retain) VideoTableData* videoTableData;
@property (nonatomic, retain) VideoTableViewController* viewController;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setVideo:(Video *)video;

@end

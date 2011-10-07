//
//  VideoTableViewCell.m
//  Shelby
//
//  Created by Mark Johnson on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoTableViewCell.h"
#import "Video.h"
#import "VideoTableData.h"

#define IPAD_CELL_WIDTH 330
#define IPAD_CELL_HEIGHT 232

#define IPAD_VIDEO_WIDTH 290
#define IPAD_VIDEO_HEIGHT 163

#define IPAD_BADGE_WIDTH 33
#define IPAD_BADGE_HEIGHT 33

#define IPAD_VIDEO_FOOTER_ORIGIN_X 20
#define IPAD_VIDEO_FOOTER_ORIGIN_Y 183
#define IPAD_VIDEO_FOOTER_WIDTH 290
#define IPAD_VIDEO_FOOTER_HEIGHT 29

#define IPAD_SHARER_ORIGIN_X 27
#define IPAD_SHARER_ORIGIN_Y 190
#define IPAD_SHARER_WIDTH 16
#define IPAD_SHARER_HEIGHT 16

#define IPAD_SHARER_NAME_ORIGIN_X 55
#define IPAD_SHARER_NAME_ORIGIN_Y 187
#define IPAD_SHARER_NAME_WIDTH 136
#define IPAD_SHARER_NAME_HEIGHT 21

#define IPAD_SHARETIME_ORIGIN_X 199
#define IPAD_SHARETIME_ORIGIN_Y 187
#define IPAD_SHARETIME_WIDTH 99
#define IPAD_SHARETIME_HEIGHT 21

#define IPAD_CELL_HORIZ_MARGIN 20
#define IPAD_CELL_VERT_MARGIN 20

#define IPAD_COMMENT_ORIGIN_X 32
#define IPAD_COMMENT_ORIGIN_Y 132
#define IPAD_COMMENT_WIDTH 266
#define IPAD_COMMENT_HEIGHT 44

#define IPAD_COMMENT_VIEW_ORIGIN_X 20
#define IPAD_COMMENT_VIEW_ORIGIN_Y 125
#define IPAD_COMMENT_VIEW_WIDTH 290
#define IPAD_COMMENT_VIEW_HEIGHT 58


#define IPHONE_CELL_HORIZ_MARGIN 20
#define IPHONE_CELL_VERT_MARGIN 10

#define IPHONE_CELL_WIDTH 320
#define IPHONE_CELL_HEIGHT 118

#define IPHONE_VIDEO_WIDTH 121
#define IPHONE_VIDEO_HEIGHT 69

#define IPHONE_BADGE_WIDTH 33
#define IPHONE_BADGE_HEIGHT 33

#define IPHONE_COMMENT_VIEW_ORIGIN_X 141
#define IPHONE_COMMENT_VIEW_ORIGIN_Y 10
#define IPHONE_COMMENT_VIEW_WIDTH 159
#define IPHONE_COMMENT_VIEW_HEIGHT 69

#define IPHONE_VIDEO_FOOTER_ORIGIN_X 20
#define IPHONE_VIDEO_FOOTER_ORIGIN_Y 79
#define IPHONE_VIDEO_FOOTER_WIDTH 280
#define IPHONE_VIDEO_FOOTER_HEIGHT 29

#define IPHONE_SHARER_ORIGIN_X 27
#define IPHONE_SHARER_ORIGIN_Y 86
#define IPHONE_SHARER_WIDTH 16
#define IPHONE_SHARER_HEIGHT 16

#define IPHONE_COMMENT_ORIGIN_X 148
#define IPHONE_COMMENT_ORIGIN_Y 17
#define IPHONE_COMMENT_WIDTH 145
#define IPHONE_COMMENT_HEIGHT 55

#define IPHONE_SHARER_NAME_ORIGIN_X 55
#define IPHONE_SHARER_NAME_ORIGIN_Y 83
#define IPHONE_SHARER_NAME_WIDTH 136
#define IPHONE_SHARER_NAME_HEIGHT 21

#define IPHONE_SHARETIME_ORIGIN_X 174
#define IPHONE_SHARETIME_ORIGIN_Y 83
#define IPHONE_SHARETIME_WIDTH 99
#define IPHONE_SHARETIME_HEIGHT 21

@implementation VideoTableViewCell

@synthesize video;
@synthesize videoTableData;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.frame = CGRectMake(0, 0, IPAD_CELL_WIDTH, IPAD_CELL_HEIGHT);
            _videoView = [[UIImageView alloc] initWithFrame:CGRectMake(IPAD_CELL_HORIZ_MARGIN, IPAD_CELL_VERT_MARGIN, IPAD_VIDEO_WIDTH, IPAD_VIDEO_HEIGHT)];
            _badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(IPAD_CELL_HORIZ_MARGIN, IPAD_CELL_VERT_MARGIN, IPAD_BADGE_WIDTH, IPAD_BADGE_HEIGHT)];
            _commentView = [[UIView alloc] initWithFrame:CGRectMake(IPAD_COMMENT_VIEW_ORIGIN_X, IPAD_COMMENT_VIEW_ORIGIN_Y, IPAD_COMMENT_VIEW_WIDTH, IPAD_COMMENT_VIEW_HEIGHT)];
            _commentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
            _videoFooterView = [[UIView alloc] initWithFrame:CGRectMake(IPAD_VIDEO_FOOTER_ORIGIN_X, IPAD_VIDEO_FOOTER_ORIGIN_Y, IPAD_VIDEO_FOOTER_WIDTH, IPAD_VIDEO_FOOTER_HEIGHT)];
            _sharerView = [[UIImageView alloc] initWithFrame:CGRectMake(IPAD_SHARER_ORIGIN_X, IPAD_SHARER_ORIGIN_Y, IPAD_SHARER_WIDTH, IPAD_SHARER_HEIGHT)];
            _sharerComment = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_COMMENT_ORIGIN_X, IPAD_COMMENT_ORIGIN_Y, IPAD_COMMENT_WIDTH, IPAD_COMMENT_HEIGHT)];
            _sharerComment.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
            _sharerComment.numberOfLines = 2;
            _sharerName = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARER_NAME_ORIGIN_X, IPAD_SHARER_NAME_ORIGIN_Y, IPAD_SHARER_NAME_WIDTH, IPAD_SHARER_NAME_HEIGHT)];
            _shareTime = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARETIME_ORIGIN_X, IPAD_SHARETIME_ORIGIN_Y, IPAD_SHARETIME_WIDTH, IPAD_SHARETIME_HEIGHT)];
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.frame = CGRectMake(0, 0, IPHONE_CELL_WIDTH, IPHONE_CELL_HEIGHT);
            _videoView = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_CELL_HORIZ_MARGIN, IPHONE_CELL_VERT_MARGIN, IPHONE_VIDEO_WIDTH, IPHONE_VIDEO_HEIGHT)];
            _badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_CELL_HORIZ_MARGIN, IPHONE_CELL_VERT_MARGIN, IPHONE_BADGE_WIDTH, IPHONE_BADGE_HEIGHT)];
            _commentView = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_COMMENT_VIEW_ORIGIN_X, IPHONE_COMMENT_VIEW_ORIGIN_Y, IPHONE_COMMENT_VIEW_WIDTH, IPHONE_COMMENT_VIEW_HEIGHT)];
            _commentView.backgroundColor = [UIColor darkGrayColor];
            _videoFooterView = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_VIDEO_FOOTER_ORIGIN_X, IPHONE_VIDEO_FOOTER_ORIGIN_Y, IPHONE_VIDEO_FOOTER_WIDTH, IPHONE_VIDEO_FOOTER_HEIGHT)];
            _sharerView = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_SHARER_ORIGIN_X, IPHONE_SHARER_ORIGIN_Y, IPHONE_SHARER_WIDTH, IPHONE_SHARER_HEIGHT)];
            
            _sharerComment = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_COMMENT_ORIGIN_X, IPHONE_COMMENT_ORIGIN_Y, IPHONE_COMMENT_WIDTH, IPHONE_COMMENT_HEIGHT)];
            _sharerComment.font = [UIFont fontWithName:@"Thonburi-Bold" size:14.0];
            _sharerComment.numberOfLines = 3;
            _sharerName = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_SHARER_NAME_ORIGIN_X, IPHONE_SHARER_NAME_ORIGIN_Y, IPHONE_SHARER_NAME_WIDTH, IPHONE_SHARER_NAME_HEIGHT)];
            _shareTime = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_SHARETIME_ORIGIN_X, IPHONE_SHARETIME_ORIGIN_Y, IPHONE_SHARETIME_WIDTH, IPHONE_SHARETIME_HEIGHT)];
        }
        
        // same for both iPhone and iPad
        _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellGradient.png"]];
        _bgView.frame = self.bounds;
        _selected = FALSE;
        
        _videoFooterView.backgroundColor = [UIColor blackColor];

        _sharerComment.textColor = [UIColor whiteColor];
        _sharerComment.backgroundColor = [UIColor clearColor];
        
        _sharerName.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
        _sharerName.textColor = [UIColor whiteColor];
        _sharerName.backgroundColor = [UIColor clearColor];
        _sharerName.textAlignment = UITextAlignmentLeft;
        _sharerName.adjustsFontSizeToFitWidth = YES;
        _sharerName.minimumFontSize = 10.0;
        _sharerName.numberOfLines = 1;
        
        _shareTime.font = [UIFont fontWithName:@"Thonburi-Bold" size:14.0];
        _shareTime.textColor = [UIColor lightGrayColor];
        _shareTime.backgroundColor = [UIColor clearColor];
        _shareTime.textAlignment = UITextAlignmentRight;
        
        [self addSubview:_bgView];
        [self addSubview:_videoView];
        [self addSubview:_badgeView];
        [self addSubview:_commentView];
        [self addSubview:_videoFooterView];
        [self addSubview:_sharerView];
        [self addSubview:_sharerComment];
        [self addSubview:_sharerName];
        [self addSubview:_shareTime];
    }
    return self;
}

- (void)dealloc 
{
    [video release];
    [super dealloc];
}

- (void)setHighlighted:(BOOL)highlighted
{
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [self setHighlighted:highlighted];
}

- (void)setSelected:(BOOL)selected
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setSelected:selected];
}


- (NSString *)prettyDateDiff:(NSDate *)date
{
    
    NSTimeInterval diff = abs([date timeIntervalSinceNow]);
    NSInteger days = floor(diff / 86400.0);
    
	if (days == 0) {
        if (diff < 60) return @"JUST NOW";
        if (diff < 120) return @"1 MINUTE AGO";
        if (diff < 3600) return [NSString stringWithFormat:@"%d MINUTES AGO", (int)floor(diff/60.0)];
        if (diff < 7200) return @"1 HOUR AGO";
        if (diff < 86400) return [NSString stringWithFormat:@"%d HOURS AGO", (int)floor(diff/3600.0)];
    }
    
    if (days == 1) return @"YESTERDAY";
    if (days < 7) return [NSString stringWithFormat:@"%d DAYS AGO", days];
    if (days < 14) return @"LAST WEEK";
    if (days < 31) return [NSString stringWithFormat:@"%d WEEKS AGO", (int)ceil(days/7.0)];
    
    return @"FOREVER-AGO";
}

- (void)drawRect:(CGRect)rect
{
    _videoView.image = video.thumbnailImage;
    
    if ([video.source isEqualToString:@"twitter"]) {
        if (!video.isWatched) {
            _badgeView.image = [UIImage imageNamed:@"TwitterNew"];
        } else {
            _badgeView.image = [UIImage imageNamed:@"TwitterWatched"];
        }
    } else if ([video.source isEqualToString:@"facebook"]) {
        if (!video.isWatched) {
            _badgeView.image = [UIImage imageNamed:@"FacebookNew"];
        } else {
            _badgeView.image = [UIImage imageNamed:@"FacebookWatched"];
        }
    } else if ([video.source isEqualToString:@"tumblr"]) {
        if (!video.isWatched) {
            _badgeView.image = [UIImage imageNamed:@"TumblrNew"];
        } else {
            _badgeView.image = [UIImage imageNamed:@"TumblrWatched"];
        }
    } else if ([video.source isEqualToString:@"bookmarklet"]) {
        // clear image, so no watched/unwatched. easier than hiding/unhiding in this case.
        _badgeView.image = [UIImage imageNamed:@"Bookmarklet"];
    }
    
    _sharerView.image = video.sharerImage;

    if (NOT_NULL(video.sharerComment)) {
        _sharerComment.text = video.sharerComment;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _commentView.hidden = NO;
        }
    } else {
        _sharerComment.text = @"";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _commentView.hidden = YES;
        }
    }
 
    int dupeCount = [videoTableData videoDupeCount:video];
    if (dupeCount != 0) {
        _sharerName.text = [NSString stringWithFormat:@"%@ + %d MORE", video.sharer, dupeCount];
    } else {
        _sharerName.text = video.sharer;
    }
    
    _shareTime.text = [self prettyDateDiff:video.createdAt];
}

@end

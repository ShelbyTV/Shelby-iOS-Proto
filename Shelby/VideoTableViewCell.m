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
#import "VideoTableViewController.h"

#define IPAD_CELL_WIDTH 330
#define IPAD_CELL_HEIGHT 232

#define IPAD_VIDEO_WIDTH 290
#define IPAD_VIDEO_HEIGHT 163

#define IPAD_BADGE_WIDTH 33
#define IPAD_BADGE_HEIGHT 33

#define IPAD_VIDEO_FOOTER_ORIGIN_X 0
#define IPAD_VIDEO_FOOTER_ORIGIN_Y 163
#define IPAD_VIDEO_FOOTER_WIDTH 290
#define IPAD_VIDEO_FOOTER_HEIGHT 29

#define IPAD_SHARER_ORIGIN_X 7
#define IPAD_SHARER_ORIGIN_Y 170
#define IPAD_SHARER_WIDTH 16
#define IPAD_SHARER_HEIGHT 16

#define IPAD_SHARER_NAME_ORIGIN_X 35
#define IPAD_SHARER_NAME_ORIGIN_Y 167
#define IPAD_SHARER_NAME_WIDTH 136
#define IPAD_SHARER_NAME_HEIGHT 21

#define IPAD_SHARETIME_ORIGIN_X 179
#define IPAD_SHARETIME_ORIGIN_Y 167
#define IPAD_SHARETIME_WIDTH 99
#define IPAD_SHARETIME_HEIGHT 21

#define IPAD_CELL_HORIZ_MARGIN 20
#define IPAD_CELL_VERT_MARGIN 20

#define IPAD_COMMENT_ORIGIN_X 12
#define IPAD_COMMENT_ORIGIN_Y 112
#define IPAD_COMMENT_WIDTH 266
#define IPAD_COMMENT_HEIGHT 44

#define IPAD_COMMENT_VIEW_ORIGIN_X 0
#define IPAD_COMMENT_VIEW_ORIGIN_Y 105
#define IPAD_COMMENT_VIEW_WIDTH 290
#define IPAD_COMMENT_VIEW_HEIGHT 58

#define IPAD_EXPANDED_COMMENT_MARGIN 10


#define IPHONE_CELL_HORIZ_MARGIN 20
#define IPHONE_CELL_VERT_MARGIN 10

#define IPHONE_CELL_WIDTH 320
#define IPHONE_CELL_HEIGHT 118

#define IPHONE_VIDEO_WIDTH 121
#define IPHONE_VIDEO_HEIGHT 69

#define IPHONE_BADGE_WIDTH 33
#define IPHONE_BADGE_HEIGHT 33

#define IPHONE_COMMENT_VIEW_ORIGIN_X 121
#define IPHONE_COMMENT_VIEW_ORIGIN_Y 10
#define IPHONE_COMMENT_VIEW_WIDTH 159
#define IPHONE_COMMENT_VIEW_HEIGHT 69

#define IPHONE_VIDEO_FOOTER_ORIGIN_X 20
#define IPHONE_VIDEO_FOOTER_ORIGIN_Y 69
#define IPHONE_VIDEO_FOOTER_WIDTH 280
#define IPHONE_VIDEO_FOOTER_HEIGHT 29

#define IPHONE_SHARER_ORIGIN_X 7
#define IPHONE_SHARER_ORIGIN_Y 76
#define IPHONE_SHARER_WIDTH 16
#define IPHONE_SHARER_HEIGHT 16

#define IPHONE_COMMENT_ORIGIN_X 128
#define IPHONE_COMMENT_ORIGIN_Y 7
#define IPHONE_COMMENT_WIDTH 145
#define IPHONE_COMMENT_HEIGHT 55

#define IPHONE_SHARER_NAME_ORIGIN_X 35
#define IPHONE_SHARER_NAME_ORIGIN_Y 74
#define IPHONE_SHARER_NAME_WIDTH 136
#define IPHONE_SHARER_NAME_HEIGHT 21

#define IPHONE_SHARETIME_ORIGIN_X 174
#define IPHONE_SHARETIME_ORIGIN_Y 73
#define IPHONE_SHARETIME_WIDTH 99
#define IPHONE_SHARETIME_HEIGHT 21

@implementation VideoTableViewCell

@synthesize videoTableData;
@synthesize viewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _dupeComments = [[NSMutableArray alloc] init];
        _dupeSharerNames = [[NSMutableArray alloc] init];
        _dupeSharerImages = [[NSMutableArray alloc] init];
        _dupeShareTimes = [[NSMutableArray alloc] init];
        _sharerName = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.frame = CGRectMake(0, 0, IPAD_CELL_WIDTH, IPAD_CELL_HEIGHT);
            _videoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPAD_VIDEO_WIDTH, IPAD_VIDEO_HEIGHT)];
            _badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPAD_BADGE_WIDTH, IPAD_BADGE_HEIGHT)];
            _commentView = [[UIView alloc] initWithFrame:CGRectMake(IPAD_COMMENT_VIEW_ORIGIN_X, IPAD_COMMENT_VIEW_ORIGIN_Y, IPAD_COMMENT_VIEW_WIDTH, IPAD_COMMENT_VIEW_HEIGHT)];
            _commentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
            _videoFooterView = [[UIView alloc] initWithFrame:CGRectMake(IPAD_VIDEO_FOOTER_ORIGIN_X, IPAD_VIDEO_FOOTER_ORIGIN_Y, IPAD_VIDEO_FOOTER_WIDTH, IPAD_VIDEO_FOOTER_HEIGHT)];
            _sharerView = [[UIImageView alloc] initWithFrame:CGRectMake(IPAD_SHARER_ORIGIN_X, IPAD_SHARER_ORIGIN_Y, IPAD_SHARER_WIDTH, IPAD_SHARER_HEIGHT)];
            _sharerComment = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_COMMENT_ORIGIN_X, IPAD_COMMENT_ORIGIN_Y, IPAD_COMMENT_WIDTH, IPAD_COMMENT_HEIGHT)];
            _sharerComment.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
            _sharerComment.numberOfLines = 2;
            _sharerName.frame = CGRectMake(IPAD_SHARER_NAME_ORIGIN_X, IPAD_SHARER_NAME_ORIGIN_Y, IPAD_SHARER_NAME_WIDTH, IPAD_SHARER_NAME_HEIGHT);
            _shareTime = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARETIME_ORIGIN_X, IPAD_SHARETIME_ORIGIN_Y, IPAD_SHARETIME_WIDTH, IPAD_SHARETIME_HEIGHT)];
            _clipView = [[UIView alloc] initWithFrame:CGRectMake(IPAD_CELL_HORIZ_MARGIN, IPAD_CELL_VERT_MARGIN, IPAD_VIDEO_WIDTH, IPAD_VIDEO_HEIGHT + IPAD_VIDEO_FOOTER_HEIGHT)];
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.frame = CGRectMake(0, 0, IPHONE_CELL_WIDTH, IPHONE_CELL_HEIGHT);
            _videoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_VIDEO_WIDTH, IPHONE_VIDEO_HEIGHT)];
            _badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_BADGE_WIDTH, IPHONE_BADGE_HEIGHT)];
            _commentView = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_COMMENT_VIEW_ORIGIN_X, 0, IPHONE_COMMENT_VIEW_WIDTH, IPHONE_COMMENT_VIEW_HEIGHT)];
            _commentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
            _videoFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, IPHONE_VIDEO_FOOTER_ORIGIN_Y, IPHONE_VIDEO_FOOTER_WIDTH, IPHONE_VIDEO_FOOTER_HEIGHT)];
            _sharerView = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_SHARER_ORIGIN_X, IPHONE_SHARER_ORIGIN_Y, IPHONE_SHARER_WIDTH, IPHONE_SHARER_HEIGHT)];
            
            _sharerComment = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_COMMENT_ORIGIN_X, IPHONE_COMMENT_ORIGIN_Y, IPHONE_COMMENT_WIDTH, IPHONE_COMMENT_HEIGHT)];
            _sharerComment.font = [UIFont fontWithName:@"Thonburi-Bold" size:14.0];
            _sharerComment.numberOfLines = 3;
            _sharerName.frame = CGRectMake(IPHONE_SHARER_NAME_ORIGIN_X, IPHONE_SHARER_NAME_ORIGIN_Y, IPHONE_SHARER_NAME_WIDTH, IPHONE_SHARER_NAME_HEIGHT);
            _shareTime = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_SHARETIME_ORIGIN_X, IPHONE_SHARETIME_ORIGIN_Y, IPHONE_SHARETIME_WIDTH, IPHONE_SHARETIME_HEIGHT)];
            _clipView = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_CELL_HORIZ_MARGIN, IPHONE_CELL_VERT_MARGIN, IPHONE_VIDEO_WIDTH + IPHONE_COMMENT_VIEW_WIDTH, IPHONE_VIDEO_HEIGHT + IPHONE_VIDEO_FOOTER_HEIGHT)];
            
            // don't have all the right iPhone code yet...
            [_sharerName setEnabled:NO];
        }
        
        // same for both iPhone and iPad
        _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellGradient.png"]];
        _bgView.frame = self.bounds;
        _clipView.clipsToBounds = TRUE;
        
        _selected = FALSE;
        
        _videoFooterView.backgroundColor = [UIColor blackColor];

        _sharerComment.textColor = [UIColor whiteColor];
        _sharerComment.backgroundColor = [UIColor clearColor];
        
        [_sharerName addTarget:self action:@selector(sharerNamePressed) forControlEvents:UIControlEventTouchUpInside];
        [_sharerName setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _sharerName.titleLabel.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
        _sharerName.titleLabel.textColor = [UIColor whiteColor];
        _sharerName.titleLabel.backgroundColor = [UIColor clearColor];
        _sharerName.titleLabel.adjustsFontSizeToFitWidth = YES;
        _sharerName.titleLabel.minimumFontSize = 10.0;
        _sharerName.titleLabel.numberOfLines = 1;
        
        _shareTime.font = [UIFont fontWithName:@"Thonburi-Bold" size:14.0];
        _shareTime.textColor = [UIColor lightGrayColor];
        _shareTime.backgroundColor = [UIColor clearColor];
        _shareTime.textAlignment = UITextAlignmentRight;
        
        _bgView.userInteractionEnabled = TRUE;
                
        [self addSubview:_bgView];
        [_bgView addSubview:_clipView];
        
        [_clipView addSubview:_videoView];
        [_clipView addSubview:_badgeView];
        [_clipView addSubview:_commentView];
        [_clipView addSubview:_videoFooterView];
        [_clipView addSubview:_sharerView];
        [_clipView addSubview:_sharerComment];
        [_clipView addSubview:_sharerName];
        [_clipView addSubview:_shareTime];
    }
    return self;
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

- (CGSize)getCommentTextSize:(NSString *)comment
{
    CGFloat maxTextWidth = IPAD_VIDEO_WIDTH - IPAD_SHARER_NAME_ORIGIN_X - 7; // 7 is right margin?
    CGSize textSize = [comment sizeWithFont:[UIFont fontWithName:@"Thonburi-Bold" size:16.0]
                          constrainedToSize:CGSizeMake(maxTextWidth, IPAD_COMMENT_HEIGHT * 2)
                              lineBreakMode:UILineBreakModeTailTruncation];
    
    return textSize;
}

- (void)sizeFramesForComments
{
    // overall frame
    CGRect tempFrame = self.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments : IPAD_CELL_HEIGHT;
    self.frame = tempFrame;
    
    // clip view frame
    tempFrame = _clipView.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments - 2 * IPAD_CELL_VERT_MARGIN : IPAD_VIDEO_HEIGHT + IPAD_VIDEO_FOOTER_HEIGHT;
    _clipView.frame = tempFrame;
    
    tempFrame = _videoFooterView.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments - 2 * IPAD_CELL_VERT_MARGIN - IPAD_VIDEO_HEIGHT : IPAD_VIDEO_FOOTER_HEIGHT;
    _videoFooterView.frame = tempFrame;
    
    [_clipView setNeedsDisplay];
    
    // iPad comment overlay
    _commentView.alpha = (_video.allComments ? 0.0 : 1.0);
    _sharerComment.alpha = (_video.allComments ? 0.0 : 1.0);
}

- (void)setVideo:(Video *)video
{
    // use this to clean up old videos also from cell caching
    if (NOT_NULL(_video)) {
        [_video release];
    }
    _video = [video retain];
    
    if (!_video.hasBeenDisplayed) {
        _video.allComments = FALSE;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _video.cellHeightCurrent = IPAD_CELL_HEIGHT;
        } else {
            _video.cellHeightCurrent = IPHONE_CELL_HEIGHT;
        }
    }
    
    _video.hasBeenDisplayed = TRUE;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return;
    }
        
    for (UILabel *dupeComment in _dupeComments)
    {
        [dupeComment removeFromSuperview];
        [dupeComment release];
    }
    [_dupeComments removeAllObjects];
    
    for (UIImageView *dupeSharerImage in _dupeSharerImages)
    {
        [dupeSharerImage removeFromSuperview];
        [dupeSharerImage release];
    }
    [_dupeSharerImages removeAllObjects];
    
    for (UILabel *dupeSharerName in _dupeSharerNames)
    {
        [dupeSharerName removeFromSuperview];
        [dupeSharerName release];
    }
    [_dupeSharerNames removeAllObjects];
    
    for (UILabel *dupeShareTime in _dupeShareTimes)
    {
        [dupeShareTime removeFromSuperview];
        [dupeShareTime release];
    }
    [_dupeShareTimes removeAllObjects];
    
    // assumes dupe count doesn't change over video lifetime
    if([videoTableData videoDupeCount:_video] == 0) {
        _video.cellHeightAllComments = IPAD_CELL_HEIGHT;
        [self sizeFramesForComments];
        return;
    }
    
    BOOL first = TRUE;
    
    float additionalHeight = 0.0;
    
    // go through all duplicate videos and add in comment stuff...
    for (Video *dupe in [videoTableData videoDupes:_video]) {
        if (first) {
            // only need comment for this one, other stuff taken care of already
            CGSize textSize;
            if (NOT_NULL(dupe.sharerComment)) {
                textSize = [self getCommentTextSize:dupe.sharerComment];
            } else {
                textSize = [self getCommentTextSize:dupe.title];
            }
            
            UILabel *dupeComment = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARER_NAME_ORIGIN_X, IPAD_VIDEO_FOOTER_HEIGHT + IPAD_VIDEO_HEIGHT - 4, textSize.width, textSize.height)];
            dupeComment.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
            dupeComment.numberOfLines = 4;
            if (NOT_NULL(dupe.sharerComment)) {
                dupeComment.text = dupe.sharerComment;
            } else {
                dupeComment.text = dupe.title;
            }
            dupeComment.textColor = [UIColor whiteColor];
            dupeComment.backgroundColor = [UIColor clearColor];
            
            [_dupeComments addObject:dupeComment];
            [_clipView addSubview:dupeComment];
            
            additionalHeight += textSize.height;
            additionalHeight += IPAD_EXPANDED_COMMENT_MARGIN - 4;
            
            first = FALSE;
        } else {
            CGSize textSize;
            if (NOT_NULL(dupe.sharerComment)) {
                textSize = [self getCommentTextSize:dupe.sharerComment];
            } else {
                textSize = [self getCommentTextSize:dupe.title];
            }
            
            UIImageView *dupeSharerImage = [[UIImageView alloc] initWithFrame:CGRectMake(IPAD_SHARER_ORIGIN_X, IPAD_SHARER_ORIGIN_Y + IPAD_VIDEO_FOOTER_HEIGHT + additionalHeight, IPAD_SHARER_WIDTH, IPAD_SHARER_HEIGHT)];
            dupeSharerImage.image = dupe.sharerImage;
            
            UILabel *dupeSharerName = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARER_NAME_ORIGIN_X, IPAD_SHARER_ORIGIN_Y + IPAD_VIDEO_FOOTER_HEIGHT + additionalHeight - 4, IPAD_SHARER_NAME_WIDTH, IPAD_SHARER_NAME_HEIGHT)];
            
            dupeSharerName.textAlignment = UITextAlignmentLeft;
            dupeSharerName.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
            dupeSharerName.textColor = [UIColor whiteColor];
            dupeSharerName.backgroundColor = [UIColor clearColor];
            dupeSharerName.adjustsFontSizeToFitWidth = YES;
            dupeSharerName.minimumFontSize = 10.0;
            dupeSharerName.numberOfLines = 1;
            dupeSharerName.text = dupe.sharer;
            
            UILabel *dupeShareTime = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARETIME_ORIGIN_X, IPAD_SHARETIME_ORIGIN_Y + IPAD_VIDEO_FOOTER_HEIGHT + additionalHeight - 4, IPAD_SHARETIME_WIDTH, IPAD_SHARETIME_HEIGHT)];
            
            dupeShareTime.font = [UIFont fontWithName:@"Thonburi-Bold" size:14.0];
            dupeShareTime.textColor = [UIColor lightGrayColor];
            dupeShareTime.backgroundColor = [UIColor clearColor];
            dupeShareTime.textAlignment = UITextAlignmentRight;
            dupeShareTime.numberOfLines = 1;
            dupeShareTime.text = [self prettyDateDiff:dupe.createdAt];
            
            additionalHeight += IPAD_SHARER_HEIGHT + 8;
            
            UILabel *dupeComment = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARER_NAME_ORIGIN_X, IPAD_VIDEO_FOOTER_HEIGHT + IPAD_VIDEO_HEIGHT + additionalHeight, textSize.width, textSize.height)];
            dupeComment.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
            dupeComment.numberOfLines = 4;
            if (NOT_NULL(dupe.sharerComment)) {
                dupeComment.text = dupe.sharerComment;
            } else {
                dupeComment.text = dupe.title;
            }
            dupeComment.textColor = [UIColor whiteColor];
            dupeComment.backgroundColor = [UIColor clearColor];
            
            [_dupeShareTimes addObject:dupeShareTime];
            [_clipView addSubview:dupeShareTime];

            [_dupeSharerNames addObject:dupeSharerName];
            [_clipView addSubview:dupeSharerName];
            
            [_dupeComments addObject:dupeComment];
            [_clipView addSubview:dupeComment];
            
            [_dupeSharerImages addObject:dupeSharerImage];
            [_clipView addSubview:dupeSharerImage];
            
            additionalHeight += textSize.height;
            additionalHeight += IPAD_EXPANDED_COMMENT_MARGIN;
        }
    }
    
    _video.cellHeightAllComments = IPAD_CELL_HEIGHT + additionalHeight;

    [self sizeFramesForComments];
}

- (void)dealloc 
{
    [_video release];
    [super dealloc];
}

- (void)sharerNamePressed
{
    if([videoTableData videoDupeCount:_video] != 0) {
        _video.allComments = !_video.allComments;
        
        // the Video* cache of height information that we can use in the table view controller
        _video.cellHeightCurrent = _video.allComments ? _video.cellHeightAllComments : IPAD_CELL_HEIGHT;    
        
        // 0.275 seems to match the OS default fairly well for table cell height adjustment animation
        [UIView animateWithDuration:0.275 animations:^{
            [self sizeFramesForComments];
        }
        completion:^(BOOL finished){
        // NOP
        }];

        // forces an update of all the table cell heights
        [self setNeedsDisplay];
        [viewController.tableView beginUpdates];
        [viewController.tableView endUpdates];
    }

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

- (void)drawRect:(CGRect)rect
{
    _videoView.image = _video.thumbnailImage;
    
    if ([_video.source isEqualToString:@"twitter"]) {
        if (!_video.isWatched) {
            _badgeView.image = [UIImage imageNamed:@"TwitterNew"];
        } else {
            _badgeView.image = [UIImage imageNamed:@"TwitterWatched"];
        }
    } else if ([_video.source isEqualToString:@"facebook"]) {
        if (!_video.isWatched) {
            _badgeView.image = [UIImage imageNamed:@"FacebookNew"];
        } else {
            _badgeView.image = [UIImage imageNamed:@"FacebookWatched"];
        }
    } else if ([_video.source isEqualToString:@"tumblr"]) {
        if (!_video.isWatched) {
            _badgeView.image = [UIImage imageNamed:@"TumblrNew"];
        } else {
            _badgeView.image = [UIImage imageNamed:@"TumblrWatched"];
        }
    } else if ([_video.source isEqualToString:@"bookmarklet"]) {
        // clear image, so no watched/unwatched. easier than hiding/unhiding in this case.
        _badgeView.image = [UIImage imageNamed:@"Bookmarklet"];
    }
    
    _sharerView.image = _video.sharerImage;

    if (IS_NULL(_video.sharerComment)) {
        _sharerComment.text = _video.title;
    } else {
        _sharerComment.text = _video.sharerComment;
    }
 
    int dupeCount = [videoTableData videoDupeCount:_video];
    
    if (dupeCount != 0) {
        [_sharerName setTitle:[NSString stringWithFormat:@"%@ + %d MORE", _video.sharer, dupeCount] forState:UIControlStateNormal];
    } else {
        [_sharerName setTitle:_video.sharer forState:UIControlStateNormal];
    }
    
    _shareTime.text = [self prettyDateDiff:_video.createdAt];
}

@end

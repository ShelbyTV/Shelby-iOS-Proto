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
#import "VideoTableViewCellConstants.h"

@implementation VideoTableViewCell

@synthesize videoTableData;
@synthesize viewController;

#pragma mark - Init

- (void)initIPad
{
    self.frame = CGRectMake(0, 0, IPAD_CELL_WIDTH, IPAD_CELL_HEIGHT);
    _videoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPAD_VIDEO_WIDTH, IPAD_VIDEO_HEIGHT)];
    _badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPAD_BADGE_WIDTH, IPAD_BADGE_HEIGHT)];
    _commentView = [[UIView alloc] initWithFrame:CGRectMake(IPAD_COMMENT_VIEW_ORIGIN_X, IPAD_COMMENT_VIEW_ORIGIN_Y, IPAD_COMMENT_VIEW_WIDTH, IPAD_COMMENT_VIEW_HEIGHT)];
    _commentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    _videoFooterView = [[UIView alloc] initWithFrame:CGRectMake(IPAD_VIDEO_FOOTER_ORIGIN_X, IPAD_VIDEO_FOOTER_ORIGIN_Y, IPAD_VIDEO_FOOTER_WIDTH, IPAD_VIDEO_FOOTER_HEIGHT)];
    _sharerView = [[UIImageView alloc] initWithFrame:CGRectMake(IPAD_SHARER_ORIGIN_X, IPAD_SHARER_ORIGIN_Y, IPAD_SHARER_WIDTH, IPAD_SHARER_HEIGHT)];
    _sharerComment = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_COMMENT_ORIGIN_X, IPAD_COMMENT_ORIGIN_Y, IPAD_COMMENT_WIDTH, IPAD_COMMENT_HEIGHT)];
    _sharerComment.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
    _sharerComment.numberOfLines = 1;
    _sharerName = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARER_NAME_ORIGIN_X, IPAD_SHARER_NAME_ORIGIN_Y, IPAD_SHARER_NAME_WIDTH, IPAD_SHARER_NAME_HEIGHT)];
    _shareTime = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARETIME_ORIGIN_X, IPAD_SHARETIME_ORIGIN_Y, IPAD_SHARETIME_WIDTH, IPAD_SHARETIME_HEIGHT)];
    _clipView = [[UIView alloc] initWithFrame:CGRectMake(IPAD_CELL_HORIZ_MARGIN, IPAD_CELL_VERT_MARGIN, IPAD_VIDEO_WIDTH, IPAD_VIDEO_HEIGHT + IPAD_VIDEO_FOOTER_HEIGHT)];
    
    _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _expandButton.frame = CGRectMake(0, IPAD_COMMENT_VIEW_ORIGIN_Y, IPAD_VIDEO_WIDTH, IPAD_COMMENT_VIEW_HEIGHT + IPAD_VIDEO_FOOTER_HEIGHT);
    [_expandButton addTarget:self action:@selector(sharerNamePressed) forControlEvents:UIControlEventTouchUpInside];
    _expandButton.backgroundColor = [UIColor clearColor];
}

- (void)initIPhone
{
    self.frame = CGRectMake(0, 0, IPHONE_CELL_WIDTH, IPHONE_CELL_HEIGHT);
    _videoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_VIDEO_WIDTH, IPHONE_VIDEO_HEIGHT)];
    _badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_BADGE_WIDTH, IPHONE_BADGE_HEIGHT)];
    _commentView = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_COMMENT_VIEW_ORIGIN_X, 0, IPHONE_COMMENT_VIEW_WIDTH, IPHONE_COMMENT_VIEW_HEIGHT)];
    _commentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    _videoFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, IPHONE_VIDEO_FOOTER_ORIGIN_Y, IPHONE_VIDEO_FOOTER_WIDTH, IPHONE_VIDEO_FOOTER_HEIGHT)];
    _sharerView = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_SHARER_ORIGIN_X, IPHONE_SHARER_ORIGIN_Y, IPHONE_SHARER_WIDTH, IPHONE_SHARER_HEIGHT)];
    
    _sharerComment = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_COMMENT_ORIGIN_X, IPHONE_COMMENT_ORIGIN_Y, IPHONE_COMMENT_WIDTH, IPHONE_COMMENT_HEIGHT)];
    _sharerComment.font = [UIFont fontWithName:@"Thonburi-Bold" size:14.0];
    _sharerComment.numberOfLines = 3;
    _sharerName = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_SHARER_NAME_ORIGIN_X, IPHONE_SHARER_NAME_ORIGIN_Y, IPHONE_SHARER_NAME_WIDTH, IPHONE_SHARER_NAME_HEIGHT)];
    _shareTime = [[UILabel alloc] initWithFrame:CGRectMake(IPHONE_SHARETIME_ORIGIN_X, IPHONE_SHARETIME_ORIGIN_Y, IPHONE_SHARETIME_WIDTH, IPHONE_SHARETIME_HEIGHT)];
    _clipView = [[UIView alloc] initWithFrame:CGRectMake(IPHONE_CELL_HORIZ_MARGIN, IPHONE_CELL_VERT_MARGIN, IPHONE_VIDEO_WIDTH + IPHONE_COMMENT_VIEW_WIDTH, IPHONE_VIDEO_HEIGHT + IPHONE_VIDEO_FOOTER_HEIGHT)];
}

- (void)initCommon
{
    _dupeComments = [[NSMutableArray alloc] init];
    _dupeSharerNames = [[NSMutableArray alloc] init];
    _dupeSharerImages = [[NSMutableArray alloc] init];
    _dupeShareTimes = [[NSMutableArray alloc] init];
    
    _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellGradient.png"]];
    _bgView.frame = self.bounds;
    _clipView.clipsToBounds = TRUE;
    
    _selected = FALSE;
    _dupeCount = 0;
    
    _videoFooterView.backgroundColor = [UIColor blackColor];
    
    _sharerComment.textColor = [UIColor whiteColor];
    _sharerComment.backgroundColor = [UIColor clearColor];
    
    _sharerName.textAlignment = UITextAlignmentLeft;
    _sharerName.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
    _sharerName.textColor = [UIColor whiteColor];
    _sharerName.backgroundColor = [UIColor clearColor];
    _sharerName.adjustsFontSizeToFitWidth = YES;
    _sharerName.minimumFontSize = 10.0;
    _sharerName.numberOfLines = 1;
    
    _shareTime.font = [UIFont fontWithName:@"Thonburi-Bold" size:14.0];
    _shareTime.textColor = [UIColor lightGrayColor];
    _shareTime.backgroundColor = [UIColor clearColor];
    _shareTime.textAlignment = UITextAlignmentRight;
    _shareTime.adjustsFontSizeToFitWidth = YES;
    _shareTime.numberOfLines = 1;
    _shareTime.minimumFontSize = 10.0;
    
    _bgView.userInteractionEnabled = TRUE;
    
    _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _clipView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _commentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    _videoFooterView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    _shareTime.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _sharerComment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _sharerName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self initIPad];
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self initIPhone];
        }
        
        [self initCommon];
        
        // must add _expandButton subview after the subviews in initCommon
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_clipView addSubview:_expandButton];
        }
    }
    return self;
}

#pragma mark - Helper Methods

- (NSString *)prettyDateDiff:(NSDate *)date
{
    NSTimeInterval diff = MAX(-1 * [date timeIntervalSinceNow], 0);
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
    return [comment sizeWithFont:[UIFont fontWithName:@"Thonburi-Bold" size:16.0]
               constrainedToSize:CGSizeMake(maxTextWidth, 80)
                   lineBreakMode:UILineBreakModeTailTruncation];
}

- (void)sizeFramesForComments
{
    // overall frame
    CGRect tempFrame = self.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments : IPAD_CELL_HEIGHT;
    self.frame = tempFrame;

    // bg frame - necessary to make sure button touchable area isn't clipped
    _bgView.frame = self.bounds;
    
    // clip view frame
    tempFrame = _clipView.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments - 2 * IPAD_CELL_VERT_MARGIN : IPAD_VIDEO_HEIGHT + IPAD_VIDEO_FOOTER_HEIGHT;
    _clipView.frame = tempFrame;
    
    tempFrame = _videoFooterView.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments - 2 * IPAD_CELL_VERT_MARGIN - IPAD_VIDEO_HEIGHT : IPAD_VIDEO_FOOTER_HEIGHT;
    _videoFooterView.frame = tempFrame;
    
    tempFrame = _expandButton.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments: IPAD_COMMENT_VIEW_HEIGHT + IPAD_VIDEO_FOOTER_HEIGHT;
    tempFrame.origin.y = _video.allComments ? IPAD_VIDEO_FOOTER_ORIGIN_Y : IPAD_COMMENT_VIEW_ORIGIN_Y;
    _expandButton.frame = tempFrame;
    
    [_clipView setNeedsDisplay];
    
    // iPad comment overlay
    _commentView.alpha = (_video.allComments ? 0.0 : 1.0);
    _sharerComment.alpha = (_video.allComments ? 0.0 : 1.0);
}

- (void)clearViewArray:(NSMutableArray *)array
{
    for (UIView *view in array)
    {
        [view removeFromSuperview];
        [view release];
    }
    [array removeAllObjects]; 
}

- (void)clearDupeData
{
    [self clearViewArray:_dupeComments];
    [self clearViewArray:_dupeSharerImages];
    [self clearViewArray:_dupeSharerNames];
    [self clearViewArray:_dupeShareTimes];
}

#pragma mark - Video Setting

- (void)setVideo:(Video *)video
{
    // use this to clean up old videos also from cell caching
    if (NOT_NULL(_video)) {
        [_video release];
    }
    _video = [video retain];

    [self clearDupeData];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return;
    }
    
    NSArray *dupes = [videoTableData videoDupes:_video];
    _dupeCount = [dupes count] - 1;
    
    // assumes dupe count doesn't change over video lifetime
    if(_dupeCount == 0) {
        _video.cellHeightAllComments = IPAD_CELL_HEIGHT;
        [self sizeFramesForComments];
        [_expandButton setEnabled:NO];
        return;
    }
    
    [_expandButton setEnabled:YES];
    BOOL first = TRUE;
    
    float additionalHeight = 0.0;
    
    // go through all duplicate videos and add in comment stuff...
    for (Video *dupe in dupes) {
        if (!first) {
            UIImageView *dupeSharerImage = [[UIImageView alloc] initWithFrame:CGRectMake(IPAD_SHARER_ORIGIN_X, IPAD_SHARER_ORIGIN_Y + IPAD_VIDEO_FOOTER_HEIGHT + additionalHeight, IPAD_SHARER_WIDTH, IPAD_SHARER_HEIGHT)];
            // actual sharer image gets set in drawRect, so that a setNeedsDisplay will pick up newly downloaded sharer images
            
            UILabel *dupeSharerName = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARER_NAME_ORIGIN_X, IPAD_SHARER_ORIGIN_Y + IPAD_VIDEO_FOOTER_HEIGHT + additionalHeight + 2, IPAD_SHARER_NAME_WIDTH, IPAD_SHARER_NAME_HEIGHT)];
            
            dupeSharerName.textAlignment = UITextAlignmentLeft;
            dupeSharerName.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
            dupeSharerName.textColor = [UIColor whiteColor];
            dupeSharerName.backgroundColor = [UIColor clearColor];
            dupeSharerName.adjustsFontSizeToFitWidth = YES;
            dupeSharerName.minimumFontSize = 10.0;
            dupeSharerName.numberOfLines = 1;
            dupeSharerName.text = dupe.sharer;
            
            UILabel *dupeShareTime = [[UILabel alloc] initWithFrame:CGRectMake(IPAD_SHARETIME_ORIGIN_X, IPAD_SHARETIME_ORIGIN_Y + IPAD_VIDEO_FOOTER_HEIGHT + additionalHeight + 2, IPAD_SHARETIME_WIDTH, IPAD_SHARETIME_HEIGHT)];
            
            dupeShareTime.font = [UIFont fontWithName:@"Thonburi-Bold" size:14.0];
            dupeShareTime.textColor = [UIColor lightGrayColor];
            dupeShareTime.backgroundColor = [UIColor clearColor];
            dupeShareTime.textAlignment = UITextAlignmentRight;
            dupeShareTime.adjustsFontSizeToFitWidth = YES;
            dupeShareTime.minimumFontSize = 10.0;
            dupeShareTime.numberOfLines = 1;
            dupeShareTime.text = [self prettyDateDiff:dupe.createdAt];
            
            additionalHeight += IPAD_SHARER_HEIGHT + 8;
            
            [_dupeShareTimes addObject:dupeShareTime];
            [_clipView addSubview:dupeShareTime];
            
            [_dupeSharerNames addObject:dupeSharerName];
            [_clipView addSubview:dupeSharerName];
            
            [_dupeSharerImages addObject:dupeSharerImage];
            [_clipView addSubview:dupeSharerImage];
        }

        CGSize textSize;
        if (NOT_NULL(dupe.sharerComment)) {
            textSize = [self getCommentTextSize:dupe.sharerComment];
        } else {
            textSize = [self getCommentTextSize:dupe.title];
        }
        
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
        
        [_dupeComments addObject:dupeComment];
        [_clipView addSubview:dupeComment];
        
        additionalHeight += textSize.height;
        additionalHeight += IPAD_EXPANDED_COMMENT_MARGIN;
        
        first = FALSE;
    }
    
    [_expandButton removeFromSuperview];
    [_clipView addSubview:_expandButton];
    
    _video.cellHeightAllComments = IPAD_CELL_HEIGHT + additionalHeight;

    [self sizeFramesForComments];
}

#pragma mark - Dealloc

- (void)dealloc 
{
    [_video release];
    [super dealloc];
}

#pragma mark - Actions

- (void)sharerNamePressed
{
    if(_dupeCount == 0) {
        return;
    }
    
    _video.allComments = !_video.allComments;
    
    // the Video* cache of height information that we can use in the table view controller
    _video.cellHeightCurrent = _video.allComments ? _video.cellHeightAllComments : IPAD_CELL_HEIGHT;    
    
    // 0.275 seems to match the OS default fairly well for table cell height adjustment animation
    [UIView animateWithDuration:0.275 animations:^{
        [self sizeFramesForComments];
    }];
    
    // forces an update of all the table cell heights
    [self setNeedsDisplay];
    [viewController.tableView beginUpdates];
    [viewController.tableView endUpdates];
}

#pragma mark - Table Cell Methods

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

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    if (NOT_NULL(_video.thumbnailImage)) {
        _videoView.image = _video.thumbnailImage;
    } else {
        _videoView.image = [UIImage imageNamed:@"VideoMissing"];
    }
        
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
    
    if (NOT_NULL(_video.sharerImage)) {
        _sharerView.image = _video.sharerImage;
    } else {
        _sharerView.image = [UIImage imageNamed:@"PlaceholderFace"];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && _dupeCount != 0)
    {
        BOOL first = TRUE;
        NSUInteger i = 0;
        NSArray *dupes = [videoTableData videoDupes:_video];
        for (Video *dupe in dupes) {
            if (first) {
                first = FALSE;
                continue;
            }
            UIImageView *dupeSharerImage = [_dupeSharerImages objectAtIndex:i];
            if (NOT_NULL(dupe.sharerImage)) {
                dupeSharerImage.image = dupe.sharerImage;
            } else {
                dupeSharerImage.image = [UIImage imageNamed:@"PlaceholderFace"];
            }
            i++;
        }
    }

    if (IS_NULL(_video.sharerComment)) {
        _sharerComment.text = _video.title;
    } else {
        _sharerComment.text = _video.sharerComment;
    }
    
    if (_dupeCount != 0) {
        _sharerName.text = [NSString stringWithFormat:@"%@ + %d MORE", _video.sharer, _dupeCount];
    } else {
        _sharerName.text = _video.sharer;
    }
    
    _shareTime.text = [self prettyDateDiff:_video.createdAt];
}

@end

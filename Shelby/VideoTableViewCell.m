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
#import "ShelbyApp.h"
#import "VideoData.h"

@implementation VideoTableViewCell

@synthesize videoTableData;
@synthesize viewController;

#pragma mark - Init

- (void)initIPad
{
    _kCellWidth = IPAD_CELL_WIDTH;
    _kCellHeight = IPAD_CELL_HEIGHT;
    _kVideoWidth = IPAD_VIDEO_WIDTH;
    _kVideoHeight = IPAD_VIDEO_HEIGHT;
    _kBadgeWidth = IPAD_BADGE_WIDTH;
    _kBadgeHeight = IPAD_BADGE_HEIGHT;
    _kCommentViewOriginX = IPAD_COMMENT_VIEW_ORIGIN_X;
    _kCommentViewOriginY = IPAD_COMMENT_VIEW_ORIGIN_Y;
    _kCommentViewWidth = IPAD_COMMENT_VIEW_WIDTH;
    _kCommentViewHeight = IPAD_COMMENT_VIEW_HEIGHT;
    _kVideoFooterOriginX = IPAD_VIDEO_FOOTER_ORIGIN_X;
    _kVideoFooterOriginY = IPAD_VIDEO_FOOTER_ORIGIN_Y;
    _kVideoFooterWidth = IPAD_VIDEO_FOOTER_WIDTH;
    _kVideoFooterHeight = IPAD_VIDEO_FOOTER_HEIGHT;
    _kSharerOriginX = IPAD_SHARER_ORIGIN_X;
    _kSharerOriginY = IPAD_SHARER_ORIGIN_Y;
    _kSharerWidth = IPAD_SHARER_WIDTH;
    _kSharerHeight = IPAD_SHARER_HEIGHT;
    _kCommentOriginX = IPAD_COMMENT_ORIGIN_X;
    _kCommentOriginY = IPAD_COMMENT_ORIGIN_Y;
    _kCommentWidth = IPAD_COMMENT_WIDTH;
    _kCommentHeight = IPAD_COMMENT_HEIGHT;
    _kSharerNameOriginX = IPAD_SHARER_NAME_ORIGIN_X;
    _kSharerNameOriginY = IPAD_SHARER_NAME_ORIGIN_Y;
    _kSharerNameWidth = IPAD_SHARER_NAME_WIDTH;
    _kSharerNameHeight = IPAD_SHARER_NAME_HEIGHT;
    _kSharetimeOriginX = IPAD_SHARETIME_ORIGIN_X;
    _kSharetimeOriginY = IPAD_SHARETIME_ORIGIN_Y;
    _kSharetimeWidth = IPAD_SHARETIME_WIDTH;
    _kSharetimeHeight = IPAD_SHARETIME_HEIGHT;
    _kCellHorizontalMargin = IPAD_CELL_HORIZ_MARGIN;
    _kCellVerticalMargin = IPAD_CELL_VERT_MARGIN;
}

- (void)initIPhone
{
    _kCellWidth = IPHONE_CELL_WIDTH;
    _kCellHeight = IPHONE_CELL_HEIGHT;
    _kVideoWidth = IPHONE_VIDEO_WIDTH;
    _kVideoHeight = IPHONE_VIDEO_HEIGHT;
    _kBadgeWidth = IPHONE_BADGE_WIDTH;
    _kBadgeHeight = IPHONE_BADGE_HEIGHT;
    _kCommentViewOriginX = IPHONE_COMMENT_VIEW_ORIGIN_X;
    _kCommentViewOriginY = IPHONE_COMMENT_VIEW_ORIGIN_Y;
    _kCommentViewWidth = IPHONE_COMMENT_VIEW_WIDTH;
    _kCommentViewHeight = IPHONE_COMMENT_VIEW_HEIGHT;
    _kVideoFooterOriginX = IPHONE_VIDEO_FOOTER_ORIGIN_X;
    _kVideoFooterOriginY = IPHONE_VIDEO_FOOTER_ORIGIN_Y;
    _kVideoFooterWidth = IPHONE_VIDEO_FOOTER_WIDTH;
    _kVideoFooterHeight = IPHONE_VIDEO_FOOTER_HEIGHT;
    _kSharerOriginX = IPHONE_SHARER_ORIGIN_X;
    _kSharerOriginY = IPHONE_SHARER_ORIGIN_Y;
    _kSharerWidth = IPHONE_SHARER_WIDTH;
    _kSharerHeight = IPHONE_SHARER_HEIGHT;
    _kCommentOriginX = IPHONE_COMMENT_ORIGIN_X;
    _kCommentOriginY = IPHONE_COMMENT_ORIGIN_Y;
    _kCommentWidth = IPHONE_COMMENT_WIDTH;
    _kCommentHeight = IPHONE_COMMENT_HEIGHT;
    _kSharerNameOriginX = IPHONE_SHARER_NAME_ORIGIN_X;
    _kSharerNameOriginY = IPHONE_SHARER_NAME_ORIGIN_Y;
    _kSharerNameWidth = IPHONE_SHARER_NAME_WIDTH;
    _kSharerNameHeight = IPHONE_SHARER_NAME_HEIGHT;
    _kSharetimeOriginX = IPHONE_SHARETIME_ORIGIN_X;
    _kSharetimeOriginY = IPHONE_SHARETIME_ORIGIN_Y;
    _kSharetimeWidth = IPHONE_SHARETIME_WIDTH;
    _kSharetimeHeight = IPHONE_SHARETIME_HEIGHT;
    _kCellHorizontalMargin = IPHONE_CELL_HORIZ_MARGIN;
    _kCellVerticalMargin = IPHONE_CELL_VERT_MARGIN;
}

- (void)initCommon
{
    self.frame = CGRectMake(0, 0, _kCellWidth, _kCellHeight);
    _videoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _kVideoWidth, _kVideoHeight)];
    _badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _kBadgeWidth, _kBadgeHeight)];
    _commentView = [[UIView alloc] initWithFrame:CGRectMake(_kCommentViewOriginX, _kCommentViewOriginY, _kCommentViewWidth, _kCommentViewHeight)];
    _commentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    _videoFooterView = [[UIView alloc] initWithFrame:CGRectMake(_kVideoFooterOriginX, _kVideoFooterOriginY, _kVideoFooterWidth, _kVideoFooterHeight)];
    _sharerView = [[UIImageView alloc] initWithFrame:CGRectMake(_kSharerOriginX, _kSharerOriginY, _kSharerWidth, _kSharerHeight)];
    _sharerComment = [[UILabel alloc] initWithFrame:CGRectMake(_kCommentOriginX, _kCommentOriginY, _kCommentWidth, _kCommentHeight)];
    _sharerComment.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
    _sharerComment.numberOfLines = 1;
    _sharerName = [[UILabel alloc] initWithFrame:CGRectMake(_kSharerNameOriginX, _kSharerNameOriginY, _kSharerNameWidth, _kSharerNameHeight)];
    _shareTime = [[UILabel alloc] initWithFrame:CGRectMake(_kSharetimeOriginX, _kSharetimeOriginY, _kSharetimeWidth, _kSharetimeHeight)];
    _clipView = [[UIView alloc] initWithFrame:CGRectMake(_kCellHorizontalMargin, _kCellVerticalMargin, _kVideoWidth, _kVideoHeight + _kVideoFooterHeight)];
    
    _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _expandButton.frame = CGRectMake(0, _kCommentViewOriginY, _kVideoWidth, _kCommentViewHeight + _kVideoFooterHeight);
    [_expandButton addTarget:self action:@selector(sharerNamePressed) forControlEvents:UIControlEventTouchUpInside];
    _expandButton.backgroundColor = [UIColor clearColor];
    
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
    _expandButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _videoView.contentMode = UIViewContentModeScaleAspectFill;
    _videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _videoView.clipsToBounds = TRUE;
    
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
    
    [_clipView addSubview:_expandButton];
    
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
    CGFloat maxTextWidth = _videoView.bounds.size.width - _kSharerNameOriginX - 7; // 7 is right margin?
    return [comment sizeWithFont:[UIFont fontWithName:@"Thonburi-Bold" size:16.0]
               constrainedToSize:CGSizeMake(maxTextWidth, 80)
                   lineBreakMode:UILineBreakModeTailTruncation];
}

- (void)sizeFramesForComments
{
    // overall frame
    CGRect tempFrame = self.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments : _kCellHeight;
    self.frame = tempFrame;

    // bg frame - necessary to make sure button touchable area isn't clipped
    _bgView.frame = self.bounds;
    
    // clip view frame
    tempFrame = _clipView.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments - 2 * _kCellVerticalMargin : _kVideoHeight + _kVideoFooterHeight;
    _clipView.frame = tempFrame;
    
    tempFrame = _videoFooterView.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments - 2 * _kCellVerticalMargin - _kVideoHeight : _kVideoFooterHeight;
    _videoFooterView.frame = tempFrame;
    
    tempFrame = _expandButton.frame;
    tempFrame.size.height = _video.allComments ? _video.cellHeightAllComments: _kCommentViewHeight + _kVideoFooterHeight;
    tempFrame.origin.y = _video.allComments ? _kVideoFooterOriginY : _kCommentViewOriginY;
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

- (void)setVideo:(Video *)video andSizeFrames:(BOOL)sizeFrames
{
    // use this to clean up old videos also from cell caching
    if (NOT_NULL(_video)) {
        [_video release];
    }
    _video = [video retain];

    [self clearDupeData];

    NSArray *dupes = [[ShelbyApp sharedApp].videoData videoDupesForVideo:_video];
    _dupeCount = [dupes count] - 1;
    
    [_expandButton setEnabled:YES];
    BOOL first = TRUE;
    
    float additionalHeight = 0.0;
    
    // go through all duplicate videos and add in comment stuff...
    for (Video *dupe in dupes) {
        if (!first) {
            UIImageView *dupeSharerImage = [[UIImageView alloc] initWithFrame:CGRectMake(_kSharerOriginX, _kSharerOriginY + _kVideoFooterHeight + additionalHeight, _kSharerWidth, _kSharerHeight)];
            // actual sharer image gets set in drawRect, so that a setNeedsDisplay will pick up newly downloaded sharer images
            
            UILabel *dupeSharerName = [[UILabel alloc] initWithFrame:CGRectMake(_kSharerNameOriginX, _kSharerOriginY + _kVideoFooterHeight + additionalHeight + 2, _kSharerNameWidth, _kSharerNameHeight)];
            
            dupeSharerName.textAlignment = UITextAlignmentLeft;
            dupeSharerName.font = [UIFont fontWithName:@"Thonburi-Bold" size:16.0];
            dupeSharerName.textColor = [UIColor whiteColor];
            dupeSharerName.backgroundColor = [UIColor clearColor];
            dupeSharerName.adjustsFontSizeToFitWidth = YES;
            dupeSharerName.minimumFontSize = 10.0;
            dupeSharerName.numberOfLines = 1;
            dupeSharerName.text = dupe.sharer;
            
            UILabel *dupeShareTime = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - (_kCellWidth - _kSharetimeOriginX), _kSharetimeOriginY + _kVideoFooterHeight + additionalHeight, _kSharetimeWidth, _kSharetimeHeight)];
            
            dupeShareTime.font = [UIFont fontWithName:@"Thonburi-Bold" size:14.0];
            dupeShareTime.textColor = [UIColor lightGrayColor];
            dupeShareTime.backgroundColor = [UIColor clearColor];
            dupeShareTime.textAlignment = UITextAlignmentRight;
            dupeShareTime.adjustsFontSizeToFitWidth = YES;
            dupeShareTime.minimumFontSize = 10.0;
            dupeShareTime.numberOfLines = 1;
            dupeShareTime.text = [self prettyDateDiff:dupe.createdAt];
            
            additionalHeight += _kSharerHeight + 8;
            
            [_dupeShareTimes addObject:dupeShareTime];
            [_clipView insertSubview:dupeShareTime belowSubview:_expandButton];
            
            [_dupeSharerNames addObject:dupeSharerName];
            [_clipView insertSubview:dupeSharerName belowSubview:_expandButton];
            
            [_dupeSharerImages addObject:dupeSharerImage];
            [_clipView insertSubview:dupeSharerImage belowSubview:_expandButton];
        }

        CGSize textSize;
        if (NOT_NULL(dupe.sharerComment)) {
            textSize = [self getCommentTextSize:dupe.sharerComment];
        } else {
            textSize = [self getCommentTextSize:dupe.title];
        }
        
        UILabel *dupeComment = [[UILabel alloc] initWithFrame:CGRectMake(_kSharerNameOriginX, _kVideoFooterHeight + _kVideoHeight + additionalHeight, textSize.width, textSize.height)];
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
        [_clipView insertSubview:dupeComment belowSubview:_expandButton];
        
        additionalHeight += textSize.height;
        additionalHeight += IPAD_EXPANDED_COMMENT_MARGIN;
        
        first = FALSE;
    }
    
    _video.cellHeightAllComments = _kCellHeight + additionalHeight;
    
    if (sizeFrames) {
        [self sizeFramesForComments];
    }
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
    _video.allComments = !_video.allComments;
    
    // the Video* cache of height information that we can use in the table view controller
    _video.cellHeightCurrent = _video.allComments ? _video.cellHeightAllComments : _kCellHeight;    
    
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && _video.currentlyPlaying) {
        _bgView.image = [UIImage imageNamed:@"CellGradientPlaying.png"];
    } else {
        _bgView.image = [UIImage imageNamed:@"CellGradient.png"];
    }
    
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
    } else if ([_video.source isEqualToString:@"bookmarklet"] ||
               [_video.source isEqualToString:@"direct_link"]) {
        // clear image, so no watched/unwatched. easier than hiding/unhiding in this case.
        _badgeView.image = [UIImage imageNamed:@"Bookmarklet"];
    }
    
    if (NOT_NULL(_video.sharerImage)) {
        _sharerView.image = _video.sharerImage;
    } else {
        _sharerView.image = [UIImage imageNamed:@"PlaceholderFace"];
    }
    
    BOOL first = TRUE;
    NSUInteger i = 0;
    NSArray *dupes = [[ShelbyApp sharedApp].videoData videoDupesForVideo:_video];
    for (Video *dupe in dupes) {
        if (first) {
            first = FALSE;
            continue;
        }
        // XXX if this races with setVideo, _dupeSharerImages might not be full initialized. need to really fix this, not this hack...
        UIImageView *dupeSharerImage = ([_dupeSharerImages count] > i) ? [_dupeSharerImages objectAtIndex:i] : nil;
        if (NOT_NULL(dupe.sharerImage)) {
            dupeSharerImage.image = dupe.sharerImage;
        } else {
            dupeSharerImage.image = [UIImage imageNamed:@"PlaceholderFace"];
        }
        i++;
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setVideo:_video andSizeFrames:NO];
    
    // the Video* cache of height information that we can use in the table view controller
    _video.cellHeightCurrent = _video.allComments ? _video.cellHeightAllComments : _kCellHeight;    
    
    // 0.275 seems to match the OS default fairly well for table cell height adjustment animation
    [UIView animateWithDuration:0.275 animations:^{
        [self sizeFramesForComments];
    }];
    
    // forces an update of all the table cell heights
    [self setNeedsDisplay];
    [viewController.tableView beginUpdates];
    [viewController.tableView endUpdates];
}

@end

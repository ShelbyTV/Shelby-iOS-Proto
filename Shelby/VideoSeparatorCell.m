//
//  VideoSeparatorCell.m
//  Shelby
//
//  Created by Mark Johnson on 2/28/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoSeparatorCell.h"

@implementation VideoSeparatorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:self.frame];
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ForegroundStripes"]];
        [self addSubview:_bgView];
        
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 2)];
        _topBar.backgroundColor = [UIColor whiteColor];
        [_bgView addSubview:_topBar];
        
        _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 2, self.frame.size.width, 2)];
        _bottomBar.backgroundColor = [UIColor whiteColor];
        [_bgView addSubview:_bottomBar];
        
        _lastSyncTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, self.frame.size.height - 20)];
        _lastSyncTimeLabel.textColor = [UIColor whiteColor];
        _lastSyncTimeLabel.shadowColor = [UIColor blackColor];
        _lastSyncTimeLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        _lastSyncTimeLabel.backgroundColor = [UIColor clearColor];
        _lastSyncTimeLabel.numberOfLines = 1;
        _lastSyncTimeLabel.textAlignment = UITextAlignmentCenter;
        _lastSyncTimeLabel.font = [UIFont fontWithName: @"Thonburi-Bold" size: 19.0];
        _lastSyncTimeLabel.adjustsFontSizeToFitWidth = YES;
        _lastSyncTimeLabel.minimumFontSize = 14.0;
        _lastSyncTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _lastSyncTimeLabel.text = @"... since today @ 9:15am";
        
        [_bgView addSubview:_lastSyncTimeLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
}

@end

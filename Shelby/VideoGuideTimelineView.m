//
//  VideoGuideTimelineView.m
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoGuideTimelineView.h"
#import "VideoTableTimelineData.h"
#import "VideoTableViewController.h"

@implementation VideoGuideTimelineView

- (id)initWithFrame:(CGRect)frame withDelegate:(id<VideoTableViewControllerDelegate>)delegate;
{
    self = [super initWithFrame:frame withDelegate:delegate];
    if (self) {

        _videoTableViewController = [[VideoTableViewController alloc] init];
        _videoTableViewController.delegate = delegate;
        _videoTableData = _videoTableTimelineData = [[VideoTableTimelineData alloc] initWithUITableView:_videoTableViewController.tableView];
        _videoTableViewController.videoTableData = _videoTableData;
        _videoTableData.delegate = _videoTableViewController;
        
        _videoTableViewController.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_videoTableViewController.tableView setBackgroundColor:[UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.0]];
        [_videoTableViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        CGFloat width = self.bounds.size.width;
        
        _updatesContainer = [[UIView alloc] initWithFrame:CGRectMake(0, -50, width, 50)];
        _updatesContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _updatesContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundStripes"]];
        _updatesContainer.opaque = YES;
        
        _updatesLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 12, width - 63, 20)];
        _updatesLabel.textColor = [UIColor whiteColor];
        _updatesLabel.shadowColor = [UIColor blackColor];
        _updatesLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        _updatesLabel.backgroundColor = [UIColor clearColor];
        _updatesLabel.numberOfLines = 1;
        _updatesLabel.textAlignment = UITextAlignmentCenter;
        _updatesLabel.font = [UIFont fontWithName: @"Thonburi-Bold" size: 19.0];
        _updatesLabel.adjustsFontSizeToFitWidth = YES;
        _updatesLabel.minimumFontSize = 14.0;
        _updatesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _updatesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 6, 36, 36)];
        _updatesImageView.image = [UIImage imageNamed:@"refreshExclamation"];
        _updatesImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        _colorSeparator = [[UIView alloc]initWithFrame:CGRectMake(0, 48, width, 2)];
        _colorSeparator.backgroundColor = [UIColor whiteColor];
        _colorSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [_updatesContainer addSubview:_colorSeparator];
        [_updatesContainer addSubview:_updatesImageView];
        [_updatesContainer addSubview:_updatesLabel];
        _updatesContainer.hidden = FALSE;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedNewDataFromAPI:)
                                                     name: @"NewDataAvailableFromAPI"
                                                   object: nil];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _videoTableViewController.tableView.frame = self.bounds;
        [self addSubview:_videoTableViewController.tableView];
        [self addSubview:_updatesContainer];
    }
    
    return self;
}

- (NSString *)commentPluralized:(int)numComments
{
    return (numComments > 1) ? @"comments" : @"comment";
}

- (NSString *)videoPluralized:(int)numVideos
{
    return (numVideos > 1) ? @"videos" : @"video";
}

- (void)hideUpdates
{
    if (!_updatesVisible) {
        return;
    }
    
    _updatesVisible = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect temp = _updatesContainer.frame;
        temp.origin.y = -1 * temp.size.height;
        _updatesContainer.frame = temp;
        
        temp = _videoTableViewController.view.frame;
        temp.origin.y = 0;
        temp.size.height = _originalFrame.size.height;
        _videoTableViewController.view.frame = temp;
    }];
}

- (void)showUpdates
{
    if (_updatesVisible) {
        return;
    }
    
    _updatesVisible = YES;
 
    [UIView animateWithDuration:0.25 animations:^{
        CGRect temp = _updatesContainer.frame;
        temp.origin.y = 0;
        _updatesContainer.frame = temp;
        
        temp = _videoTableViewController.view.frame;
        temp.origin.y = _updatesContainer.frame.size.height;
        temp.size.height = _originalFrame.size.height - _updatesContainer.frame.size.height;
        _videoTableViewController.view.frame = temp;
    }];
}

- (void)receivedNewDataFromAPI:(NSNotification *)notification
{
    int newVideos = [[notification.userInfo objectForKey:@"newVideos"] intValue];
    int newCommentsOnExistingVideos = [[notification.userInfo objectForKey:@"newCommentsOnExistingVideos"] intValue];
    
    if (newVideos <= 0 && newCommentsOnExistingVideos <= 0) {
        _updatesLabel.text = @"";
        [self hideUpdates];
        return;
    }
    
    if (newVideos > 0 && newCommentsOnExistingVideos > 0) {
        _updatesLabel.text = [NSString stringWithFormat:@"%d new %@ & %d new %@",
                              newVideos,
                              [self videoPluralized:newVideos],
                              newCommentsOnExistingVideos,
                              [self commentPluralized:newCommentsOnExistingVideos]];
    } else if (newVideos > 0) {
        _updatesLabel.text = [NSString stringWithFormat:@"%d new %@",
                              newVideos,
                              [self videoPluralized:newVideos]];
    } else if (newCommentsOnExistingVideos > 0) {
        _updatesLabel.text = [NSString stringWithFormat:@"%d new %@",
                              newCommentsOnExistingVideos,
                              [self commentPluralized:newCommentsOnExistingVideos]];
    }
    
    NSLog(@"%@", _updatesLabel.text);
    
    [self showUpdates];
}


@end

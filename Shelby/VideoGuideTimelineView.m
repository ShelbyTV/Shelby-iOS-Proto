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

- (id)initWithVideoTableViewControllerDelegate:(id<VideoTableViewControllerDelegate>)delegate
{
    self = [super initWithVideoTableViewControllerDelegate:delegate];
    if (self) {

        _videoTableViewController = [[VideoTableViewController alloc] init];
        _videoTableViewController.delegate = delegate;
        _videoTableData = _videoTableTimelineData = [[VideoTableTimelineData alloc] initWithUITableView:_videoTableViewController.tableView];
        _videoTableViewController.videoTableData = _videoTableData;
        _videoTableData.delegate = _videoTableViewController;
        
        [_videoTableViewController.tableView setBackgroundColor:[UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.0]];
        [_videoTableViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        CGFloat width;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            width = 330;
        } else {
            width = 320;
        }
        
        _updatesContainer = [[UIView alloc] initWithFrame:CGRectMake(0, -80, width, 80)];
        _updatesContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _updatesContainer.backgroundColor = [UIColor colorWithRed:0.48 green:0.19 blue:0.57 alpha:1.0];
        _updatesContainer.opaque = YES;
        
        _updatesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, width - 40, 40)];
        _updatesLabel.textColor = [UIColor whiteColor];
        _updatesLabel.shadowColor = [UIColor blackColor];
        _updatesLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        _updatesLabel.backgroundColor = [UIColor clearColor];
        _updatesLabel.numberOfLines = 2;
        _updatesLabel.font = [UIFont fontWithName: @"Thonburi-Bold" size: 18.0];
        _updatesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [_updatesContainer addSubview:_updatesLabel];
        _updatesContainer.hidden = FALSE;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedNewDataFromAPI:)
                                                     name: @"NewDataAvailableFromAPI"
                                                   object: nil];
    }
    
    return self;
}

- (void)initSubviews
{
    _videoTableViewController.tableView.frame = self.bounds;
    [self addSubview:_videoTableViewController.tableView];
    [self addSubview:_updatesContainer];
}

- (NSString *)commentPluralized:(int)numComments
{
    return (numComments > 1) ? @"comments" : @"comment";
}

- (NSString *)videoPluralized:(int)numVideos
{
    return (numVideos > 1) ? @"videos" : @"video";
}

- (NSString *)isOrAre:(int)num
{
    return (num > 1) ? @"are" : @"is";
}

- (void)hideUpdates
{
    if (!_updatesVisible) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect temp = _updatesContainer.frame;
        temp.origin.y -= temp.size.height;
        _updatesContainer.frame = temp;
        
        temp = _videoTableViewController.view.frame;
        temp.origin.y -= _updatesContainer.frame.size.height;
        temp.size.height += _updatesContainer.frame.size.height;
        _videoTableViewController.view.frame = temp;
    }
                     completion:^(BOOL finished){
                         _updatesVisible = NO;
                     }];
}

- (void)showUpdates
{
    if (_updatesVisible) {
        return;
    }
 
    [UIView animateWithDuration:0.25 animations:^{
        CGRect temp = _updatesContainer.frame;
        temp.origin.y += temp.size.height;
        _updatesContainer.frame = temp;
        
        temp = _videoTableViewController.view.frame;
        temp.origin.y += _updatesContainer.frame.size.height;
        temp.size.height -= _updatesContainer.frame.size.height;
        _videoTableViewController.view.frame = temp;
    }
                     completion:^(BOOL finished){
                         _updatesVisible = YES;
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
        _updatesLabel.text = [NSString stringWithFormat:@"%d new %@ and %d new %@ are waiting for you. Pull to refresh.",
                              newVideos,
                              [self videoPluralized:newVideos],
                              newCommentsOnExistingVideos,
                              [self commentPluralized:newCommentsOnExistingVideos]];
    } else if (newVideos > 0) {
        _updatesLabel.text = [NSString stringWithFormat:@"%d new %@ %@ waiting for you. Pull to refresh.",
                              newVideos,
                              [self videoPluralized:newVideos],
                              [self isOrAre:newVideos]];
    } else if (newCommentsOnExistingVideos > 0) {
        _updatesLabel.text = [NSString stringWithFormat:@"%d new %@ %@ waiting for you. Pull to refresh.",
                              newCommentsOnExistingVideos,
                              [self commentPluralized:newCommentsOnExistingVideos],
                              [self isOrAre:newCommentsOnExistingVideos]];
    }
    
    NSLog(@"%@", _updatesLabel.text);
    
    [self showUpdates];
}


@end

//
//  VideoTableViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "VideoTableData.h"

@class VideoTableData;
@class Video;
@class VideoTableViewController;

@protocol VideoTableViewControllerDelegate

- (void)videoTableViewControllerFinishedRefresh:(VideoTableViewController *)controller;

@end

@interface VideoTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, VideoTableDataDelegate>
{
    VideoTableData *videoTableData;
    id callbackObject;
    SEL callbackSelector;
    UITableViewCell *videoCell;
    NSInteger _currentVideoIndex;

    EGORefreshTableHeaderView *_refreshHeaderView;
    UIView *_networkActivityView;
}

@property (nonatomic, assign) id <VideoTableViewControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet UITableViewCell *videoCell;

- (id)initWithStyle:(UITableViewStyle)style
     callbackObject:(id)object
   callbackSelector:(SEL)selector;

- (void)clearVideos;
- (void)loadVideos;
- (Video *)getCurrentVideo;
- (Video *)getNextVideo;
- (Video *)getPreviousVideo;

@end

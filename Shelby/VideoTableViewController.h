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

- (void)videoTableWasTouched;
- (void)playVideo:(Video *)video;

@end

@interface VideoTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, VideoTableDataDelegate>
{
    id callbackObject;
    SEL callbackSelector;
    NSInteger _currentVideoIndex;

    EGORefreshTableHeaderView *_refreshHeaderView;
}

@property (nonatomic, assign) id <VideoTableViewControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet UITableViewCell *videoCell;
@property (nonatomic, assign) VideoTableData *videoTableData;

- (void)reset;
- (Video *)getFirstVideo;
- (Video *)getNextVideo;
- (Video *)getPreviousVideo;

- (void)enableDemoMode;

@end

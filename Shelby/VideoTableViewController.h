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
    NSInteger _currentVideoIndex;
    NSInteger videoMode;
    
    IBOutlet UITableViewCell *timelineOnboardCell;
    IBOutlet UITableViewCell *favoritesOnboardCell;
    IBOutlet UITableViewCell *watchLaterOnboardCell;

    EGORefreshTableHeaderView *_refreshHeaderView;
}

@property (nonatomic, assign) id <VideoTableViewControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet UITableViewCell *videoCell;

- (id)initWithStyle:(UITableViewStyle)style
     callbackObject:(id)object
   callbackSelector:(SEL)selector;

- (void)changeVideoMode:(NSInteger)mode;
- (void)clearVideoTableData;
- (Video *)getFirstVideo;
- (Video *)getNextVideo;
- (Video *)getPreviousVideo;
- (void)loadVideos;

@end

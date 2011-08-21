//
//  VideoTableViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class VideoTableData;
@class Video;

@interface VideoTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    VideoTableData *videoTableData;
    id callbackObject;
    SEL callbackSelector;
    UITableViewCell *videoCell;
    NSInteger _currentVideoIndex;

    EGORefreshTableHeaderView *_refreshHeaderView;

    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes
    BOOL _reloading;
}

@property (nonatomic, assign) IBOutlet UITableViewCell *videoCell;

- (id)initWithStyle:(UITableViewStyle)style
     callbackObject:(id)object
   callbackSelector:(SEL)selector;

- (void)loadVideos;
- (Video *)getNextVideo;
- (Video *)getPreviousVideo;

@end

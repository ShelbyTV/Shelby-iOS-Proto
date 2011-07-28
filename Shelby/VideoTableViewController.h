//
//  VideoTableViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoTableData;

@interface VideoTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    VideoTableData *videoTableData;
}



@end

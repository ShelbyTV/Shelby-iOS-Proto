//
//  STVEmailController.h
//  Shelby
//
//  Created by David Kay on 10/12/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchContactController.h"

@class Video;

@interface STVEmailController : NSObject <TTMessageControllerDelegate, SearchContactControllerDelegate> {
  NSTimer* _sendTimer;
  //UIViewController *_parentViewController;
}
  
@property (nonatomic, retain) UIViewController *searchViewController;
@property (nonatomic, retain) UIViewController *parentViewController;
@property (nonatomic, retain) Video *video;


- (id)initWithParentViewController:(UIViewController *)parent;

@end

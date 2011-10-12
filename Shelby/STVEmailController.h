//
//  STVEmailController.h
//  Shelby
//
//  Created by David Kay on 10/12/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchTestController.h"


@interface STVEmailController : NSObject <TTMessageControllerDelegate, SearchTestControllerDelegate> {
  NSTimer* _sendTimer;
  //UIViewController *_parentViewController;
}
  
@property (nonatomic, retain) UIViewController *parentViewController;

@end

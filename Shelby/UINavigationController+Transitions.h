//
//  UINavigationController+Transitions.h
//  Shelby
//
//  Created by Mark Johnson on 1/19/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Transitions)

- (void)pushFadeViewController:(UIViewController *)viewController;
- (void)fadePopViewController;

- (void)pushZoomViewController:(UIViewController *)viewController;
- (void)unZoomPopViewController;

@end

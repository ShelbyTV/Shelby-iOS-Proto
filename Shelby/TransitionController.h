//
//  TransitionController.h
//  Shelby
//
//  Created by Mark Johnson on 1/19/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitionController : UIViewController

@property (nonatomic, strong)   UIView *                containerView;
@property (nonatomic, strong)   UIViewController *      viewController;

- (id)initWithViewController:(UIViewController *)viewController;
- (void)transitionToViewController:(UIViewController *)viewController
                       withOptions:(UIViewAnimationOptions)options;

@end

//
//  TransitionController.h
//  Shelby
//
//  Created by Mark Johnson on 1/19/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitionController : UIViewController

@property (nonatomic, strong)   UIViewController *      viewController;

- (id)initWithViewController:(UIViewController *)viewController;

- (void)transitionZoomInToViewController:(UIViewController *)viewController
                withEndOfCompletionBlock:(void (^)(void))block;
- (void)transitionZoomOutToViewController:(UIViewController *)viewController
                 withEndOfCompletionBlock:(void (^)(void))block;
- (void)transitionImmediatelyToViewController:(UIViewController *)viewController
                     withEndOfCompletionBlock:(void (^)(void))block;

@end

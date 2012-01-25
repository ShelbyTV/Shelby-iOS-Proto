//
//  TransitionController.m
//  Shelby
//
//  Created by Mark Johnson on 1/19/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "TransitionController.h"
#import "ShelbyApp.h"
#import <QuartzCore/QuartzCore.h>

@implementation TransitionController

@synthesize viewController = _viewController;

- (id)initWithViewController:(UIViewController *)viewController
{
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)loadView
{
    self.wantsFullScreenLayout = YES;
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = view;
    self.view.autoresizesSubviews = TRUE;
    
    [self.view addSubview:self.viewController.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)transitionZoomInToViewController:(UIViewController *)viewController
                withEndOfCompletionBlock:(void (^)(void))block
{
    if (_viewController == viewController) {
        return;
    }
    
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
        
    [viewController.view.layer setAffineTransform:CGAffineTransformMakeScale(0.01, 0.01)];
    [self.view addSubview:viewController.view];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [viewController.view.layer setAffineTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                     }
                     completion:^(BOOL finished){
                         [_viewController.view removeFromSuperview]; 
                         _viewController = viewController;
                         dispatch_async( currentQueue, ^{
                             block();  
                         });
                     }
     ];
}

- (void)transitionZoomOutToViewController:(UIViewController *)viewController
                 withEndOfCompletionBlock:(void (^)(void))block
{
    if (_viewController == viewController) {
        return;
    }
    
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    
    [_viewController.view.layer setAffineTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [self.view insertSubview:viewController.view atIndex:0];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [_viewController.view.layer setAffineTransform:CGAffineTransformMakeScale(0.01, 0.01)];
                     }
                     completion:^(BOOL finished){
                         [_viewController.view removeFromSuperview];
                         [_viewController.view.layer setAffineTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                         _viewController = viewController;
                         dispatch_async( currentQueue, ^{
                             block();  
                         });
                     }
     ];
}

- (void)transitionImmediatelyToViewController:(UIViewController *)viewController
                     withEndOfCompletionBlock:(void (^)(void))block
{
    if (_viewController == viewController) {
        return;
    }
    
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    
    [self.view addSubview:viewController.view];
    [_viewController.view removeFromSuperview];
    _viewController = viewController;
    
    dispatch_async( currentQueue, ^{
        block();  
    });
}

@end


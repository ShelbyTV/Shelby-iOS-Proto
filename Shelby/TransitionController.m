//
//  TransitionController.m
//  Shelby
//
//  Created by Mark Johnson on 1/19/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "TransitionController.h"
#import "ShelbyApp.h"

@implementation TransitionController

@synthesize containerView = _containerView,
viewController = _viewController;

- (id)initWithViewController:(UIViewController *)viewController
{
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)loadView
{
//    self.wantsFullScreenLayout = YES;
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.view = view;
    self.view.autoresizesSubviews = TRUE;
    
    _containerView = [[UIView alloc] initWithFrame:view.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _containerView.autoresizesSubviews = TRUE;
    [self.view addSubview:_containerView];
    
    [_containerView addSubview:self.viewController.view];
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

- (void)transitionToViewController:(UIViewController *)viewController
                       withOptions:(UIViewAnimationOptions)transition
{
    [UIView transitionFromView:[ShelbyApp sharedApp].shelbyWindow.rootViewController.view
                        toView:viewController.view
                      duration:0.65f
                       options:transition
                    completion:^(BOOL finished){
                        [ShelbyApp sharedApp].shelbyWindow.rootViewController = viewController;
                    }];
    
    _viewController = viewController;
}

@end


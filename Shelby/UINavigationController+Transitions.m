//
//  UINavigationController+Transitions.m
//  Shelby
//
//  Created by Mark Johnson on 1/19/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "UINavigationController+Transitions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UINavigationController (Transitions)

- (void)pushFadeViewController:(UIViewController *)viewController
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
    
	[self pushViewController:viewController animated:NO];
}

- (void)fadePopViewController
{
	CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
	[self popViewControllerAnimated:NO];
}

- (void)pushZoomViewController:(UIViewController *)viewController
{
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = 0.3f;
    scale.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.01f],
                    [NSNumber numberWithFloat:1.f],
                    nil];
    
	[viewController.view.layer addAnimation:scale forKey:nil];
    
	[self pushViewController:viewController animated:NO];
}

- (void)unZoomPopViewController
{
    [CATransaction begin];
    
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = 0.3f;
    scale.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f],
                    [NSNumber numberWithFloat:0.01f],
                    nil];
    
	[self.view.layer addAnimation:scale forKey:nil];
	[self popViewControllerAnimated:NO];
    
    [CATransaction commit];
}

@end

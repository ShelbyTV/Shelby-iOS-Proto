//
//  NavigationViewController_iPad.m
//  Shelby
//
//  Created by Mark Johnson on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 * Eventually there will be device-specific logic in these NavigationViewController subclasses,
 * since both devices have very different navigation.
 */

#import "NavigationViewController_iPad.h"

@implementation NavigationViewController_iPad

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (CGRect)toggleFrame:(CGRect)frame right:(BOOL)right {
    const float OFFSET = 100.0f;

    CGRect newFrame = frame;
    float offset = right ? -OFFSET : OFFSET;
    newFrame.origin.x += offset;
    return newFrame;
}

- (IBAction)shelbyIconWasPressed:(id)sender {
    // Slide the tray in and out.

    [UIView animateWithDuration:0.25 animations:^{
        header.frame = [self toggleFrame: header.frame right: _trayClosed];
    }
    completion:^(BOOL finished){
        // NOP
    }];
    _trayClosed = !_trayClosed;
}

@end

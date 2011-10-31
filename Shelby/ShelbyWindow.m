//
//  ShelbyWindow.m
//  Shelby
//
//  Created by Mark Johnson on 10/29/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import "ShelbyWindow.h"

@implementation ShelbyWindow

- (void)setFrame:(CGRect)frame
{
    if (frame.origin.x == 0 && frame.origin.y == 0) {
        super.frame = frame;
    }
}

- (void)setHidden:(BOOL)hidden
{
    super.hidden = NO;
}

- (void)resignKeyWindow
{
    [self makeKeyAndVisible];
}

@end

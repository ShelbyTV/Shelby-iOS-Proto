//
//  VideoPlayerViewController.m
//  Shelby
//
//  Created by Mark Johnson on 1/19/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "VideoPlayer.h"

@implementation VideoPlayerViewController

- (id)init
{
    // initialise ourselves normally
    self = [super init];
    if (self) {
        self.view = [[VideoPlayer alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL) canBecomeFirstResponder 
{
    return YES;
}

@end

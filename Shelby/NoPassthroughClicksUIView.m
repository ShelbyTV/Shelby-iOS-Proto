//
//  NoPassthroughClicksUIView.m
//  Shelby
//
//  Created by Mark Johnson on 1/28/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "NoPassthroughClicksUIView.h"

@implementation NoPassthroughClicksUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

//
//  RemoteModeGradientView.m
//  Shelby
//
//  Created by Mark Johnson on 12/31/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import "RemoteModeGradientView.h"

@implementation RemoteModeGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClipToRect(context, rect);
    
    CGPoint startPoint = CGPointMake(self.bounds.size.width / 2.0, 0);
    CGPoint endPoint = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height);
    
    CGFloat locations[2];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
    UIColor *color = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    locations[0] = 0.0;
    color = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    locations[1] = 1.0;
    
    CGGradientRef gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
    CGColorSpaceRelease(space);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

    CGGradientRelease(gradient);
    
	[super drawRect:rect];
}


@end

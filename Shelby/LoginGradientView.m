//
//  LoginGradientView.m
//  Shelby
//
//  Created by Mark Johnson on 12/7/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import "LoginGradientView.h"

@implementation LoginGradientView

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
    
    CGPoint startCenter = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    CGFloat startRadius = 1.0;
    
    CGPoint endCenter = startCenter;
    CGFloat endRadius = MAX(self.bounds.size.width, self.bounds.size.height) / 2.0; // not going to be big enough
    
    CGFloat locations[2];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
    UIColor *color = [UIColor colorWithRed:0.234 green:0.234 blue:0.234 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    locations[0] = 0.0;
    color = [UIColor colorWithRed:0.099 green:0.099 blue:0.099 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    locations[1] = 1.0;
    
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
    CGColorSpaceRelease(space);

    CGContextDrawRadialGradient(context, gradient, startCenter, startRadius, endCenter, endRadius, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);

	[super drawRect:rect];
}

@end

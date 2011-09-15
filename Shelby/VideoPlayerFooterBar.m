//
//  VideoPlayerFooterBar.m
//  Shelby
//
//  Created by David Kay on 9/15/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "VideoPlayerFooterBar.h"

@implementation VideoPlayerFooterBar

@synthesize title;

static NSString *NIB_NAME = @"VideoPlayerFooterBar";

+ (VideoPlayerFooterBar *)footerBarFromNib {
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:NIB_NAME owner:self options:nil];

    return [objects objectAtIndex:0];
}

- (void)loadViewFromNib {
    // load everything in the XIB we created
    NSArray *objects = [[NSBundle mainBundle] 
        loadNibNamed:NIB_NAME owner:self options:nil];

    // actually, we know there's only one thing in it, which is the
    // view we want to appear within this one
    [self addSubview:[objects objectAtIndex:0]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self loadViewFromNib];
    }
    return self;
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

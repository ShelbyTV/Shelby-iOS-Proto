//
//  STVOfflineView.m
//  Shelby
//
//  Created by David Kay on 9/19/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "STVOfflineView.h"

@implementation STVOfflineView

static NSString *IPAD_NIB_NAME   = @"STVOfflineView_iPad";
static NSString *IPHONE_NIB_NAME = @"STVOfflineView_iPhone";

#pragma mark - Factory

+ (STVOfflineView *)viewFromNib {
    NSString *nibName;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibName = IPHONE_NIB_NAME;
    } else {
        nibName = IPAD_NIB_NAME;
    }
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];

    return [objects objectAtIndex:0];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

//
//  OfflineView.m
//  Shelby
//
//  Created by David Kay on 9/19/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "OfflineView.h"

@implementation OfflineView

static NSString *IPAD_NIB_NAME   = @"OfflineView_iPad";
static NSString *IPHONE_NIB_NAME = @"OfflineView_iPhone";

#pragma mark - Factory

+ (OfflineView *)viewFromNib {
    NSString *nibName;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibName = IPHONE_NIB_NAME;
    } else {
        nibName = IPAD_NIB_NAME;
    }
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];

    return [objects objectAtIndex:0];
}

@end

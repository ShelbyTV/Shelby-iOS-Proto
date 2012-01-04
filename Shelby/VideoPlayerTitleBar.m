//
//  VideoPlayerTitleBar.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/5/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "VideoPlayerTitleBar.h"


@implementation VideoPlayerTitleBar

@synthesize title;
@synthesize comment;
@synthesize sharerPic;

@synthesize channelPic;

static NSString *IPHONE_NIB_NAME = @"VideoPlayerTitleBar_iPhone";
static NSString *IPAD_NIB_NAME = @"VideoPlayerTitleBar_iPad";
static NSString *TV_NIB_NAME = @"VideoPlayerTitleBar_TV";

+ (VideoPlayerTitleBar *)titleBarFromTVNib 
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:TV_NIB_NAME owner:self options:nil];
    
    return [objects objectAtIndex:0];
}

+ (VideoPlayerTitleBar *)titleBarFromNib 
{    
    NSString *nibName;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibName = IPHONE_NIB_NAME;
    } else {
        nibName = IPAD_NIB_NAME;
    }
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];

    return [objects objectAtIndex:0];
}

- (void)loadViewFromNib
{    
    NSString *nibName;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibName = IPHONE_NIB_NAME;
    } else {
        nibName = IPAD_NIB_NAME;
    }
    
    // load everything in the XIB we created
    NSArray *objects = [[NSBundle mainBundle] 
        loadNibNamed:nibName owner:self options:nil];

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

- (void)dealloc
{
    [super dealloc];
}

@end

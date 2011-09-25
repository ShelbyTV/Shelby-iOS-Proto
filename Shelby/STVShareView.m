//
//  STVShareView.m
//  Shelby
//
//  Created by David Kay on 9/25/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "STVShareView.h"


@implementation STVShareView

@synthesize delegate;

#pragma mark - Factory

static NSString *IPAD_NIB_NAME   = @"STVShareView";
static NSString *IPHONE_NIB_NAME = @"STVShareView";

+ (STVShareView *)viewFromNib {
    NSString *nibName;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibName = IPHONE_NIB_NAME;
    } else {
        nibName = IPAD_NIB_NAME;
    }
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];

    return [objects objectAtIndex:0];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - 

- (NSArray *)socialNetworks {
    NSMutableArray *array = [NSMutableArray array];
    BOOL twitter  = _twitterButton.selected;
    BOOL facebook = _facebookButton.selected;

    if (twitter) {
        [array addObject: @"twitter"];
    }
    if (facebook) {
        [array addObject: @"facebook"];
    }

    return [NSArray arrayWithArray: array];
}

#pragma mark - UI Callbacks

- (IBAction)twitterWasPressed:(id)sender {

    // Toggle the twitter Button
    UIButton *button = (UIButton *) sender;
    BOOL selected = button.selected;
    [button setSelected: !selected];
}

- (IBAction)facebookWasPressed:(id)sender {
    // Toggle the facebook Button
    UIButton *button = (UIButton *) sender;
    BOOL selected = button.selected;
    [button setSelected: !selected];
}

- (IBAction)sendWasPressed:(id)sender {

    // Check the state of the FB & Twitter buttons
    NSString *message = _textView.text;
    NSArray *networks = [self socialNetworks];

    // Notify our delegate
    if (self.delegate) {
        [self.delegate shareView:self sentMessage:message withNetworks:networks];
    }
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

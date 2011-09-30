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
@synthesize mainView;
@synthesize topBackground;
@synthesize emailView;
@synthesize socialView;
@synthesize activeView;

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

    STVShareView *view = [objects objectAtIndex:0];
    UIColor *backgroundPattern = [UIColor colorWithPatternImage: [UIImage imageNamed: @"SharePattern.png"]];
    //view.backgroundColor = backgroundPattern;
    //view.mainView.backgroundColor = backgroundPattern;
    view.socialView.backgroundColor = backgroundPattern;
    view.emailView.backgroundColor = backgroundPattern;
    view.topBackground.backgroundColor = backgroundPattern;
    [view makeSocialViewActive: YES];
    return view;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

#pragma mark Toggle Views

- (void)makeSocialViewActive:(BOOL)isSocialView {
    if (isSocialView) {
        self.activeView = self.socialView;
        self.socialView.hidden = NO;
        self.emailView.hidden  = YES;

        // set button state
        _socialButton.selected = YES;
        _emailButton.selected  = NO;
    } else {
        self.activeView = self.emailView;
        self.emailView.hidden  = NO;
        self.socialView.hidden = YES;
        
        // set button state
        _emailButton.selected  = YES;
        _socialButton.selected = NO;
    }
}

#pragma mark -

- (NSString *)recipients {
    // validate email?
    return _emailRecipientView.text;
}

- (NSArray *)socialNetworks {
    NSMutableArray *array = [NSMutableArray array];
    if (self.activeView == self.emailView) {
        [array addObject: @"email"];
    } else {
        BOOL twitter  = _twitterButton.selected;
        BOOL facebook = _facebookButton.selected;

        // Check the state of the FB & Twitter buttons
        if (twitter) {
            [array addObject: @"twitter"];
        }
        if (facebook) {
            [array addObject: @"facebook"];
        }
    }
    return [NSArray arrayWithArray: array];
}

#pragma mark - UI Callbacks

- (IBAction)closeWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate shareViewClosePressed : self];
    }
}

- (IBAction)emailWasPressed:(id)sender {
   if (sender == self.activeView) {
       return;
   } else {
       [self makeSocialViewActive: NO];
   }
}

- (IBAction)socialWasPressed:(id)sender {
   if (sender == self.activeView) {
       return;
   } else {
       [self makeSocialViewActive: YES];
   }
}

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

    NSString *message = (self.activeView == self.emailView)
        ? _emailTextView.text
        : _socialTextView.text;

    NSArray *networks = [self socialNetworks];

    NSString *recipients = (self.activeView == self.emailView)
        ? [self recipients]
        : nil;

    // Notify our delegate
    if (self.delegate) {
        [self.delegate shareView:self sentMessage:message withNetworks:networks andRecipients:recipients];
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

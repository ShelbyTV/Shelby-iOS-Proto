//
//  STVShareView.m
//  Shelby
//
//  Created by David Kay on 9/25/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "STVShareView.h"
#import "Video.h"
#import "User.h"

@interface STVShareView ()

- (void)makeSocialViewActive:(BOOL)isSocialView;

@end

@implementation STVShareView

@synthesize delegate;
@synthesize mainView;
@synthesize topBackground;
@synthesize emailView;
@synthesize socialView;
@synthesize activeView;
@synthesize video = _video;

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
    //UIColor *backgroundPattern = [UIColor colorWithPatternImage: [UIImage imageNamed: @"SharePattern.png"]];
    UIColor *backgroundPattern = [UIColor colorWithPatternImage: [UIImage imageNamed: @"SharePatternSquare.png"]];
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

#pragma mark - Setter/Getter

- (void)setVideo:(Video *)video {
    // Standard retain/release.
    [_video release];
    _video = [video retain];

    // Populate the UI.
    _socialTextView.text = [NSString stringWithFormat: @"Check out this great video I'm watching @onShelby: %@", video.shortPermalink];
    _emailTextView.text = [NSString stringWithFormat: @"Check out this great video I'm watching @onShelby: %@", video.shortPermalink];
}

- (void)updateAuthorizations:(User *)user {
    // Set twitter view visible
    _twitterButton.enabled  = [user.auth_twitter boolValue];
    _facebookButton.enabled = [user.auth_facebook boolValue];
}


#pragma mark - UITextViewDelegate

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//
//}
//
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
//
//}

//- (void)textViewDidBeginEditing:(UITextView *)textView;
//- (void)textViewDidEndEditing:(UITextView *)textView;

//- (void)textViewDidChange:(UITextView *)textView;
//
//- (void)textViewDidChangeSelection:(UITextView *)textView;

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText
{
    NSString* newText = [aTextView.text stringByReplacingCharactersInRange:aRange withString:aText];

    // TODO - find out why the size of the string is smaller than the actual width, so that you get extra, wrapped characters unless you take something off
    CGSize tallerSize = CGSizeMake(aTextView.frame.size.width-15,aTextView.frame.size.height*2); // pretend there's more vertical space to get that extra line to check on
    CGSize newSize = [newText sizeWithFont:aTextView.font constrainedToSize:tallerSize lineBreakMode:UILineBreakModeWordWrap];

    if (newSize.height > aTextView.frame.size.height) {
        {
            LOG(@"error. too big!");
            // TODO: Consider hitting send if they hit enter again at this point.

            //[myAppDelegate beep];
            return NO;
        }
    } else {
        return YES;
    }
}

#pragma mark - UITextFieldDelegate

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end

//- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
//- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
//- (BOOL)textFieldShouldClear:(UITextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)

- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    if (textField == _emailRecipientView) {
        [_emailTextView becomeFirstResponder];
        return NO;
    }
    return YES;
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

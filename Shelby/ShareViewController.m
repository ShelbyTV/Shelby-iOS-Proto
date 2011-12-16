//
//  ShareViewController.m
//  Shelby
//
//  Created by Mark Johnson on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "Video.h"
#import "User.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "COPeoplePickerViewController.h"


@implementation ShareViewController

@synthesize delegate;
@synthesize bodyTextView = _bodyTextView;

#pragma mark Toggle Views

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _perfectTweetRemarks = [[NSArray alloc] initWithObjects:@"the perfect tweet!", 
                                @"nailed it.", 
                                @"honeymoon fit.", 
                                @"...like a glove.", 
                                // @"I don't always tweet, but when I do, it's 140 characters.", // too long for iPhone
                                @"best. tweet. ever.", 
                                @"dead on balls accurate.", nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    [_video release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)populateUI
{
    // Populate the UI.
    NSString *defaultComment = @"";
    if (_video.shortPermalink && _video.sharer) {
        defaultComment = [NSString stringWithFormat: @"Great video via %@ %@", [_video.sharer lowercaseString], _video.shortPermalink];
    }

    _bodyTextView.text = defaultComment;
    _bodyTextView.selectedRange = NSMakeRange(0, [[NSString stringWithFormat: @"Great video via %@", [_video.sharer lowercaseString]] length]);
    [self textViewDidChange:_bodyTextView];
    
    [_peoplePicker clearTokenField];
    
    [self updateSendButton];
    
    [self.view setNeedsDisplay];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    if (NOT_NULL(_video)) {
        [self populateUI];
    }
    
    _peoplePicker = [[COPeoplePickerViewController alloc] initWithFrame:_emailRecipientFieldHolder.bounds];
    _peoplePicker.tableViewHolder = _emailRecipientSuggestionsHolder;
    _peoplePicker.delegate = self;
    [_emailRecipientFieldHolder addSubview:_peoplePicker.view];
    
    UIColor *backgroundPattern = [UIColor colorWithPatternImage: [UIImage imageNamed: @"ForegroundStripes"]];
    _dialogContainerView.backgroundColor = backgroundPattern;
    
    [self adjustViewsForOrientation:self.interfaceOrientation];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark -

- (NSString *)recipients
{
    // validate email?
    return [_peoplePicker concatenatedEmailAddresses];
}

- (NSArray *)socialNetworks
{
    NSMutableArray *array = [NSMutableArray array];
    if ([_shareTypeSelector selectedSegmentIndex] == 1) {
        [array addObject: @"email"];
    } else {
        BOOL twitter  = !_twitterButton.selected;
        BOOL facebook = !_facebookButton.selected;
        
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

- (void)resignFirstResponders
{
    [_peoplePicker resignFirstResponders];
    [_bodyTextView resignFirstResponder];
}

#pragma mark - UI Callbacks

- (IBAction)closeWasPressed:(id)sender
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    
    [self resignFirstResponders];
    if (self.delegate) {
        [self.delegate shareViewClosePressed : self];
    }
}

- (void)updateInterfaceType
{
    if ([_shareTypeSelector selectedSegmentIndex] == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            _emailRecipientContainerView.alpha = 0.0;
            _postButtonsContainerView.alpha = 1.0;
        }
        completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.25 animations:^{
                    _bodyTextContainerView.frame = _socialBodyPlaceholder.frame;
                }
                completion:^(BOOL finished){
                    // keeps state the same, but makes sure tweet display is animated properly
                    [self setTwitterEnabled:!_twitterButton.selected];
                }];
            }
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            _tweetRemainingLabel.alpha = 0.0;
            _postButtonsContainerView.alpha = 0.0;
        }
                         completion:^(BOOL finished){
                             if (finished) {
                                 [UIView animateWithDuration:0.25 animations:^{
                                     _bodyTextContainerView.frame = _emailBodyPlaceholder.frame;
                                 }
                                                  completion:^(BOOL finished){
                                                      [UIView animateWithDuration:0.25 animations:^{
                                                          _emailRecipientContainerView.alpha = 1.0;
                                                      }];
                                                  }];
                             }
                         }];
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    
    [self updateInterfaceType];
    [self updateSendButton];
}

- (void)updateSendButton
{
    if ([_shareTypeSelector selectedSegmentIndex] == 0 && 
        [[self socialNetworks] count] == 0) {
        _sendButton.enabled = NO;
    } else if ([_shareTypeSelector selectedSegmentIndex] == 1
                && [_peoplePicker tokenCount] == 0) {
        _sendButton.enabled = NO;
    } else if ([_shareTypeSelector selectedSegmentIndex] == 0 &&
        !_twitterButton.selected && _bodyTextView.text.length > 140) {
        _sendButton.enabled = NO;
    } else {
        _sendButton.enabled = YES;
    }
}

- (void)setTwitterEnabled:(BOOL)enabled
{
    _twitterButton.selected = !enabled;
    
    if ([_shareTypeSelector selectedSegmentIndex] != 0) {
        return;
    }
    
    if (enabled && _tweetRemainingLabel.alpha != 1.0) {
        [UIView animateWithDuration:0.25 animations:^{
            _tweetRemainingLabel.alpha = 1.0;
        }];
    } else if (!enabled && _tweetRemainingLabel.alpha != 0.0) {
        [UIView animateWithDuration:0.25 animations:^{
            _tweetRemainingLabel.alpha = 0.0;
        }];
    }

    [self updateSendButton];
}

- (IBAction)twitterWasPressed:(id)sender
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    
    [self setTwitterEnabled:_twitterButton.selected];
}

- (IBAction)facebookWasPressed:(id)sender
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    
    UIButton *button = (UIButton *) sender;
    [button setSelected:!button.selected];
    [self updateSendButton];
}

- (IBAction)sendWasPressed:(id)sender
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    
    // send should do nothing if in social mode and no social networks chosen
    if ([_shareTypeSelector selectedSegmentIndex] == 0 && 
        [[self socialNetworks] count] == 0) {
        return;
    }
    
    if ([_shareTypeSelector selectedSegmentIndex] == 1
         && [_peoplePicker tokenCount] == 0)
    {
        return;
    }
    
    NSString *message = _bodyTextView.text;
    NSArray *networks = [self socialNetworks];
    NSString *recipients = ([_shareTypeSelector selectedSegmentIndex] == 1) ? [self recipients] : nil;
    
    [self resignFirstResponders];

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
    
    [self populateUI];
}

- (Video *)getVideo
{
    return _video;
}

- (void)updateAuthorizations:(User *)user {
    // Set twitter view visible
    if ([user.auth_twitter boolValue]) {
        _twitterButton.enabled   = YES;
        [self setTwitterEnabled:YES];
    } else {
        _twitterButton.enabled  = NO;
    }
    
    if ([user.auth_facebook boolValue]) {
        _facebookButton.enabled   = YES;
        _facebookButton.selected  = NO;
    } else {
        _facebookButton.enabled  = NO;
    }
    
    [self updateSendButton];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    
    NSInteger charactersRemaining = 140 - [textView.text length];
    
    if (charactersRemaining > 0) {
        _tweetRemainingLabel.text = [NSString stringWithFormat:@"%d", charactersRemaining];
        _tweetRemainingLabel.textColor = [UIColor grayColor];
    } else if (charactersRemaining == 0) {
        _tweetRemainingLabel.text = [_perfectTweetRemarks objectAtIndex:(arc4random() % [_perfectTweetRemarks count])];
        _tweetRemainingLabel.textColor = [UIColor grayColor];
    } else {
        _tweetRemainingLabel.text = [NSString stringWithFormat:@"%d", charactersRemaining];
        _tweetRemainingLabel.textColor = [UIColor redColor];
    }
    
    [self updateSendButton];
}


//- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText
//{
//    if (aTextView == _bodyTextView) {
//        
//        NSRange permalink = [_bodyTextView.text rangeOfString:[NSString stringWithFormat:@" %@", _video.shortPermalink]];
//        
//        if (aRange.length == 0 && aRange.location <= permalink.location) {
//            // this is fine
//        } else if (aRange.location >= permalink.location && aRange.location < (permalink.location + permalink.length)) {
//            return NO;
//        }
//    }
    
//    NSString* newText = [aTextView.text stringByReplacingCharactersInRange:aRange withString:aText];
//    
//    // TODO - find out why the size of the string is smaller than the actual width, so that you get extra, wrapped characters unless you take something off
//    CGSize tallerSize = CGSizeMake(aTextView.frame.size.width-15,aTextView.frame.size.height*2); // pretend there's more vertical space to get that extra line to check on
//    CGSize newSize = [newText sizeWithFont:aTextView.font constrainedToSize:tallerSize lineBreakMode:UILineBreakModeWordWrap];
//    
//    if (newSize.height > aTextView.frame.size.height) {
//        {
//            LOG(@"error. too big!");
//            // TODO: Consider hitting send if they hit enter again at this point.
//            
//            //[myAppDelegate beep];
//            return NO;
//        }
//    } else {
//        return YES;
//    }
//}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
//    if (textField == _emailRecipientTextField) {
//        [_bodyTextView becomeFirstResponder];
//        return NO;
//    }
    return YES;
}

- (void) numberOfEmailTokensChanged;
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    [self updateSendButton];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
    // on iPad we just use the auto-rotate stuff
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    
    // on iPhone we do some manual adjustments.
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        
        CGRect temp = _shareTypeSelector.frame;
        temp.size.width = 150;
        temp.origin.x = 10;
        temp.origin.y = 10;
        _shareTypeSelector.frame = temp;
    
        temp = _socialBodyPlaceholder.frame;
        temp.origin.x = 170;
        temp.origin.y = 10;
        temp.size.height = 74;
        _socialBodyPlaceholder.frame = temp;
        
        temp = _postButtonsContainerView.frame;
        temp.origin.x = 10;
        temp.origin.y = 45;
        _postButtonsContainerView.frame = temp;
        
        temp = _tweetRemainingLabel.frame;
        temp.origin.x = 170;
        temp.origin.y = 89;
        temp.size.width = 300;
        _tweetRemainingLabel.frame = temp;
        
        temp = _emailBodyPlaceholder.frame;
        temp.origin.x = 10;
        temp.origin.y = 50;
        temp.size.width = 460;
        temp.size.height = 50;
        _emailBodyPlaceholder.frame = temp;
        
        temp = _emailRecipientContainerView.frame;
        temp.origin.x = 170;
        temp.origin.y = 10;
        temp.size.height = 31;
        _emailRecipientContainerView.frame = temp;
        
        temp = _emailRecipientSuggestionsHolder.frame;
        temp.origin.x = 205;
        temp.origin.y = 40;
        temp.size.height = 74;
        _emailRecipientSuggestionsHolder.frame = temp;

    } else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {

        CGRect temp = _shareTypeSelector.frame;
        temp.size.width = 207;
        temp.origin.x = 56;
        temp.origin.y = 10;
        _shareTypeSelector.frame = temp;
        
        temp = _socialBodyPlaceholder.frame;
        temp.origin.x = 10;
        temp.origin.y = 50;
        temp.size.height = 95;
        _socialBodyPlaceholder.frame = temp;
        
        temp = _postButtonsContainerView.frame;
        temp.origin.x = 11;
        temp.origin.y = 150;
        _postButtonsContainerView.frame = temp;
        
        temp = _tweetRemainingLabel.frame;
        temp.origin.x = 104;
        temp.origin.y = 150;
        temp.size.width = 205;
        _tweetRemainingLabel.frame = temp;
        
        temp = _emailBodyPlaceholder.frame;
        temp.origin.x = 10;
        temp.origin.y = 118;
        temp.size.width = 300;
        temp.size.height = 92;
        _emailBodyPlaceholder.frame = temp;
        
        temp = _emailRecipientContainerView.frame;
        temp.origin.x = 10;
        temp.origin.y = 50;
        temp.size.height = 58;
        _emailRecipientContainerView.frame = temp;
        
        temp = _emailRecipientSuggestionsHolder.frame;
        temp.origin.x = 45;
        temp.origin.y = 108;
        temp.size.height = 112;
        _emailRecipientSuggestionsHolder.frame = temp;
    }
    
    if ([_shareTypeSelector selectedSegmentIndex] == 0)
    {
        _bodyTextContainerView.frame = _socialBodyPlaceholder.frame;
    } else {
        _bodyTextContainerView.frame = _emailBodyPlaceholder.frame;
    }
}

@end




























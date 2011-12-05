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
                                @"I don't always tweet, but when I do, it's 140 characters.",
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
    //return _emailRecipientTextField.text;
    return @""; // XXX
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
//    [_emailRecipientTextField resignFirstResponder];
    [_bodyTextView resignFirstResponder];
}

#pragma mark - UI Callbacks

- (IBAction)closeWasPressed:(id)sender {
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
    [self updateInterfaceType];
    [self updateSendButton];
}

- (void)updateSendButton
{
    if ([_shareTypeSelector selectedSegmentIndex] == 0 && 
        [[self socialNetworks] count] == 0) {
        _sendButton.enabled = NO;
    } else if ([_shareTypeSelector selectedSegmentIndex] == 1
               // && [_emailRecipientTextField.text length] == 0
               ) {
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
    [self setTwitterEnabled:_twitterButton.selected];
}

- (IBAction)facebookWasPressed:(id)sender
{
    UIButton *button = (UIButton *) sender;
    [button setSelected:!button.selected];
    [self updateSendButton];
}

- (IBAction)sendWasPressed:(id)sender {
    
    // send should do nothing if in social mode and no social networks chosen
    if ([_shareTypeSelector selectedSegmentIndex] == 0 && 
        [[self socialNetworks] count] == 0) {
        return;
    }
    
    if ([_shareTypeSelector selectedSegmentIndex] == 1
        // && [_emailRecipientTextField.text length] == 0
        )
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


- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText
{
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
//    if (textField == _emailRecipientTextField) {
//        [_bodyTextView becomeFirstResponder];
//        return NO;
//    }
    return YES;
}

- (IBAction)emailRecipientValueChanged:(id)sender
{
    [self updateSendButton];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
    // on iPad we just use the auto-rotate stuff
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    
    // on iPhone we do some manual adjustments.
//    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
//        CGRect temp = _twitterButton.frame;
//        temp.origin = CGPointMake(271, 40);
//        _twitterButton.frame = temp;
//        
//        temp = _facebookButton.frame;
//        temp.origin = CGPointMake(314, 40);
//        _facebookButton.frame = temp;
//        
//        temp = _postShareOn.frame;
//        temp.origin = CGPointMake(273, 18);
//        _postShareOn.frame = temp;
//        
//        temp = _socialTextView.frame;
//        temp.size = CGSizeMake(250, 113);
//        _socialTextView.frame = temp;
//        _socialTextBackground.frame = temp;
//        
//        temp = _emailTextView.frame;
//        temp.size = CGSizeMake(250, 83);
//        _emailTextView.frame = temp;
//        _emailTextBackground.frame = temp;
//        
//        temp = _emailRecipientView.frame;
//        temp.size = CGSizeMake(225, 25);
//        _emailRecipientView.frame = temp;
//
//    }
//    else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
//        CGRect temp = _twitterButton.frame;
//        temp.origin = CGPointMake(8, 170);
//        _twitterButton.frame = temp;
//        
//        temp = _facebookButton.frame;
//        temp.origin = CGPointMake(51, 170);
//        _facebookButton.frame = temp;
//        
//        temp = _postShareOn.frame;
//        temp.origin = CGPointMake(10, 148);
//        _postShareOn.frame = temp;
//        
//        temp = _socialTextView.frame;
//        temp.size = CGSizeMake(203, 135);
//        _socialTextView.frame = temp;
//        _socialTextBackground.frame = temp;
//        
//        temp = _emailTextView.frame;
//        temp.size = CGSizeMake(203, 119);
//        _emailTextView.frame = temp;
//        _emailTextBackground.frame = temp;
//        
//        temp = _emailRecipientView.frame;
//        temp.size = CGSizeMake(178, 25);
//        _emailRecipientView.frame = temp;
//    }
}


- (IBAction)addContactWasPressed:(id)sender
{

    

}    
    
//    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
//    picker.peoplePickerDelegate = self;
//    // Display only a person's phone, email, and birthdate
//    NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonEmailProperty], nil];
//    picker.displayedProperties = displayedItems;
//    // Show the picker 
//
//    [self presentModalViewController:picker animated:YES];
//    [picker release];
//    
//    
//    NSMutableArray *emailAddress = [[NSMutableArray new] init];
//    ABRecordRef record_;
//
//    ABAddressBookRef addressBook = ABAddressBookCreate();
//    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
//    
//    ABAddressBookRef ab = [self.tokenFieldDelegate addressBookForTokenField:self];
//    NSArray *people = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(ab));
//    records = [NSMutableArray new];
//    for (id obj in people) {
//        ABRecordRef recordRef = (__bridge CFTypeRef)obj;
//        CORecord *record = [CORecord new];
//        record->record_ = CFRetain(recordRef);
//        [records addObject:record];
//    }
//    lastUpdated = [NSDate date];
//    
//    ABMultiValueRef multi = ABRecordCopyValue(record_, kABPersonEmailProperty);
//    CFIndex multiCount = ABMultiValueGetCount(multi);
//    for (CFIndex i=0; i<multiCount; i++) {
//        CORecordEmail *email = [CORecordEmail new];
//        email->emails_ = CFRetain(multi);
//        email->identifier_ = ABMultiValueGetIdentifierAtIndex(multi, i);
//        [addresses addObject:email];
//    }
//    CFRelease(multi);
//    return [NSArray arrayWithArray:addresses];
//}


@end

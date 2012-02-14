//
//  ShareView.m
//  Shelby
//
//  Created by Mark Johnson on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShareView.h"
#import "Video.h"
#import "User.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "COPeoplePickerViewController.h"


@implementation ShareView

@synthesize delegate;
@synthesize bodyTextView = _bodyTextView;

#pragma mark Toggle Views

+ (ShareView *)shareViewFromNib
{
    NSArray *objects;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        objects = [[NSBundle mainBundle] loadNibNamed:@"ShareView_iPad" owner:self options:nil];
    } else {
        objects = [[NSBundle mainBundle] loadNibNamed:@"ShareView_iPhone" owner:self options:nil];
    }
    
    [((ShareView *)[objects objectAtIndex:0]) initView];
    
    return [objects objectAtIndex:0];
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
    if (_video.sharer) {
        defaultComment = [NSString stringWithFormat: @"\"%@\" on [shelby.tv_short_link] via %@ ", _video.title, [_video.sharer lowercaseString]];
    }

    _bodyTextView.text = defaultComment;
    _bodyTextView.selectedRange = NSMakeRange(0, [[NSString stringWithFormat: @"\"%@\" on", _video.title] length]);
    [self textViewDidChange:_bodyTextView];
    
    [_peoplePicker clearTokenField];
    
    [self updateSendButton];
    
    [self setNeedsDisplay];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)initView
{
    _perfectTweetRemarks = [[NSArray alloc] initWithObjects:@"the perfect tweet!", 
                           @"nailed it.", 
                           @"honeymoon fit.", 
                           @"...like a glove.", 
                           // @"I don't always tweet, but when I do, it's 140 characters.", // too long for iPhone
                           @"best. tweet. ever.", 
                           @"dead on balls accurate.", nil];
    
    if (NOT_NULL(_video)) {
        [self populateUI];
    }
    
    _peoplePicker = [[COPeoplePickerViewController alloc] initWithFrame:_emailRecipientFieldHolder.bounds];
    _peoplePicker.tableViewHolder = _emailRecipientSuggestionsHolder;
    _peoplePicker.delegate = self;
    [_emailRecipientFieldHolder addSubview:_peoplePicker.view];
    
    UIColor *backgroundPattern = [UIColor colorWithPatternImage: [UIImage imageNamed: @"ForegroundStripes"]];
    _dialogContainerView.backgroundColor = backgroundPattern;
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
        BOOL twitter  = (!_twitterButton.selected) && (_twitterButton.enabled);
        BOOL facebook = (!_facebookButton.selected) && (_facebookButton.enabled);
        BOOL tumblr = (!_tumblrButton.selected) && (_tumblrButton.enabled);
        
        // Check the state of the FB & Twitter buttons
        if (twitter) {
            [array addObject: @"twitter"];
        }
        if (facebook) {
            [array addObject: @"facebook"];
        }
        if (tumblr) {
            [array addObject: @"tumblr"];
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

- (IBAction)tumblrWasPressed:(id)sender
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
    
    if ([user.auth_tumblr boolValue]) {
        _tumblrButton.enabled   = YES;
        _tumblrButton.selected  = NO;
    } else {
        _tumblrButton.enabled  = NO;
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }

    return YES;
}

- (void) numberOfEmailTokensChanged;
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    [self updateSendButton];
}

- (void)layoutSubviews
{
    // on iPad we just use the auto-rotate stuff
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
        
    // on iPhone we do some manual adjustments.
    if (self.bounds.size.width > self.bounds.size.height) {
                
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

    } else {
        
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




























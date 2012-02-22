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

- (void)iPhoneInitializeSelectionScreen
{
    _iPhoneShareScreenState = SHARE_SELECTION_SCREEN;
    _bodyTextContainerView.hidden = YES;
    _emailRecipientContainerView.hidden = YES;
    _postButtonsContainerView.hidden = YES;
    _tweetRemainingLabel.hidden = YES;
    
    _shareViaEmailButton.selected = NO;
    _shareViaPostButton.selected = NO;
    _shareViaButtonsContainerView.hidden = NO;
    
    [_cancelBackButton setTitle:@"Cancel"];
    _toolbarLabel.text = @"Share";
    
    NSMutableArray *toolbarItems = [[[NSMutableArray alloc] initWithArray:[_toolbar items]] autorelease];
    if ([toolbarItems containsObject:_sendButton]) {
        [toolbarItems removeObject:_sendButton];
    }
    
    [_toolbar setItems:toolbarItems animated:NO];
}

- (void)populateUI
{
    // Populate the UI.
    NSString *defaultComment = @"";
    
    if (NOT_NULL(_video.title)) {
        
        if (NOT_NULL(_video.sharer)) {
            defaultComment = [NSString stringWithFormat: @"\"%@\" on [shelby.tv_short_link] via %@", _video.title, [_video.sharer lowercaseString]];
        } else {
            defaultComment = [NSString stringWithFormat: @"\"%@\" on [shelby.tv_short_link]", _video.title];
        }

        _bodyTextView.text = defaultComment;
        _bodyTextView.selectedRange = NSMakeRange(0, [[NSString stringWithFormat: @"\"%@\" on", _video.title] length]);
        
    } else {
        
        if (NOT_NULL(_video.sharer)) {
            defaultComment = [NSString stringWithFormat: @"Great video on [shelby.tv_short_link] via %@", [_video.sharer lowercaseString]];
        } else {
            defaultComment = @"Great video on [shelby.tv_short_link]";
        }
        
        _bodyTextView.text = defaultComment;
        _bodyTextView.selectedRange = NSMakeRange(0, [[NSString stringWithFormat: @"Great video on", _video.title] length]);
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self iPhoneInitializeSelectionScreen];
    }
    
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
    
    UIColor *backgroundPattern = [UIColor colorWithPatternImage: [UIImage imageNamed: @"shareBackground"]];
    _dialogContainerView.backgroundColor = backgroundPattern;
    
    [_sendButton retain];
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
    if (_shareViaEmailButton.selected) {
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
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&  
       _iPhoneShareScreenState == SHARE_TEXTENTRY_SCREEN)
    {
        [self iPhoneInitializeSelectionScreen];
        return;
    }
    
    if (self.delegate) {
        [self.delegate shareViewClosePressed : self];
    }
}

- (void)updateInterfaceType
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return;
    }
    
    if (_shareViaPostButton.selected) {
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

- (IBAction)shareViaPostButtonPressed:(id)sender
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    
    if (_shareViaPostButton.selected) {
        return;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _iPhoneShareScreenState = SHARE_TEXTENTRY_SCREEN;
        _bodyTextContainerView.hidden = NO;
        _emailRecipientContainerView.hidden = YES;
        _postButtonsContainerView.hidden = NO;
        _tweetRemainingLabel.hidden = NO;
        _shareViaButtonsContainerView.hidden = YES;
        
        _bodyTextContainerView.frame = _socialBodyPlaceholder.frame;
        [_cancelBackButton setTitle:@"Back"];
        _toolbarLabel.text = @"Post";
        
        NSMutableArray *toolbarItems = [[[NSMutableArray alloc] initWithArray:[_toolbar items]] autorelease];
        if (![toolbarItems containsObject:_sendButton]) {
            [toolbarItems addObject:_sendButton];
        }
        
        [_toolbar setItems:toolbarItems animated:NO];
        
        [_bodyTextView becomeFirstResponder];
    }
    
    _shareViaEmailButton.selected = NO;
    _shareViaPostButton.selected = YES;
    
    [self updateInterfaceType];
    [self updateSendButton];
}

- (IBAction)shareViaEmailButtonPressed:(id)sender
{
    if (delegate) {
        [delegate shareViewWasTouched];
    }
    
    if (_shareViaEmailButton.selected) {
        return;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _iPhoneShareScreenState = SHARE_TEXTENTRY_SCREEN;
        _bodyTextContainerView.hidden = NO;
        _emailRecipientContainerView.hidden = NO;
        _postButtonsContainerView.hidden = YES;
        _tweetRemainingLabel.hidden = YES;
        _shareViaButtonsContainerView.hidden = YES;
        
        _bodyTextContainerView.frame = _emailBodyPlaceholder.frame;
        [_cancelBackButton setTitle:@"Back"];
        _toolbarLabel.text = @"Email";
        
        NSMutableArray *toolbarItems = [[[NSMutableArray alloc] initWithArray:[_toolbar items]] autorelease];
        if (![toolbarItems containsObject:_sendButton]) {
            [toolbarItems addObject:_sendButton];
        }
        
        [_toolbar setItems:toolbarItems animated:NO];
        
        [_bodyTextView becomeFirstResponder];
    }
    
    _shareViaPostButton.selected = NO;
    _shareViaEmailButton.selected = YES;
    
    [self updateInterfaceType];
    [self updateSendButton];
}

- (void)updateSendButton
{
    if (_shareViaPostButton.selected && 
        [[self socialNetworks] count] == 0) {
        _sendButton.enabled = NO;
    } else if (_shareViaEmailButton.selected
                && [_peoplePicker tokenCount] == 0) {
        _sendButton.enabled = NO;
    } else if (_shareViaPostButton.selected &&
        !_twitterButton.selected && _bodyTextView.text.length > 140) {
        _sendButton.enabled = NO;
    } else {
        _sendButton.enabled = YES;
    }
}

- (void)setTwitterEnabled:(BOOL)enabled
{
    _twitterButton.selected = !enabled;
    
    if (!_shareViaPostButton.selected) {
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
    if (_shareViaPostButton.selected && 
        [[self socialNetworks] count] == 0) {
        return;
    }
    
    if (_shareViaEmailButton.selected
         && [_peoplePicker tokenCount] == 0)
    {
        return;
    }
    
    NSString *message = _bodyTextView.text;
    NSArray *networks = [self socialNetworks];
    NSString *recipients = (_shareViaEmailButton.selected) ? [self recipients] : nil;
    
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
                
        CGRect temp = _shareViaPostButton.frame;
        temp.origin.x = 76;
        temp.origin.y = 82;
        _shareViaPostButton.frame = temp;
        
        temp = _shareViaEmailButton.frame;
        temp.origin.x = 311;
        temp.origin.y = 86;
        _shareViaEmailButton.frame = temp;
        
        _landscapeShareButtonSeparatorView.alpha = 1.0;
        _portraitShareButtonSeparatorView.alpha = 0.0;
        
        temp = _socialBodyPlaceholder.frame;
        temp.origin.x = 115;
        temp.origin.y = 7;
        temp.size.width = 355;
        temp.size.height = 75;
        _socialBodyPlaceholder.frame = temp;
        
        temp = _postButtonsContainerView.frame;
        temp.origin.x = 7;
        temp.origin.y = 7;
        temp.size.width = 100;
        temp.size.height = 100;
        _postButtonsContainerView.frame = temp;
        
        temp = _tweetRemainingLabel.frame;
        temp.origin.x = 170;
        temp.origin.y = 87;
        _tweetRemainingLabel.frame = temp;
        
        temp = _emailBodyPlaceholder.frame;
        temp.origin.x = 7;
        temp.origin.y = 44;
        temp.size.width = 466;
        temp.size.height = 60;
        _emailBodyPlaceholder.frame = temp;
        
        temp = _emailRecipientContainerView.frame;
        temp.origin.x = 7;
        temp.origin.y = 7;
        temp.size.width = 466;
        temp.size.height = 30;
        _emailRecipientContainerView.frame = temp;
        
        temp = _emailRecipientSuggestionsHolder.frame;
        temp.origin.x = 47;
        temp.origin.y = 37;
        temp.size.width = 466;
        temp.size.height = 77;
        _emailRecipientSuggestionsHolder.frame = temp;

    } else {
        
        CGRect temp = _shareViaPostButton.frame;
        temp.origin.x = 116;
        temp.origin.y = 56;
        _shareViaPostButton.frame = temp;
        
        temp = _shareViaEmailButton.frame;
        temp.origin.x = 111;
        temp.origin.y = 266;
        _shareViaEmailButton.frame = temp;
        
        _landscapeShareButtonSeparatorView.alpha = 0.0;
        _portraitShareButtonSeparatorView.alpha = 1.0;
                
        temp = _socialBodyPlaceholder.frame;
        temp.origin.x = 10;
        temp.origin.y = 72;
        temp.size.width = 300;
        temp.size.height = 110;
        _socialBodyPlaceholder.frame = temp;
        
        temp = _postButtonsContainerView.frame;
        temp.origin.x = 10;
        temp.origin.y = 15;
        temp.size.width = 154;
        temp.size.height = 47;
        _postButtonsContainerView.frame = temp;
        
        temp = _tweetRemainingLabel.frame;
        temp.origin.x = 10;
        temp.origin.y = 187;
        _tweetRemainingLabel.frame = temp;
        
        temp = _emailBodyPlaceholder.frame;
        temp.origin.x = 10;
        temp.origin.y = 88;
        temp.size.width = 300;
        temp.size.height = 120;
        _emailBodyPlaceholder.frame = temp;
        
        temp = _emailRecipientContainerView.frame;
        temp.origin.x = 10;
        temp.origin.y = 15;
        temp.size.width = 300;
        temp.size.height = 58;
        _emailRecipientContainerView.frame = temp;
        
        temp = _emailRecipientSuggestionsHolder.frame;
        temp.origin.x = 50;
        temp.origin.y = 73;
        temp.size.width = 260;
        temp.size.height = 147;
        _emailRecipientSuggestionsHolder.frame = temp;
    }
    
    if (_shareViaPostButton.selected)
    {
        _bodyTextContainerView.frame = _socialBodyPlaceholder.frame;
    } else {
        _bodyTextContainerView.frame = _emailBodyPlaceholder.frame;
    }
}

@end




























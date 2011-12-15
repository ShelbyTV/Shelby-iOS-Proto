//
//  ShareViewController.h
//  Shelby
//
//  Created by Mark Johnson on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COPeoplePickerViewController.h"

@class ShareViewController;
@class Video;
@class User;

@class COPeoplePickerViewController;

@protocol ShareViewDelegate 

- (void)shareViewClosePressed:(ShareViewController*)shareView;
- (void)shareView:(ShareViewController*)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks andRecipients:(NSString *)recipients;
- (void)shareViewWasTouched;

@end

@interface ShareViewController : UIViewController <COPeoplePickerDelegate>
{
    IBOutlet UIButton *_twitterButton;
    IBOutlet UIButton *_facebookButton;
    IBOutlet UIBarButtonItem *_sendButton;
    
    IBOutlet UITextView *_bodyTextView;
    IBOutlet UIView *_emailRecipientFieldHolder;
    IBOutlet UIView *_emailRecipientSuggestionsHolder;
    
    IBOutlet UIView *_bodyTextContainerView;
    IBOutlet UIView *_postButtonsContainerView;
    IBOutlet UIView *_emailRecipientContainerView;
    
    IBOutlet UIView *_dialogContainerView;
    
    IBOutlet UIView *_socialBodyPlaceholder;
    IBOutlet UIView *_emailBodyPlaceholder;
    
    IBOutlet UISegmentedControl *_shareTypeSelector;
    
    IBOutlet UILabel *_tweetRemainingLabel;
    
    COPeoplePickerViewController *_peoplePicker;
    
    NSArray *_perfectTweetRemarks;
    Video *_video;
}

@property (assign) id <ShareViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextView *bodyTextView;

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (IBAction)segmentedControlValueChanged:(id)sender;
- (IBAction)closeWasPressed:(id)sender;
- (IBAction)twitterWasPressed:(id)sender;
- (IBAction)facebookWasPressed:(id)sender;
- (IBAction)sendWasPressed:(id)sender;
- (void)textViewDidChange:(UITextView *)textView;
- (void)setTwitterEnabled:(BOOL)enabled;

- (void)updateSendButton;

- (void)updateAuthorizations:(User *)user;

- (void)setVideo:(Video *)video;
- (Video *)getVideo;

- (void)numberOfEmailTokensChanged;

@end

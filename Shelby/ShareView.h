//
//  ShareView.h
//  Shelby
//
//  Created by Mark Johnson on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COPeoplePickerViewController.h"

@class ShareView;
@class Video;
@class User;

@class COPeoplePickerViewController;

@protocol ShareViewDelegate 

- (void)shareViewClosePressed:(ShareView*)shareView;
- (void)shareView:(ShareView*)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks andRecipients:(NSString *)recipients;
- (void)shareViewWasTouched;

@end

typedef enum {
    SHARE_SELECTION_SCREEN,
    SHARE_TEXTENTRY_SCREEN
} ShareScreen;

@interface ShareView : UIView <COPeoplePickerDelegate>
{
    IBOutlet UIButton *_twitterButton;
    IBOutlet UIButton *_facebookButton;
    IBOutlet UIButton *_tumblrButton;
    
    IBOutlet UILabel *_toolbarLabel;
    IBOutlet UIToolbar *_toolbar;
    IBOutlet UIBarButtonItem *_cancelBackButton;
    IBOutlet UIBarButtonItem *_sendButton;
    
    IBOutlet UITextView *_bodyTextView;
    IBOutlet UIView *_emailRecipientFieldHolder;
    IBOutlet UIView *_emailRecipientSuggestionsHolder;
    
    IBOutlet UIView *_bodyTextContainerView;
    IBOutlet UIView *_postButtonsContainerView;
    IBOutlet UIView *_emailRecipientContainerView;
    
    IBOutlet UIView *_dialogContainerView;
    
    IBOutlet UIView *_shareViaButtonsContainerView;
    IBOutlet UIView *_portraitShareButtonSeparatorView;
    IBOutlet UIView *_landscapeShareButtonSeparatorView;
    IBOutlet UIButton *_shareViaPostButton;
    IBOutlet UIButton *_shareViaEmailButton;
    
    IBOutlet UIView *_socialBodyPlaceholder;
    IBOutlet UIView *_emailBodyPlaceholder;
        
    IBOutlet UILabel *_tweetRemainingLabel;
    
    COPeoplePickerViewController *_peoplePicker;
    
    ShareScreen _iPhoneShareScreenState;
    
    NSArray *_perfectTweetRemarks;
    Video *_video;
}

@property (assign) id <ShareViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextView *bodyTextView;

+ (ShareView *)shareViewFromNib;

- (void)initView;

- (IBAction)shareViaPostButtonPressed:(id)sender;
- (IBAction)shareViaEmailButtonPressed:(id)sender;

- (IBAction)closeWasPressed:(id)sender;
- (IBAction)twitterWasPressed:(id)sender;
- (IBAction)facebookWasPressed:(id)sender;
- (IBAction)tumblrWasPressed:(id)sender;
- (IBAction)sendWasPressed:(id)sender;
- (void)textViewDidChange:(UITextView *)textView;
- (void)setTwitterEnabled:(BOOL)enabled;

- (void)updateSendButton;

- (void)updateAuthorizations:(User *)user;

- (void)setVideo:(Video *)video;
- (Video *)getVideo;

- (void)numberOfEmailTokensChanged;

@end

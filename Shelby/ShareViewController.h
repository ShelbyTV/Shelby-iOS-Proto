//
//  ShareViewController.h
//  Shelby
//
//  Created by Mark Johnson on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareViewController;
@class Video;
@class User;

@protocol ShareViewDelegate 

- (void)shareViewClosePressed:(ShareViewController*)shareView;
- (void)shareView:(ShareViewController*)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks andRecipients:(NSString *)recipients;

@end

@interface ShareViewController : UIViewController
{
    IBOutlet UIButton *_twitterButton;
    IBOutlet UIButton *_facebookButton;
    IBOutlet UIButton *_emailButton;
    IBOutlet UIButton *_socialButton;
    
    IBOutlet UIImageView *_socialTextBackground;
    IBOutlet UITextView *_socialTextView;
    
    IBOutlet UIImageView *_emailTextBackground;
    IBOutlet UITextView *_emailTextView;
    IBOutlet UITextField *_emailRecipientView;
    
    IBOutlet UILabel *_postShareOn;
    
    Video *_video;
}

@property (assign) id <ShareViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextView *socialTextView;
@property (nonatomic, retain) IBOutlet UITextView *emailTextView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *topBackground;
@property (nonatomic, retain) IBOutlet UIView *emailView;
@property (nonatomic, retain) IBOutlet UIView *socialView;
@property (nonatomic, assign) UIView *activeView;

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (IBAction)socialWasPressed:(id)sender;
- (IBAction)emailWasPressed:(id)sender;
- (IBAction)twitterWasPressed:(id)sender;
- (IBAction)facebookWasPressed:(id)sender;
- (IBAction)sendWasPressed:(id)sender;

- (void)updateAuthorizations:(User *)user;

- (void)setVideo:(Video *)video;
- (Video *)getVideo;

@end

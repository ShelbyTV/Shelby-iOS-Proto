//
//  STVShareView.h
//  Shelby
//
//  Created by David Kay on 9/25/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STVShareView;
@class Video;
@class User;

@protocol STVShareViewDelegate 

- (void)shareViewClosePressed:(STVShareView*)shareView;
- (void)shareView:(STVShareView*)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks andRecipients:(NSString *)recipients;

@end

@interface STVShareView : UIView {
  IBOutlet UIButton *_twitterButton;
  IBOutlet UIButton *_facebookButton;
  IBOutlet UIButton *_emailButton;
  IBOutlet UIButton *_socialButton;
  IBOutlet UITextView *_socialTextView;
  IBOutlet UITextView *_emailTextView;
  IBOutlet UITextField *_emailRecipientView;
  Video *_video;
}

@property (assign) id <STVShareViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *topBackground;
@property (nonatomic, retain) IBOutlet UIView *emailView;
@property (nonatomic, retain) IBOutlet UIView *socialView;
@property (nonatomic, assign) UIView *activeView;
@property (nonatomic, retain) Video *video;

+ (STVShareView *)viewFromNib;

- (IBAction)socialWasPressed:(id)sender;
- (IBAction)emailWasPressed:(id)sender;
- (IBAction)twitterWasPressed:(id)sender;
- (IBAction)facebookWasPressed:(id)sender;
- (IBAction)sendWasPressed:(id)sender;

- (void)updateAuthorizations:(User *)user;

@end

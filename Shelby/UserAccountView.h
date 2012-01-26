//
//  UserAccountView.h
//  Shelby
//
//  Created by Mark Johnson on 1/25/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@protocol UserAccountViewDelegate 

- (void)userAccountViewDemoMode;
- (void)userAccountViewBackToVideos;
- (void)userAccountViewAddFacebook;
- (void)userAccountViewAddTwitter;
- (void)userAccountViewAddTumblr;
- (void)userAccountViewLogOut;
- (void)userAccountViewTermsOfUse;
- (void)userAccountViewPrivacyPolicy;

@end

@interface UserAccountView : UIView
{
    IBOutlet UIButton *addFacebookButton;
    IBOutlet UIButton *addTwitterButton;
    IBOutlet UIButton *addTumblrButton;
    IBOutlet UIButton *logoutButton;
    
    IBOutlet UIButton *termsOfUseButton;
    IBOutlet UIButton *privacyPolicyButton;
    IBOutlet UILabel *legalBeagleLabel;
    IBOutlet UIView *legalBackgroundView;
    
    IBOutlet UIToolbar *_settingsToolbar;
    IBOutlet UIBarButtonItem *_demoModeButton;
}

@property (assign) id <UserAccountViewDelegate> delegate;

+ (UserAccountView *)userAccountViewFromNibWithFrame:(CGRect)frame
                                        withDelegate:(id <UserAccountViewDelegate>)delegate;

- (void)initViewWithFrame:(CGRect)frame
             withDelegate:(id <UserAccountViewDelegate>)delegate;

- (IBAction)demoMode:(id)sender;
- (IBAction)backToVideos:(id)sender;
- (IBAction)addFacebook:(id)sender;
- (IBAction)addTwitter:(id)sender;
- (IBAction)addTumblr:(id)sender;
- (IBAction)logOut:(id)sender;
- (IBAction)termsOfUse:(id)sender;
- (IBAction)privacyPolicy:(id)sender;

- (void)updateUserAuthorizations:(User *)user;

- (void)setDemoModeButtonEnabled;
- (void)setDemoModeButtonDisabled;
- (void)setDemoModeButtonTitle:(NSString *)title;

@end

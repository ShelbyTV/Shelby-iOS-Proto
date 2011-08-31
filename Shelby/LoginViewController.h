//
//  LoginViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NetworkManager;

@interface LoginViewController : UIViewController {
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    id callbackObject;
    SEL callbackSelector;

    // These are all to implement keyboard scrolling.
    IBOutlet UIScrollView *_scrollView;
    CGPoint _originalOffset;
    UIView *_activeField;

    // Actual login stuff.
    NetworkManager *_networkManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       callbackObject:(id)object
     callbackSelector:(SEL)selector;

- (void)fadeOut;
- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;
- (IBAction)registerWasPressed:(id)sender;
- (IBAction)loginWasPressed:(id)sender;

- (IBAction)requestTokenWasPressed:(id)sender;
- (IBAction)authorizeWasPressed:(id)sender;
- (IBAction)accessTokenWasPressed:(id)sender;
- (IBAction)fetchBroadcastsWasPressed:(id)sender;

@end

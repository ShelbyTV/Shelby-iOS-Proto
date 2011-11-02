//
//  LoginViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectivityViewController.h"
#import "NetworkObject.h"

@class LoginHelper;
@class Reachability;

@interface LoginViewController : ConnectivityViewController <UIWebViewDelegate, NetworkObject> {
    id callbackObject;
    SEL callbackSelector;
    
    IBOutlet UIView *activityHolder;

    // Actual login stuff
    LoginHelper *_loginHelper;
    
    IBOutlet UIWebView *_webView;
    IBOutlet UIView *_webViewHolder;
}

@property (readonly) NSInteger networkCounter;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       callbackObject:(id)object
     callbackSelector:(SEL)selector;

- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;

- (IBAction)closeWebView:(id)sender;

@end

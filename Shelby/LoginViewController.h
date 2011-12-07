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
#import "FullscreenWebView.h"

@class LoginHelper;
@class Reachability;

@interface LoginViewController : ConnectivityViewController <FullscreenWebViewDelegate, NetworkObject> {
    id callbackObject;
    SEL callbackSelector;
    
    IBOutlet UIView *activityHolder;

    // Actual login stuff
    LoginHelper *_loginHelper;
    
    FullscreenWebView *_fullscreenWebView;
}

@property (readonly) NSInteger networkCounter;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       callbackObject:(id)object
     callbackSelector:(SEL)selector;

- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;

// FullscreenWebViewDelegate
- (void)fullscreenWebViewCloseWasPressed:(id)sender;
- (void)fullscreenWebViewDidFinishLoad:(UIWebView *)webView;
- (void)fullscreenWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end

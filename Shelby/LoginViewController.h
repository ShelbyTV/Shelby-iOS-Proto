//
//  LoginViewController.h
//  Shelby
//
//  Created by Mark Johnson on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectivityViewController.h"

@class LoginHelper;
@class Reachability;

@interface LoginViewController : ConnectivityViewController {
    id callbackObject;
    SEL callbackSelector;
    
    IBOutlet UIView *activityHolder;

    // Actual login stuff
    LoginHelper *_loginHelper;
}
    
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       callbackObject:(id)object
     callbackSelector:(SEL)selector;

- (void)allDone;
- (void)fadeOut;
- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;

@end

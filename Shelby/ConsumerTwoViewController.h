//
//  ConsumerTwoViewController.h
//  ConsumerTwo
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoginHelper.h"

@interface ConsumerTwoViewController : UIViewController <LoginHelperDelegate> {
  LoginHelper *_loginHelper;
  IBOutlet UILabel *_requestTokenLabel;
  IBOutlet UILabel *_accessTokenLabel;
  
  IBOutlet UITextField *_urlField;
}

- (IBAction)requestTokenWasPressed:(id)sender;
- (IBAction)authorizeWasPressed:(id)sender;
- (IBAction)accessTokenWasPressed:(id)sender;

//- (IBAction)mapsWasPressed:(id)sender;
- (IBAction)goToUrlWasPressed:(id)sender;

@end

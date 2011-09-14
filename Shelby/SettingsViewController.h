//
//  SettingsViewController.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICustomSwitch;
@class SettingsViewController;

@protocol SettingsViewControllerDelegate

- (void)settingsViewControllerDone:(SettingsViewController *)settingsController;

@end

@interface SettingsViewController : UIViewController {
}

@property(nonatomic, assign) id <SettingsViewControllerDelegate> delegate;
@property(nonatomic, retain) IBOutlet UICustomSwitch *contactSwitch;
@property(nonatomic, retain) IBOutlet UICustomSwitch *whereToSwitch;

+ (SettingsViewController *)viewController;

- (IBAction)doneWasPressed:(id)sender;

@end

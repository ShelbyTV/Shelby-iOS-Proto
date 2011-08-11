//
//  SettingsViewController.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICustomSwitch;

@interface SettingsViewController : UIViewController {
    
}

@property(nonatomic, retain) IBOutlet UICustomSwitch * contactSwitch;
@property(nonatomic, retain) IBOutlet UICustomSwitch * whereToSwitch;

+ (SettingsViewController *)viewController;

@end

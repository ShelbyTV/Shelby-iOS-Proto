//
//  COPeoplePickerViewController.h
//  COPeoplePickerViewController
//
//  Created by Erik Aigner on 08.10.11.
//  Copyright (c) 2011 chocomoko.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol COPeoplePickerDelegate

- (void)numberOfEmailTokensChanged;

@end

@interface COPeoplePickerViewController : UIViewController

// An array of ABPropertyID listing the properties that should be visible when viewing a person.
// If you are interested in one particular type of data (for example a phone number), displayedProperties
// should be an array with a single NSNumber instance (representing kABPersonPhoneProperty).
// Note that name information will always be shown if available.
//
// DEVNOTE: currently only supports email (extend if you need more)
//
//@property (nonatomic, copy) NSArray *displayedProperties;

- (id)initWithFrame:(CGRect)frame;
- (int)tokenCount;
- (NSString *)concatenatedEmailAddresses;

@property (nonatomic, retain) UIView *tableViewHolder;
@property (nonatomic, assign) id <COPeoplePickerDelegate> delegate;

@end

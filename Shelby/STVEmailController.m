//
//  STVEmailController.m
//  Shelby
//
//  Created by David Kay on 10/12/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "STVEmailController.h"
#import "STVEmailController.h"
#import "SearchTestController.h"
#import "MockDataSource.h"
#import <Three20UI/UIViewAdditions.h>
#import <Three20UI/Three20UI.h>

@implementation STVEmailController

@synthesize parentViewController;

#pragma mark - private

- (UIViewController*)composeTo:(NSString*)recipient {
  TTTableTextItem* item = [TTTableTextItem itemWithText:recipient URL:nil];

  TTMessageController* controller =
    [[[TTMessageController alloc] initWithRecipients:[NSArray arrayWithObject:item]] autorelease];
  controller.dataSource = [[[MockSearchDataSource alloc] init] autorelease];
  controller.delegate = self;

  return controller;
}

- (UIViewController*)post:(NSDictionary*)query {
  TTPostController* controller = [[[TTPostController alloc] initWithNavigatorURL:nil
																		   query:
								   [NSDictionary dictionaryWithObjectsAndKeys:@"Default Text", @"text", nil]]
								   autorelease];
  controller.originView = [query objectForKey:@"__target__"];
  return controller;
}

- (void)cancelAddressBook {
  [[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:YES];
}

- (void)sendDelayed:(NSTimer*)timer {
  _sendTimer = nil;

  NSArray* fields = timer.userInfo;
  UIView* lastView = [self.parentViewController.view.subviews lastObject];
  CGFloat y = lastView.bottom + 20;

  TTMessageRecipientField* toField = [fields objectAtIndex:0];
  for (id recipient in toField.recipients) {
    UILabel* label = [[[UILabel alloc] init] autorelease];
    label.backgroundColor = self.parentViewController.view.backgroundColor;
    label.text = [NSString stringWithFormat:@"Sent to: %@", recipient];
    [label sizeToFit];
    label.frame = CGRectMake(30, y, label.width, label.height);
    y += label.height;
    [self.parentViewController.view addSubview:label];
  }

  [self.parentViewController.modalViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - NSObject

- (void)dealloc {
  [_sendTimer invalidate];
	[super dealloc];
}

#pragma mark - TTMessageControllerDelegate

- (void)composeController:(TTMessageController*)controller didSendFields:(NSArray*)fields {
  _sendTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
                        selector:@selector(sendDelayed:) userInfo:fields repeats:NO];
}

- (void)composeControllerDidCancel:(TTMessageController*)controller {
  [_sendTimer invalidate];
  _sendTimer = nil;

  [controller dismissModalViewControllerAnimated:YES];
}

- (void)composeControllerShowRecipientPicker:(TTMessageController*)controller {
  SearchTestController* searchController = [[[SearchTestController alloc] init] autorelease];
  searchController.delegate = self;
  searchController.title = @"Address Book";
  searchController.navigationItem.prompt = @"Select a recipient";
  searchController.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
      target:self action:@selector(cancelAddressBook)] autorelease];

  UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
  [navController pushViewController:searchController animated:NO];
  [controller presentModalViewController:navController animated:YES];
}

#pragma mark - SearchTestControllerDelegate

- (void)searchTestController:(SearchTestController*)controller didSelectObject:(id)object {
  TTMessageController* composeController = (TTMessageController*)self.parentViewController.modalViewController;
  [composeController addRecipient:object forFieldAtIndex:0];
  [controller dismissModalViewControllerAnimated:YES];
}


@end

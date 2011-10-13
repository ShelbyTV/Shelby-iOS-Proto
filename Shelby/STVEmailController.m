//
//  STVEmailController.m
//  Shelby
//
//  Created by David Kay on 10/12/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <Three20UI/UIViewAdditions.h>
#import <Three20UI/Three20UI.h>

#import "STVEmailController.h"
#import "BroadcastApi.h"
#import "SearchContactController.h"
#import "ContactDataSource.h"

@implementation STVEmailController

@synthesize parentViewController;
@synthesize searchViewController;
@synthesize video;

#pragma mark - Initialization

- (id)initWithParentViewController:(UIViewController *)parent {
  if (self = [super init]) {
    self.parentViewController = parent;
  }
  return self;
}

#pragma mark - private

- (UIViewController*)composeWithSubject:(NSString*)subject body:(NSString*)body {

  //TTTableTextItem* item = [TTTableTextItem itemWithText:recipient URL:nil];

  TTMessageController* controller =
    [[[TTMessageController alloc] initWithRecipients:nil] autorelease];
  controller.dataSource = [[[ContactSearchDataSource alloc] init] autorelease];
  controller.delegate = self;


  controller.showsRecipientPicker = YES;

  controller.subject = subject;
  controller.body    = body;

  return controller;
}

- (UIViewController*)composeTo:(NSString*)recipient {
  TTTableTextItem* item = [TTTableTextItem itemWithText:recipient URL:nil];

  TTMessageController* controller =
    [[[TTMessageController alloc] initWithRecipients:[NSArray arrayWithObject:item]] autorelease];
  controller.dataSource = [[[ContactSearchDataSource alloc] init] autorelease];
  controller.delegate = self;

  return controller;
}

- (void)cancelAddressBook {
  //[[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:YES];
  [self.searchViewController dismissModalViewControllerAnimated:YES];
}

- (void)sendDelayed:(NSTimer*)timer {
  _sendTimer = nil;

  NSArray* fields = timer.userInfo;

  NSString *recipients = nil;
  TTMessageRecipientField* toField = [fields objectAtIndex:0];
  //for (TTTextField *recipient in toField.recipients) {
  for (id recipient in toField.recipients) {

    Contact *contact = [recipient userInfo];

    if (recipients) {
      recipients = [NSString stringWithFormat: @"%@,%@",
                 recipients,
                 contact.email
      ];
    } else {
        recipients = contact.email;
    }
    //NSString *sentText = [NSString stringWithFormat:@"Sent to: %@", contact.name];
    //NSString *email = contact.email;

    //NSLog(sentText);
    //NSLog(email);
  }

  // TODO: POST to API
  TTMessageTextField* subjectField = [fields objectAtIndex: 1];
  TTTextEditor* bodyField = [fields objectAtIndex: 2];

  NSString *subject = subjectField.text;
  NSString *body = bodyField.text;

  NSLog(@"subject: %@", subject);
  NSLog(@"body: %@", body);
  NSLog(@"recipients: %@", recipients);

  [BroadcastApi share: self.video
              comment: body
             networks: [NSArray arrayWithObject: @"email"]
            recipient: recipients];

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
  SearchContactController* searchController = [[[SearchContactController alloc] init] autorelease];
  searchController.delegate = self;
  searchController.title = @"Address Book";
  searchController.navigationItem.prompt = @"Select a recipient";
  searchController.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
      target:self action:@selector(cancelAddressBook)] autorelease];

  self.searchViewController = searchController;

  UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
  [navController pushViewController:searchController animated:NO];
  [controller presentModalViewController:navController animated:YES];
}

#pragma mark - SearchTestControllerDelegate

- (void)searchTestController:(SearchContactController*)controller didSelectObject:(id)object {
  UINavigationController* navController = (UINavigationController*)self.parentViewController.modalViewController;
  TTMessageController* composeController = (TTMessageController*)navController.topViewController;
  [composeController addRecipient:object forFieldAtIndex:0];
  [controller dismissModalViewControllerAnimated:YES];
}


@end

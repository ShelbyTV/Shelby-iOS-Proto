//
//  ConsumerTwoViewController.m
//  ConsumerTwo
//
//  Created by David Kay on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConsumerTwoViewController.h"
#import "LoginHelper.h"

@implementation ConsumerTwoViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UI Callbacks

- (IBAction)requestTokenWasPressed:(id)sender {
  [_loginHelper getRequestToken];
}

- (IBAction)authorizeWasPressed:(id)sender {
   [_loginHelper authorizeToken: _loginHelper.requestToken];
}

- (IBAction)accessTokenWasPressed:(id)sender {
  [_loginHelper getAccessToken: _loginHelper.requestToken];
}

//- (IBAction)mapsWasPressed:(id)sender {
//  NSString *mapsPath = @"http://maps.google.com/maps?ll=-37.812022,144.969277";
//  NSURL *url = [NSURL URLWithString: mapsPath];
//	[[UIApplication sharedApplication] openURL:url];
//}

- (IBAction)goToUrlWasPressed:(id)sender {
  NSString *mapsPath = _urlField.text;
  NSURL *url = [NSURL URLWithString: mapsPath];
	[[UIApplication sharedApplication] openURL:url];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  _loginHelper = [[LoginHelper alloc] init];
  _loginHelper.delegate = self;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - LoginHelperDelegate Methods

- (void)fetchRequestTokenDidFinish:(OAToken *)requestToken {
  _requestTokenLabel.text = [requestToken description];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
  _requestTokenLabel.text = @"failed to fetch!";
}

- (void)fetchAccessTokenDidFinish:(OAToken *)accessToken {
  _accessTokenLabel.text = [accessToken description];
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
  _accessTokenLabel.text = @"failed to fetch!";
}

@end

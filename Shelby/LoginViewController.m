//
//  LoginViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)loginWithFacebook:(id)sender
{
    NSLog(@"loginWithFacebook! username:%@ password:%@", [username text], [password text]);
}

- (IBAction)loginWithTwitter:(id)sender
{
    NSLog(@"loginWithTwitter! username:%@ password:%@", [username text], [password text]);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // We resign the first responder
    // This closes the keyboard
	[textField resignFirstResponder];
    
    // Since we use this LoginViewController as the delegate for both username and password fields,
    // this one method closes the keyboard for both fields.
    
    // Return YES to confirm the UITextField is returning
	return YES;
}

@end

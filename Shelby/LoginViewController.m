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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /* 
     * Even though normally I don't like programmatically checking for iPad vs. iPhone, an iPad
     * or iPhone-specific subclass would only have this one method. Doesn't seem worth it.
     *
     * This may not be necessary -- just having this on the RootView might be enough?
     */
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait &&
            UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ||
           (interfaceOrientation == UIInterfaceOrientationLandscapeRight &&
            UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackgroundStripes" ofType:@"png"]]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)fadeOut
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0.0;
    }
    completion:^(BOOL finished){
        if (finished) {
            NSLog(@"Animation stopped!");
            [self.view setHidden:YES];
        }
    }];
}

- (IBAction)loginWithFacebook:(id)sender
{
    [self fadeOut];
        
    NSLog(@"loginWithFacebook! username:%@ password:%@", [username text], [password text]);
}

- (IBAction)loginWithTwitter:(id)sender
{
    [self fadeOut];
    
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


//
//  LoginViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginHelper.h"

@implementation LoginViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       callbackObject:(id)object
     callbackSelector:(SEL)selector
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        callbackObject = object;
        callbackSelector = selector;

        _loginHelper = [[LoginHelper alloc] init];
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

    // Add keyboard notification listeners so we can animate the view up/down.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    //username.keyboardType = UIKeyboardTypeDefault;
    //password.keyboardType = UIKeyboardTypeDefault
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // Remove keyboard notification listeners.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - Misc Methods

- (void)fadeOut
{
    //Note: this won't work on iOS3.
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0.0;
    }
    completion:^(BOOL finished){
        if (finished) {
            [self.view setHidden:YES];
        }
    }];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    LOG(@"keyboardWasShown");
    NSDictionary* info = [aNotification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect toView:nil];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    // Offset for a toolbar on the top of the screen.
    //aRect.size.height -= self.toolbar.frame.size.height;
    CGPoint fieldOrigin = _activeField.frame.origin;
    fieldOrigin.y -= _scrollView.contentOffset.y;
    fieldOrigin = [self.view convertPoint:fieldOrigin toView:self.view.superview];
    _originalOffset = _scrollView.contentOffset;
    if (!CGRectContainsPoint(aRect, fieldOrigin) ) {
        //[_scrollView scrollRectToVisible:_activeField.frame animated:YES];
    }
    // Add some buffer space so we don't have the textField against the top of the screen.

    float BUFFER = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  50.0f : 200.0f;

    CGPoint offset = CGPointMake(0, fieldOrigin.y - BUFFER);
    [_scrollView setContentOffset:offset
                         animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    LOG(@"keyboardWillBeHidden");
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    [_scrollView setContentOffset:_originalOffset animated:YES];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // We resign the first responder
    // This closes the keyboard
    if (textField == username) {
        // If we're coming from 'username', let's move focus to 'password.'
        [password becomeFirstResponder];
    }
    if (textField == password) {
        // If we're coming from 'password', we're done!
        [self loginWasPressed: password];
        [textField resignFirstResponder];
    }

    // Return YES to confirm the UITextField is returning
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _activeField = textField;
}

#pragma mark - View Callbacks

- (IBAction)loginWithFacebook:(id)sender
{
    [callbackObject performSelector:callbackSelector];
    [self fadeOut];

//    LOG(@"loginWithFacebook! username:%@ password:%@", [username text], [password text]);
}

- (IBAction)loginWithTwitter:(id)sender
{
    [callbackObject performSelector:callbackSelector];
    [self fadeOut];


//    LOG(@"loginWithTwitter! username:%@ password:%@", [username text], [password text]);
}

- (IBAction)registerWasPressed:(id)sender {
    // Open up a browswer to the shelby registration page?
    NSString *registrationUrl = @"http://shelby.tv";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: registrationUrl]];
}

- (IBAction)loginWasPressed:(id)sender {
    LOG(@"Login not implemented");
    //[_loginHelper getRequestToken];
}

- (IBAction)requestTokenWasPressed:(id)sender {
  [_loginHelper getRequestToken];
}

- (IBAction)authorizeWasPressed:(id)sender {
   [_loginHelper authorizeToken: _loginHelper.requestToken];
}

- (IBAction)accessTokenWasPressed:(id)sender {
  [_loginHelper getAccessToken: _loginHelper.requestToken];
}


@end


//
//  LoginViewController.m
//  Shelby
//
//  Created by Mark Johnson on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkManager.h"
#import "ShelbyApp.h"

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

        _networkManager = [ShelbyApp sharedApp].networkManager;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedIn:)
                                                     name:@"NetworkManagerLoggedIn"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedOut:)
                                                     name:@"NetworkManagerLoggedOut"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NetworkManagerLoggedIn" object:nil];
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

- (void)fade:(BOOL)visible {
    float alpha;
    BOOL hidden;
    if (visible) {
        alpha = 1.0f;
        hidden = NO;
    } else {
        alpha = 0.0f;
        hidden = YES;
    }
    //Note: this won't work on iOS3.
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = alpha;
    }
    completion:^(BOOL finished){
        if (finished) {
            [self.view setHidden: hidden];
        }
    }];
}

- (void)fadeIn
{
    [self fade: YES];
}

- (void)fadeOut
{
    [self fade: NO];
}

/**
 * Once we've completed logging in, this removes the view.
 */
- (void)allDone
{
    [callbackObject performSelector:callbackSelector];
    [self fadeOut];
}

- (void)beginLogin
{
#ifdef OFFLINE_MODE
    [self allDone];
#else
    [_networkManager beginOAuthHandshake];
#endif
}

#pragma mark - Notification Handlers

- (void)userLoggedIn:(NSNotification*)aNotification
{
    [self allDone];
}

- (void)userLoggedOut:(NSNotification*)aNotification
{
    // Show the screen again.
    [self fadeIn];
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
    //[self allDone];
    [self beginLogin];

//    LOG(@"loginWithFacebook! username:%@ password:%@", [username text], [password text]);
}

- (IBAction)loginWithTwitter:(id)sender
{
    //[self allDone];
    [self beginLogin];


//    LOG(@"loginWithTwitter! username:%@ password:%@", [username text], [password text]);
}

- (IBAction)registerWasPressed:(id)sender {
    // Open up a browswer to the shelby registration page?
    NSString *registrationUrl = @"http://shelby.tv";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: registrationUrl]];
}

- (IBAction)loginWasPressed:(id)sender {
    LOG(@"Login not implemented");
    //[_networkManager getRequestToken];
}

- (IBAction)requestTokenWasPressed:(id)sender {
    [self beginLogin];
}

- (IBAction)authorizeWasPressed:(id)sender {
   //[_networkManager authorizeToken: _networkManager.requestToken];
   //[_networkManager authorizeToken];
}

- (IBAction)accessTokenWasPressed:(id)sender {
     //[_networkManager getAccessToken: _networkManager.requestToken verifier: ];
     //[_networkManager getAccessToken];
}

@end

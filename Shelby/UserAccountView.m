//
//  UserAccountView.m
//  Shelby
//
//  Created by Mark Johnson on 1/25/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "UserAccountView.h"
#import "User.h"
#import "ShelbyApp.h"

@implementation UserAccountView

@synthesize delegate;

+ (UserAccountView *)userAccountViewFromNibWithFrame:(CGRect)frame
                                        withDelegate:(id <UserAccountViewDelegate>)uavDelegate
{
    NSArray *objects;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        objects = [[NSBundle mainBundle] loadNibNamed:@"UserAccount_iPad" owner:self options:nil];
    } else {
        objects = [[NSBundle mainBundle] loadNibNamed:@"UserAccount_iPhone" owner:self options:nil];
    }
    
    [((UserAccountView *)[objects objectAtIndex:0]) initViewWithFrame:frame withDelegate:uavDelegate];
    
    return [objects objectAtIndex:0];
}

- (void)initViewWithFrame:(CGRect)frame
             withDelegate:(id <UserAccountViewDelegate>)uavDelegate
{
    self.delegate = uavDelegate;
    self.frame = frame;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    // check if we're a developer or beta build to see if we need to remove demo mode button
    if (![(NSString *)[infoDictionary objectForKey:@"CFBundleVersion"] isEqualToString:@"X.X"] &&
        [(NSString *)[infoDictionary objectForKey:@"CFBundleVersion"] rangeOfString:@"b"].location == NSNotFound) 
    {
        NSMutableArray *items = [[_settingsToolbar.items mutableCopy] autorelease];
        [items removeObject:_demoModeButton];
        _settingsToolbar.items = items;
    } else {
        if ([ShelbyApp sharedApp].demoModeEnabled) {
            _demoModeButton.title = @"Demo Mode On";
            [self setDemoModeButtonDisabled];
        }
    }
    
    _demoModeButton.possibleTitles = [NSSet setWithObjects:@"Demo Mode", @"Waiting...", @"Downloading...", @"Demo Mode On", nil];
}

- (IBAction)demoMode:(id)sender
{
    if (delegate) {
        [delegate userAccountViewDemoMode];
    }
}

- (IBAction)backToVideos:(id)sender
{
    if (delegate) {
        [delegate userAccountViewBackToVideos];
    }
}

- (IBAction)addFacebook:(id)sender
{
    if (delegate) {
        [delegate userAccountViewAddFacebook];
    }    
}

- (IBAction)addTwitter:(id)sender
{
    if (delegate) {
        [delegate userAccountViewAddTwitter];
    }
}

- (IBAction)addTumblr:(id)sender
{
    if (delegate) {
        [delegate userAccountViewAddTumblr];
    }
}

- (IBAction)logOut:(id)sender
{
    if (delegate) {
        [delegate userAccountViewLogOut];
    }
}

- (IBAction)termsOfUse:(id)sender
{
    if (delegate) {
        [delegate userAccountViewTermsOfUse];
    }
}

- (IBAction)privacyPolicy:(id)sender
{
    if (delegate) {
        [delegate userAccountViewPrivacyPolicy];
    }
}

- (void)updateUserAuthorizations:(User *)user
{
    
    addTwitterButton.enabled = ![user.auth_twitter boolValue];
    addFacebookButton.enabled = ![user.auth_facebook boolValue];
    addTumblrButton.enabled = ![user.auth_tumblr boolValue];
}

- (void)setDemoModeButtonEnabled
{
    _demoModeButton.enabled = TRUE;
}

- (void)setDemoModeButtonDisabled
{
    _demoModeButton.enabled = FALSE;
}

- (void)setDemoModeButtonTitle:(NSString *)title
{
    [_demoModeButton performSelectorOnMainThread:@selector(setTitle:) withObject:title waitUntilDone:NO];
}

@end

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

- (void)layoutSubviews
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }

    // landscape
    if (self.bounds.size.width > self.bounds.size.height) {
        
        CGRect temp;
        
        temp = addFacebookButton.frame;
        temp.origin.x = 20;
        temp.origin.y = 64;
        temp.size.width = 280;
        addFacebookButton.frame = temp;
        
        temp = addTwitterButton.frame;
        temp.origin.x = 20;
        temp.origin.y = 116;
        temp.size.width = 280;
        addTwitterButton.frame = temp;
        
        temp = addTumblrButton.frame;
        temp.origin.x = 20;
        temp.origin.y = 168;
        temp.size.width = 280;
        addTumblrButton.frame = temp;
        
        temp = logoutButton.frame;
        temp.origin.x = 20;
        temp.origin.y = 244;
        temp.size.width = 280;
        logoutButton.frame = temp;
        
        temp = legalBackgroundView.frame;
        temp.origin.x = 320;
        temp.origin.y = 44;
        temp.size.width = 160;
        temp.size.height = 276;
        legalBackgroundView.frame = temp;
        
        temp = legalBeagleLabel.frame;
        temp.origin.x = 15;
        temp.origin.y = 20;
        temp.size.width = 130;
        temp.size.height = 100;
        legalBeagleLabel.frame = temp;
        
        temp = termsOfUseButton.frame;
        temp.origin.x = 10;
        temp.origin.y = 132;
        temp.size.width = 140;
        temp.size.height = 44;
        termsOfUseButton.frame = temp;
        
        temp = privacyPolicyButton.frame;
        temp.origin.x = 10;
        temp.origin.y = 184;
        temp.size.width = 140;
        temp.size.height = 44;
        privacyPolicyButton.frame = temp;

    } else { // portrait (values taken from NIB)
     
        CGRect temp;
        
        temp = addFacebookButton.frame;
        temp.origin.x = 20;
        temp.origin.y = 64;
        temp.size.width = 280;
        addFacebookButton.frame = temp;
        
        temp = addTwitterButton.frame;
        temp.origin.x = 20;
        temp.origin.y = 116;
        temp.size.width = 280;
        addTwitterButton.frame = temp;
                
        temp = addTumblrButton.frame;
        temp.origin.x = 20;
        temp.origin.y = 168;
        temp.size.width = 280;
        addTumblrButton.frame = temp;
        
        temp = logoutButton.frame;
        temp.origin.x = 20;
        temp.origin.y = 244;
        temp.size.width = 280;
        logoutButton.frame = temp;
        
        temp = legalBackgroundView.frame;
        temp.origin.x = 0;
        temp.origin.y = 374;
        temp.size.width = 320;
        temp.size.height = 106;
        legalBackgroundView.frame = temp;
        
        temp = legalBeagleLabel.frame;
        temp.origin.x = 20;
        temp.origin.y = 10;
        temp.size.width = 280;
        temp.size.height = 21;
        legalBeagleLabel.frame = temp;
        
        temp = termsOfUseButton.frame;
        temp.origin.x = 20;
        temp.origin.y = 42;
        temp.size.width = 136;
        temp.size.height = 44;
        termsOfUseButton.frame = temp;
        
        temp = privacyPolicyButton.frame;
        temp.origin.x = 164;
        temp.origin.y = 42;
        temp.size.width = 136;
        temp.size.height = 44;
        privacyPolicyButton.frame = temp;
    }
}

@end

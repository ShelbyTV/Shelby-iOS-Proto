//
//  FullscreenWebViewController.m
//  Shelby
//
//  Created by Mark Johnson on 12/7/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import "FullscreenWebViewController.h"

@implementation FullscreenWebViewController

@synthesize delegate;
@synthesize webView = _webView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // other stuff
    }
    return self;
}

- (IBAction)closeFullscreenWebViewController:(id)sender
{
    if (delegate) {
        [delegate fullscreenWebViewCloseWasPressed:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)view
{    
    if (delegate) {
        [delegate fullscreenWebViewDidFinishLoad:view];
    }
}

- (void)webView:(UIWebView *)view didFailLoadWithError:(NSError *)error
{    
    if (delegate) {
        [delegate fullscreenWebView:view didFailLoadWithError:error];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL) canBecomeFirstResponder 
{
    return YES;
}

@end

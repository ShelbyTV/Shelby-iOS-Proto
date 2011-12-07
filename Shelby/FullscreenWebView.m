//
//  FullscreenWebView.m
//  Shelby
//
//  Created by Mark Johnson on 12/7/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import "FullscreenWebView.h"

@implementation FullscreenWebView

@synthesize delegate;
@synthesize webView;

static NSString *IPHONE_NIB_NAME = @"FullscreenWebView_iPhone";
static NSString *IPAD_NIB_NAME = @"FullscreenWebView_iPad";

+ (FullscreenWebView *)fullscreenWebViewFromNib 
{    
    NSString *nibName;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibName = IPHONE_NIB_NAME;
    } else {
        nibName = IPAD_NIB_NAME;
    }
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
    return [objects objectAtIndex:0];
}

- (IBAction)closeFullscreenWebView:(id)sender
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


@end

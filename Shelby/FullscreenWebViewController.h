//
//  FullscreenWebViewController.h
//  Shelby
//
//  Created by Mark Johnson on 12/7/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FullscreenWebViewController;


@protocol FullscreenWebViewControllerDelegate 
- (void)fullscreenWebViewCloseWasPressed:(id)sender;
- (void)fullscreenWebViewDidFinishLoad:(UIWebView *)webView;
- (void)fullscreenWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
@end

@interface FullscreenWebViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *_webView;
}

@property (assign) id <FullscreenWebViewControllerDelegate> delegate;
@property (nonatomic, readonly) UIWebView *webView;

- (IBAction)closeFullscreenWebViewController:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

// UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)view;
- (void)webView:(UIWebView *)view didFailLoadWithError:(NSError *)error;

@end

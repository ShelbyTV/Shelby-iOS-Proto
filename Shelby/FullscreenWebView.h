//
//  FullscreenWebView.h
//  Shelby
//
//  Created by Mark Johnson on 12/7/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FullscreenWebView;


@protocol FullscreenWebViewDelegate 
- (void)fullscreenWebViewCloseWasPressed:(id)sender;
- (void)fullscreenWebViewDidFinishLoad:(UIWebView *)webView;
- (void)fullscreenWebView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
@end

@interface FullscreenWebView : UIView <UIWebViewDelegate> {}

+ (FullscreenWebView *)fullscreenWebViewFromNib;

@property (assign) id <FullscreenWebViewDelegate> delegate;
@property(nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction)closeFullscreenWebView:(id)sender;

// UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)view;
- (void)webView:(UIWebView *)view didFailLoadWithError:(NSError *)error;

@end

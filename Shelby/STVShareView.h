//
//  STVShareView.h
//  Shelby
//
//  Created by David Kay on 9/25/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STVShareView;

@protocol STVShareViewDelegate 

- (void)shareView:(STVShareView*)shareView sentMessage:(NSString *)message withNetworks:(NSArray *)networks;

@end

@interface STVShareView : UIView {
  IBOutlet UIButton *_twitterButton;
  IBOutlet UIButton *_facebookButton;
  IBOutlet UITextView *_textView;
}

@property (assign) id <STVShareViewDelegate> delegate;

+ (STVShareView *)viewFromNib;

- (IBAction)twitterWasPressed:(id)sender;
- (IBAction)facebookWasPressed:(id)sender;
- (IBAction)sendWasPressed:(id)sender;

@end

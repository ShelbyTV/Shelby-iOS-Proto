//
//  STVUserView.h
//  Shelby
//
//  Created by David Kay on 9/13/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STVUserView;

@protocol STVUserViewDelegate

- (void)userViewWasPressed:(STVUserView *)userView;

@end

/**
 * View for showing the user's name, photo, and social accounts. Primarily used
 * in the top-right of the navigation controller.
 */
@interface STVUserView : UIView {
}


@property (nonatomic, retain) IBOutlet UIImageView *twitter;
@property (nonatomic, retain) IBOutlet UIImageView *facebook;

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, assign) id<STVUserViewDelegate> delegate;

- (IBAction)buttonWasPressed:(id)sender;

@end

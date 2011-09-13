//
//  STVUserView.h
//  Shelby
//
//  Created by David Kay on 9/13/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * View for showing the user's name, photo, and social accounts. Primarily used
 * in the top-right of the navigation controller.
 */
@interface STVUserView : UIView {
}
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *name;

@end

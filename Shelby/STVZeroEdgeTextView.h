//
//  STVZeroEdgeTextView.h
//  Shelby
//
//  Created by David Kay on 10/3/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * TextView subclass. Takes advantage of the fact that UITextView is a subclass
 * of UIScrollView in order to eliminate unwanted scrolling up/down when
 * entering text.
 *
 * http://stackoverflow.com/questions/1178010/how-to-stop-uitextview-from-scrolling-up-when-entering-it
 */
@interface STVZeroEdgeTextView : UITextView

@end

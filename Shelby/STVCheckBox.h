//
//  STVCheckBox.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface STVCheckBox : UIView {
    UIButton  *_button;
    BOOL _isChecked;
    
    UIImage *_checkedImage;
    UIImage *_emptyImage;
}

- (IBAction)buttonWasPressed:(id)sender;

@end

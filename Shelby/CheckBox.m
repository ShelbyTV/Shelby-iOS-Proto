//
//  CheckBox.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "CheckBox.h"

#pragma mark - Private Methods

@interface CheckBox (private)

- (void)setImageForState:(BOOL)isChecked;

@end

@implementation CheckBox (private)

- (void)setImageForState:(BOOL)isChecked {
    UIImage *newImage = (isChecked) ? _checkedImage : _emptyImage;

    [_button setImage: newImage
             forState: UIControlStateNormal];
}

@end

#pragma mark - Main Class

@implementation CheckBox

#pragma mark - Initialization

- (void)initImages {
    _emptyImage = [[UIImage imageNamed: @"CheckboxEmpty"] retain];
    _checkedImage = [[UIImage imageNamed: @"CheckboxChecked"] retain];

    _button = [UIButton buttonWithType: UIButtonTypeCustom];
    [_button addTarget: self
                action: @selector(buttonWasPressed:)
      forControlEvents: UIControlEventTouchUpInside];

    [self addSubview: _button];

    [self setImageForState: NO];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initImages];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // initialise ourselves normally
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initImages];
    }
    return self;
}

#pragma mark - Appearance

- (void)layoutSubviews {
    _button.frame = self.bounds;
}

#pragma mark - UI Callbacks

- (IBAction)buttonWasPressed:(id)sender {
    _isChecked = !_isChecked;
    [self setImageForState: _isChecked];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Cleanup

- (void)dealloc
{
    [super dealloc];
}

@end

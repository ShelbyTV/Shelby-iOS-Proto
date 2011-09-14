//
//  STVUserView.m
//  Shelby
//
//  Created by David Kay on 9/13/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "STVUserView.h"

#define IMAGE_WIDTH 36
#define IMAGE_MARGIN 5

@implementation STVUserView

@synthesize image;
@synthesize name;
@synthesize button;
@synthesize delegate;

- (void)initialize {
    self.image = [[[UIImageView alloc] init] autorelease];
    self.image.image = [UIImage imageNamed: @"Face.png"];

    self.name  = [[[UILabel alloc] init] autorelease];
    self.name.font = [UIFont fontWithName: @"Arial Bold" 
                                     size: 17.0
                                     ];
    self.name.text = @"Name";
    self.name.textColor = [UIColor whiteColor];
    self.name.textAlignment = UITextAlignmentRight;
    self.name.backgroundColor = [UIColor clearColor];

    self.button = [UIButton buttonWithType: UIButtonTypeCustom];
    self.button.showsTouchWhenHighlighted = YES;
    [self.button addTarget: self
                    action: @selector(buttonWasPressed:)
          forControlEvents: UIControlEventTouchUpInside
                    ];

    [self addSubview: self.image];
    [self addSubview: self.name];
    [self addSubview: self.button];

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // initialise ourselves normally
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib {
    LOG(@"[STVUserView awakeFromNib]");
}

- (IBAction)buttonWasPressed:(id)sender {
    LOG(@"[STVUserView buttonWasPressed]");
    if (self.delegate) {
        [self.delegate userViewWasPressed: self];
    }
}

- (void)layoutSubviews {


    self.image.frame = CGRectMake(
        self.bounds.size.width - (IMAGE_WIDTH + IMAGE_MARGIN),
        IMAGE_MARGIN,
        IMAGE_WIDTH,
        IMAGE_WIDTH
        );

    self.name.frame = CGRectMake(
        IMAGE_MARGIN,
        IMAGE_MARGIN,
        self.bounds.size.width - (IMAGE_WIDTH + (2 * IMAGE_MARGIN) + IMAGE_MARGIN),
        21
        );

    self.button.frame = self.bounds;
    LogRect(@"button frame", self.button.frame);
    LogRect(@"bounds", self.bounds);
    [self bringSubviewToFront: self.button];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
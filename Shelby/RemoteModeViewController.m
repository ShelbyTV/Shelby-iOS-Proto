//
//  RemoteModeViewController.m
//  Shelby
//
//  Created by Mark Johnson on 1/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "RemoteModeViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation RemoteModeViewController

@synthesize delegate;

static const float kTapTime = 0.5f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        pinchRecognizer.delaysTouchesBegan = NO;
        
        leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
        leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        leftSwipeRecognizer.delaysTouchesBegan = NO;
        
        rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        rightSwipeRecognizer.delaysTouchesBegan = NO;
        
        upSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
        upSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        upSwipeRecognizer.delaysTouchesBegan = NO;
        
        downSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
        downSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        downSwipeRecognizer.delaysTouchesBegan = NO;
        
        
        leftDoubleSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDoubleLeft:)];
        leftDoubleSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        leftDoubleSwipeRecognizer.numberOfTouchesRequired = 2;
        leftDoubleSwipeRecognizer.delaysTouchesBegan = NO;
        
        rightDoubleSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDoubleRight:)];
        rightDoubleSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        rightDoubleSwipeRecognizer.numberOfTouchesRequired = 2;
        rightDoubleSwipeRecognizer.delaysTouchesBegan = NO;
        
        upDoubleSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDoubleUp:)];
        upDoubleSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        upDoubleSwipeRecognizer.numberOfTouchesRequired = 2;
        upDoubleSwipeRecognizer.delaysTouchesBegan = NO;
        
        downDoubleSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDoubleDown:)];
        downDoubleSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        downDoubleSwipeRecognizer.numberOfTouchesRequired = 2;
        downDoubleSwipeRecognizer.delaysTouchesBegan = NO;

        
        doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.delaysTouchesBegan = NO;
                
        [self.view addGestureRecognizer:pinchRecognizer];
        
        [self.view addGestureRecognizer:leftSwipeRecognizer];
        [self.view addGestureRecognizer:rightSwipeRecognizer];
        [self.view addGestureRecognizer:upSwipeRecognizer];
        [self.view addGestureRecognizer:downSwipeRecognizer];
        
        [self.view addGestureRecognizer:leftDoubleSwipeRecognizer];
        [self.view addGestureRecognizer:rightDoubleSwipeRecognizer];
        [self.view addGestureRecognizer:upDoubleSwipeRecognizer];
        [self.view addGestureRecognizer:downDoubleSwipeRecognizer];
        
        [self.view addGestureRecognizer:doubleTapRecognizer];
    }
    return self;
}

- (void)flashPinchAndClose
{
    alreadyClosing = TRUE;
    
    [UIView animateWithDuration:0.1 animations:^{
        pinchWhite.alpha = 1.0;
    }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3 animations:^{
                             pinchWhite.alpha = 0.0;
                         }                      completion:^(BOOL finished){
                             self.view.hidden = YES;
                             alreadyClosing = FALSE;
                         }];
                     }];
}

- (void)flashImageView:(UIImageView *)imageView
{
    [UIView animateWithDuration:0.1 animations:^{
        imageView.alpha = 1.0;
    }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3 animations:^{
                             imageView.alpha = 0.0;
                         }];
                     }];
}


#pragma mark - Pinch Handling

- (void)pinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    NSLog(@"scale: %.2f velocity: %.2f", gestureRecognizer.scale, gestureRecognizer.velocity);
    
    if (gestureRecognizer.scale < 0.5 && gestureRecognizer.velocity < -1.0 &&
        !alreadyClosing) {
        [self flashPinchAndClose];
    }
}

#pragma mark - Swipe Handling

- (void)swipeLeft:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeLeft");
    
    if (delegate)
    {
        [self flashImageView:swipeLeftWhite];
        [delegate remoteModeNextVideo];
    }
}

- (void)swipeRight:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeRight");
    
    if (delegate)
    {
        [self flashImageView:swipeRightWhite];
        [delegate remoteModePreviousVideo];
    }
}

- (void)swipeUp:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeUp");
    
    if (delegate)
    {
        [self flashImageView:swipeUpWhite];
        [delegate remoteModeLikeVideo];
    }
}

- (void)swipeDown:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeDown");
    
    if (delegate)
    {
        [self flashImageView:swipeDownWhite];
        [delegate remoteModeWatchLaterVideo];
    }
}

#pragma mark - 2-Finger Swipe Handling

- (void)swipeDoubleLeft:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeDoubleLeft");
    
    if (delegate)
    {
        [self flashImageView:doubleSwipeLeftWhite];
        [delegate remoteModeScanBackward];
    }
}

- (void)swipeDoubleRight:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeDoubleRight");
    
    if (delegate)
    {
        [self flashImageView:doubleSwipeRightWhite];
        [delegate remoteModeScanForward];
    }
}

- (void)swipeDoubleUp:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeDoubleUp");
    
    if (delegate)
    {
        [self flashImageView:doubleSwipeUpWhite];
        [delegate remoteModePreviousChannel];
    }
}

- (void)swipeDoubleDown:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeDoubleDown");
    
    if (delegate)
    {
        [self flashImageView:doubleSwipeDownWhite];
        [delegate remoteModeNextChannel];
    }
}

#pragma mark - Tap Handling

- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"doubleTap");
    
    if (delegate)
    {
        [self flashImageView:doubleTapWhite];
        [delegate remoteModeTogglePlayPause];
    }
}

#pragma mark - Other Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    
    _lastTouchesBegan = CACurrentMediaTime();
    if (delegate)
    {
        [delegate remoteModeShowInfo];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // nothing to do here
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
    
    if (delegate)
    {
        if (CACurrentMediaTime() - _lastTouchesBegan < kTapTime)
        {
            [self flashImageView:tapWhite];
            [delegate remoteModeHideInfo];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end

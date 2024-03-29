//
//  RemoteModeViewController.m
//  Shelby
//
//  Created by Mark Johnson on 1/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "RemoteModeViewController.h"
#import "RemoteModeHelpTableViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation RemoteModeViewController

@synthesize delegate;

static const float kTapTime = 0.5f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        pinchRecognizer.delaysTouchesBegan = YES;
        
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
        doubleTapRecognizer.numberOfTapsRequired = 1;
        doubleTapRecognizer.numberOfTouchesRequired = 2;
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
        
        helpController = [[RemoteModeHelpTableViewController alloc] init];
        helpController.view.frame = helpTableContainerView.bounds;
        
        [(UITableView *)helpController.view setSeparatorColor:[UIColor darkGrayColor]];
        [(UITableView *)helpController.view setBackgroundColor:[UIColor blackColor]];
        
        [helpTableContainerView addSubview:helpController.view];
    }
    return self;
}

- (void)flashPinchAndClose
{
    alreadyPinching = TRUE;
    [self hideRemoteMode];
    
//    [UIView animateWithDuration:0.1 animations:^{
//        pinchWhite.alpha = 1.0;
//    }
//                     completion:^(BOOL finished){
//                         [UIView animateWithDuration:0.3 animations:^{
//                             pinchWhite.alpha = 0.0;
//                         }                      completion:^(BOOL finished){
//                             self.view.hidden = YES;
//                             alreadyPinching = FALSE;
//                         }];
//                     }];
}

- (void)flashSpreadAndShowSharing
{
//    alreadySpreading = TRUE;
    
    if (delegate) {
        [delegate remoteModeShowSharing];
    }

//    [UIView animateWithDuration:0.1 animations:^{
//        spreadWhite.alpha = 1.0;
//    }
//                     completion:^(BOOL finished){
//                         [UIView animateWithDuration:0.3 animations:^{
//                             spreadWhite.alpha = 0.0;
//                         }                      completion:^(BOOL finished){
//                             if (delegate) {
//                                 [delegate remoteModeShowSharing];
//                             }
//                             alreadySpreading = FALSE;
//                         }];
//                     }];
}

- (void)flashGestureWithImage:(UIImage *)image withCommand:(NSString *)command
{
    [UIView animateWithDuration:0.1 
                     animations:^{
                         
                         lastGestureImageView.image = image;
                         lastGestureCommandLabel.text = command;
                         lastGestureContainerView.alpha = 1.0;
                     
                     }
                     completion:^(BOOL finished) {
            
                         [UIView animateWithDuration:1.5 
                                               delay:0.1
                                             options:UIViewAnimationCurveEaseInOut 
                                          animations:^{lastGestureContainerView.alpha = 0.0;}
                                          completion:^(BOOL finished){}
                          ];
                     }
     ];
}


#pragma mark - Pinch Handling

- (void)pinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"scale: %.2f velocity: %.2f", gestureRecognizer.scale, gestureRecognizer.velocity);
    
    if (gestureRecognizer.scale < 0.5 && gestureRecognizer.velocity < -1.0 &&
        !alreadyPinching) {
        [self flashPinchAndClose];
    } else if (gestureRecognizer.scale > 2 && gestureRecognizer.velocity > 1.0 && !alreadySpreading) {
        [self flashSpreadAndShowSharing];
    }
}

#pragma mark - Swipe Handling

- (void)swipeLeft:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeLeft");
    
    if (delegate)
    {
        [self flashGestureWithImage:[UIImage imageNamed:@"oneFingerSwipeLeft"] withCommand:@"NEXT VIDEO"];
        [delegate remoteModeNextVideo];
    }
}

- (void)swipeRight:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeRight");
    
    if (delegate)
    {
        [self flashGestureWithImage:[UIImage imageNamed:@"oneFingerSwipeRight"] withCommand:@"PREVIOUS VIDEO"];
        [delegate remoteModePreviousVideo];
    }
}

- (void)swipeUp:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeUp");
    
    if (delegate)
    {
        [self flashGestureWithImage:[UIImage imageNamed:@"oneFingerSwipeUp"] withCommand:@"TOGGLE FAVORITE"];
        [delegate remoteModeLikeVideo];
    }
}

- (void)swipeDown:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeDown");
    
    if (delegate)
    {
        [self flashGestureWithImage:[UIImage imageNamed:@"oneFingerSwipeDown"] withCommand:@"TOGGLE WATCH LATER"];
        [delegate remoteModeWatchLaterVideo];
    }
}

#pragma mark - 2-Finger Swipe Handling

- (void)swipeDoubleLeft:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeDoubleLeft");
    
    if (delegate)
    {
        [self flashGestureWithImage:[UIImage imageNamed:@"twoFingerSwipeLeft"] withCommand:@"SCAN BACK"];
        [delegate remoteModeScanBackward];
    }
}

- (void)swipeDoubleRight:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"swipeDoubleRight");
    
    if (delegate)
    {
        [self flashGestureWithImage:[UIImage imageNamed:@"twoFingerSwipeRight"] withCommand:@"SCAN FORWARD"];
        [delegate remoteModeScanForward];
    }
}

- (void)swipeDoubleUp:(UIGestureRecognizer *)gestureRecognizer
{
//    NSLog(@"swipeDoubleUp");
//    
//    if (delegate)
//    {
//        [self flashGestureWithImage:[UIImage imageNamed:@"twoFingerSwipeUp"] withCommand:@"PREVIOUS CHANNEL"];
//        [delegate remoteModePreviousChannel];
//    }
}

- (void)swipeDoubleDown:(UIGestureRecognizer *)gestureRecognizer
{
//    NSLog(@"swipeDoubleDown");
//    
//    if (delegate)
//    {
//        [self flashGestureWithImage:[UIImage imageNamed:@"twoFingerSwipeDown"] withCommand:@"NEXT CHANNEL"];
//        [delegate remoteModeNextChannel];
//    }
}

#pragma mark - Tap Handling

- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"doubleTap");
    
    if (delegate)
    {
        [self flashGestureWithImage:[UIImage imageNamed:@"twoFingerTap"] withCommand:@"PLAY/PAUSE"];
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
            [self flashGestureWithImage:[UIImage imageNamed:@"oneFingerTap"] withCommand:@"SHOW/HIDE CONTEXT"];
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [stripesView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LoginBackgroundStripes_iPad"]]];
    } else {
        [stripesView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LoginBackgroundStripes_iPhone"]]];
    }
    [stripesView setOpaque:NO];
    [[stripesView layer] setOpaque:NO]; // hack needed for transparent backgrounds on iOS < 5
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

- (IBAction)helpPressed:(id)sender
{
    [needHelpImage.layer removeAllAnimations];
    
    if (needHelpImage.alpha != 0.0) {
        
        [UIView animateWithDuration:0.2 
                              delay:0.0 
                            options:UIViewAnimationCurveEaseInOut 
                         animations:^(void) {needHelpImage.alpha = 0.0;} 
                         completion:^(BOOL finished) {}];
        
    }
         
    helpButton.selected = !helpButton.selected;
    if (helpButton.selected) {
        
        [UIView animateWithDuration:0.2 
                              delay:0.0 
                            options:UIViewAnimationCurveEaseInOut 
                         animations:^(void) {
                         
                             CGRect temp = helpContainerView.frame;
                             
                             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                 temp.origin.x -= temp.size.width;
                                 
                                 CGRect temp2 = lastGestureContainerContainerView.frame;
                                 temp2.size.width -= temp.size.width;
                                 lastGestureContainerContainerView.frame = temp2;
                                 
                                 helpButton.alpha = 0.0;
                                 
                             } else {
                                 temp.origin.y -= temp.size.height;
                             }
                             
                             helpContainerView.frame = temp;
                         
                         } 
                         completion:^(BOOL finished) {}];
        
    } else {
        
        [UIView animateWithDuration:0.2 
                              delay:0.0 
                            options:UIViewAnimationCurveEaseInOut 
                         animations:^(void) {
                             
                             CGRect temp = helpContainerView.frame;
                             
                             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                 temp.origin.x += temp.size.width;
                                 
                                 CGRect temp2 = lastGestureContainerContainerView.frame;
                                 temp2.size.width += temp.size.width;
                                 lastGestureContainerContainerView.frame = temp2;
                                 
                                 helpButton.alpha = 1.0;
                                 
                             } else {
                                 temp.origin.y += temp.size.height;
                             }
                             
                             helpContainerView.frame = temp;
                             
                         } 
                         completion:^(BOOL finished) {}];
    }
}

- (void)showRemoteMode
{
    self.view.hidden = FALSE;
    alreadyPinching = FALSE; 
    alreadySpreading = FALSE;
    
    [needHelpImage.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.5
                          delay:1.0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^(void) {needHelpImage.alpha = 1.0;}
                     completion:^(BOOL finished) {
         
                         [UIView animateWithDuration:0.5 
                                               delay:6.0 
                                             options:UIViewAnimationCurveEaseInOut 
                                          animations:^(void) {needHelpImage.alpha = 0.0;} 
                                          completion:^(BOOL finished) {}
                          ];
                         
                     }
     ];
}

- (void)hideRemoteMode
{
    if (helpButton.selected) {
        helpButton.selected = FALSE;
        
        [UIView animateWithDuration:0.2 
                              delay:0.0 
                            options:UIViewAnimationCurveEaseInOut 
                         animations:^(void) {
                             
                             CGRect temp = helpContainerView.frame;
                             
                             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                 temp.origin.x += temp.size.width;
                                 
                                 CGRect temp2 = lastGestureContainerContainerView.frame;
                                 temp2.size.width += temp.size.width;
                                 lastGestureContainerContainerView.frame = temp2;
                                 
                                 helpButton.alpha = 1.0;
                                 
                             } else {
                                 temp.origin.y += temp.size.height;
                             }
                             
                             helpContainerView.frame = temp;
                             
                         } 
                         completion:^(BOOL finished) {
                         
                             [UIView animateWithDuration:0.0 
                                                   delay:0.5
                                                 options:UIViewAnimationCurveEaseInOut 
                                              animations:^(void) {
                                 
                                                  self.view.hidden = TRUE;  
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                              
                                                  alreadyPinching = FALSE; 
                                                  
                                              }
                              ];
                         
                         }];
    } else {
    
        self.view.hidden = TRUE;
    
    }
}


































@end

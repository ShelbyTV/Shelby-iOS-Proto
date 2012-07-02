//
//  GTViewController.m
//  Shelby
//
//  Created by Arthur Ariel Sabintsev on 6/29/12.
//
//

#import "GTViewController.h"

@interface GTViewController ()

@end

@implementation GTViewController
@synthesize messageLabel = _messageLabel;
@synthesize messageButton = _messageButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        
        [self.messageLabel setFont:[UIFont fontWithName:@"Ubuntu-Bold" size:self.messageLabel.font.pointSize]];
        
    }
    
    return self;
}

- (void)viewDidUnload
{
    self.messageLabel = nil; [self.messageLabel release];
    self.messageButton = nil; [self.messageButton release];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:35.0f/255.0f green:37.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    
    [self.messageLabel setTextAlignment:UITextAlignmentLeft];
    [self.messageLabel setTextColor:[UIColor whiteColor]];
    [self.messageLabel setText:@"A new Shelby app is coming soon, loaded with exciting new features.\n\nWe've shut down this version to focus on delivering the rebuilt app to you ASAP.\n\nWe apologize for the inconvenience, but it'll totally be worth it."];
    [self.messageLabel setNeedsDisplay];
}

- (IBAction)launchShelbyBlog:(id)sender
{
    
    
    if ( sender == self.messageButton) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://shelby.tv/blog"]];

    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
     
         return (interfaceOrientation == UIInterfaceOrientationPortrait);
         
     } else if ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) && (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ) {
         
         return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
     
    } else if ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) && (interfaceOrientation == UIInterfaceOrientationLandscapeRight) ) {
    
        return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
   
    } else { 
        
        return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
    }
    
}

@end

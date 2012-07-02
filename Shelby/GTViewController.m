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
@synthesize importantLabel = _importantLabel;
@synthesize blogButton = _blogButton;

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
    self.importantLabel = nil; [self.importantLabel release];
    self.blogButton = nil; [self.blogButton release];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:35.0f/255.0f green:37.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    
    [self.messageLabel setTextAlignment:UITextAlignmentLeft];
    [self.messageLabel setTextColor:[UIColor whiteColor]];
    [self.messageLabel setText:@"A new Shelby app is coming soon!\n\nWe've shut down this version to devote ourselves entirely to finishing the new app, and delivering it to you quickly. We apologize for the inconvenience."];
    [self.importantLabel setText:@"IMPORTANT: You don’t have to uninstall this version. The new app will be deployed as an update."];
    
}

- (IBAction)launchShelbyBlog:(id)sender
{
    
    
    if ( sender == self.blogButton) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://shelby.tv/blog/post/26350448496/shelby-gt-ios"]];

    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    switch ( [[UIDevice currentDevice] userInterfaceIdiom])  {
            
        case UIUserInterfaceIdiomPhone:
            return interfaceOrientation == UIInterfaceOrientationPortrait;
            break;
            
        case UIUserInterfaceIdiomPad:
            
            if ( interfaceOrientation == UIInterfaceOrientationLandscapeRight ) {
                
                return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
                
            } else if ( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
                
                return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
                
            } else {
                
               return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
                
            }
            
            break;
            
        default:
            break;
    }
    
}

@end

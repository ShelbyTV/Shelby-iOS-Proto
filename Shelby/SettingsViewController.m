//
//  SettingsViewController.m
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "SettingsViewController.h"
#import "UICustomSwitch.h"
#import "ShelbyApp.h"
#import "NetworkManager.h"
#import "User.h"

@implementation SettingsViewController

@synthesize delegate;
@synthesize contactSwitch;
@synthesize whereToSwitch;

+ (SettingsViewController *)viewController {
    NSString *nibName;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //nibName = @"SettingsViewController_iPad";
        nibName = @"SettingsViewController_iPad";
	} else {
        nibName = @"SettingsViewController_iPhone";
	}
    return [[[SettingsViewController alloc] initWithNibName: nibName
                                                     bundle: nil] autorelease];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Settings";

        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutWasPressed:)];
        self.navigationItem.rightBarButtonItem = logoutButton;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //CGRect frame = self.contactSwitch.frame;
    
    //UICustomSwitch *newSwitch = [UICustomSwitch switchWithLeftText:@"Weekly"
    //                                                      andRight:@"Monthly"];
    //newSwitch.frame = frame;
    ////[self.view removeSubview: self.contactSwitch];
    //[self.view addSubview: newSwitch];
    //self.contactSwitch = newSwitch;

    self.contactSwitch.leftLabel.text  = @"Weekly";
    self.contactSwitch.rightLabel.text = @"Monthly";
    
    //[self.contactSwitch setTintColor: [UIColor redColor]];
    [self.contactSwitch setTintColor: [UIColor 
        colorWithRed: 170 / 255.0
               green: 72  / 255.0
                blue: 192 / 255.0
               alpha: 1.0]];
    
    self.whereToSwitch.leftLabel.text  = @"Twitter";
    self.whereToSwitch.rightLabel.text = @"Email";

    //self.contactSwitch.leftLabel.frame = frame;
    //self.contactSwitch.rightLabel.frame = frame;
        
    // Init user info.
    User *user = [ShelbyApp sharedApp].networkManager.user;
    _nameField.text = user.name;
    _nicknameField.text = user.nickname;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI Callbacks

- (IBAction)logoutWasPressed:(id)sender {
    [[ShelbyApp sharedApp].networkManager logout];
}

- (IBAction)doneWasPressed:(id)sender {
    if (self.delegate) {
        [self.delegate settingsViewControllerDone: self];
    }
}

@end

//
//  GTViewController.h
//  Shelby
//
//  Created by Arthur Ariel Sabintsev on 6/29/12.
//
//

#import <UIKit/UIKit.h>

@interface GTViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;

- (IBAction)launchShelbyBlog:(id)sender;

@end
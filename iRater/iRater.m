//
//  iRater.m
//  iRater
//
//  Created by Arthur on 4/15/12.
//  Copyright (c) 2012 ArtSabintsev. All rights reserved.
//

#import "iRater.h"

#pragma mark - Private Macros

/* CUSTOMIZE */
#define iRaterEventsNeededForTrigger        10                                                          // Number (integer) of events needed for ratings reminder alert
#define iRaterEventsNeededForRetrigger      10                                                          // Number (integer) of events needed for ratings reminder alert to retrigger if user chose 'Remind Me Later' option
#define iRaterDebugMode                     NO                                                          // Set YES to show the alert every time. Set NO when shipping to App Store.

// App Information
#define iRaterAppleID                       @"467849037"                                                // Apple ID for your app

/* DO NOT CUSTOMIZE */
// NSUserDefaults String Identifiers
#define iRaterPreviouslyLaunched            @"PreviouslyLaunched" 
#define iRaterTrackingDisabled              @"trackingDisabled"
#define iRaterDidChooseRemindMeLater        @"DidChooseRemindMeLater"                                        
#define iRaterCounter                       @"Counter"                                                  
#define iRaterVersion                       @"Version"                                                  
    
// App Information
#define iRaterAppName                       [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey]              
#define iRaterAppVersion                    [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]           
#define iRaterAppStoreLink                  [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", iRaterAppleID]

// UIAlertView String Identifiers
#define iRaterAlertTitle                    [NSString stringWithFormat:@"Rate %@", iRaterAppName]       
#define iRaterAlertMessage                  [NSString stringWithFormat:@"Thanks for being an active %@ user! Please take a moment and tell us how we're doing!", iRaterAppName]
#define iRaterNoMessage                     @"No, Thanks!"                                             
#define iRaterYesMessage                    [NSString stringWithFormat:@"Yes, I'll rate %@", iRaterAppName]
#define iRaterRemindMeLaterMessage          @"Remind Me Later"                                          

#pragma mark - Private Declarations
@interface iRater () <UIAlertViewDelegate>

@property (unsafe_unretained, nonatomic)    BOOL        previouslyLaunched;     // Used to initialize default values on first launch
@property (unsafe_unretained, nonatomic)    BOOL        didChooseRemindMeLater; // Flag used to remind user to rate app at a later time (when users selects 'Remind Me Later' in alertView)
@property (unsafe_unretained, nonatomic)    BOOL        trackingDisabled;       // Flag used to enable/disable tracking and alertView display (when user selects 'NO' in alertView)
@property (unsafe_unretained, nonatomic)    NSUInteger  counter;                // Keeps track of number of events triggered
@property (copy, nonatomic)                 NSString    *version;               // Version of your app

- (void)defaultValues;
- (void)checkVersion;
- (void)checkNumberOfEventsTriggered:(NSUInteger)counter;
- (void)enableRemindMeLater;
- (void)disableTracking;
- (UIAlertView*)initializeAlertView;

@end

@implementation iRater

static iRater *sharedInstance = nil;

#pragma mark - Singleton Methods
+ (iRater*)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

- (id)init
{
    
    if ( self = [super init] ) {
        
        // Set Default Variables
        if ( ![self previouslyLaunched] ) {
            
            // Set default values on first launch of application (after installation)
            [self defaultValues];
            
        }
        
    }
    
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark - Public Methods
- (void)recordEvent
{
    // Check current version of app and perform reset if necessary
    [self checkVersion];
    
    // Increment Counter (saves to NSUserDefaults in custom setter)
    self.counter++;
}

#pragma mark - Private Methods
- (void)defaultValues
{
    self.previouslyLaunched = YES;
    self.didChooseRemindMeLater = NO;
    self.trackingDisabled = NO;
    self.counter = 0;
    self.version = iRaterAppVersion;
}

- (void)checkVersion
{
    if ( ![self.version isEqualToString:iRaterAppVersion] ) {       // If installed version doesn't match version saved in defaults (e.g., newer version installed)
        
        // Reset default values on version change
        [self defaultValues];
        
    }
}

- (void)checkNumberOfEventsTriggered:(NSUInteger)counter
{
    
    // Output current number of events triggered
    NSLog(@"[%@: %d Events Triggered]", NSStringFromClass([self class]), counter);
    
    // Shows alert if conditions are satisfied    
    switch (iRaterDebugMode) {
            
        case NO:                                                        // If 'Debug Mode' is IS NOT enabled
            
            if ( ![self didChooseRemindMeLater] ) {                     // If 'Remind Me Later' IS NOT enabled
                
                if ( counter == iRaterEventsNeededForTrigger ) {    
                    
                    UIAlertView *alertView = [self initializeAlertView];
                    [alertView show];
                    
                }
                
            } else if ( [self didChooseRemindMeLater] ) {               // If 'Remind Me Later' IS enabled
                
                if ( counter == iRaterEventsNeededForRetrigger ) {
                    
                    UIAlertView *alertView = [self initializeAlertView];
                    [alertView show];
                    
                }
                
            } break;
            
        case YES:{                                                      // If 'Debug Mode IS enabled
        
            UIAlertView *alertView = [self initializeAlertView];
            [alertView show];
            
            } break;
        default:
            break;
    }
}

- (void)disableTracking
{
    [self setTrackingDisabled:YES];
    self.counter = 0;
}

- (void)enableRemindMeLater
{
    self.didChooseRemindMeLater = YES;
    self.counter = 0;
}

- (UIAlertView*)initializeAlertView
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:iRaterAlertTitle 
                                                         message:iRaterAlertMessage 
                                                        delegate:self 
                                               cancelButtonTitle:iRaterNoMessage 
                                               otherButtonTitles:iRaterYesMessage, iRaterRemindMeLaterMessage, nil] autorelease];
    
    return alertView;
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    switch (buttonIndex) {
        case 0:         // No
            [self disableTracking];
            break;
        case 1:{        // Yes
                
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iRaterAppStoreLink]];   // Show App Store review page
            [self disableTracking];                                                                 // Disable tracking
            
            }break;
        case 2:         // Remind Me Later
            [self enableRemindMeLater];
            break;
        default:
            break;
    }
    
}

#pragma mark - Accessor Methods that utilize NSUserDefaults
// previouslyLaunched
- (void)setPreviouslyLaunched:(BOOL)previouslyLaunched
{
    [[NSUserDefaults standardUserDefaults] setBool:previouslyLaunched forKey:iRaterPreviouslyLaunched];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)previouslyLaunched
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:iRaterPreviouslyLaunched];
}

// trackingDisabled
- (void)setTrackingDisabled:(BOOL)trackingDisabled
{
    [[NSUserDefaults standardUserDefaults] setBool:trackingDisabled forKey:iRaterTrackingDisabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

- (BOOL)trackingDisabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:iRaterTrackingDisabled];
}

// didChooseRemindMeLater
- (void)setDidChooseRemindMeLater:(BOOL)didChooseRemindMeLater
{
    [[NSUserDefaults standardUserDefaults] setBool:didChooseRemindMeLater forKey:iRaterDidChooseRemindMeLater];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)didChooseRemindMeLater
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:iRaterDidChooseRemindMeLater];
}

// counter
- (void)setCounter:(NSUInteger)counter
{
    [[NSUserDefaults standardUserDefaults] setInteger:counter forKey:iRaterCounter];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /*
     If user has not previously clicked 'No' on an alertView, 
     perform check on total number of events triggered, 
     and show alert if conditions within 'checkNumberOfEventsTriggered:' are satisfied.
    */
     if ( ![self trackingDisabled] ) [self checkNumberOfEventsTriggered:counter];
}

- (NSUInteger)counter
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:iRaterCounter];
}

// version
- (void)setVersion:(NSString *)version
{
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:iRaterVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)version
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:iRaterVersion];
}

@end
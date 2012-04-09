//
//  ShelbyAppDelegate.h
//  Shelby
//
//  Created by Mark Johnson on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class LoginViewController;
@class NavigationViewController;
@class ShelbyWindow;

@interface ShelbyAppDelegate : NSObject <UIApplicationDelegate> {
    LoginViewController *loginViewController;
    NavigationViewController *navigationViewController;
    ShelbyWindow *shelbyWindow;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)raiseShelbyWindow;
- (void)lowerShelbyWindow;

@end

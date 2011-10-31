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

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)clearWebViewAnimations;
- (void)resetShelbyWindowRotation;

@end

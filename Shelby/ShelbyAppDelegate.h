//
//  ShelbyAppDelegate.h
//  Shelby
//
//  Created by Mark Johnson on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

// Third Party Libraries (for use in sub-classes)
#import <Crashlytics/Crashlytics.h>
#import "Appirater.h"

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
- (void)raiseShelbyWindow;
- (void)lowerShelbyWindow;

@end


@protocol ThirdPartyDelegate <NSObject>
- (void)initializeThirdPartyLibraries; // Used in subclasses (_iPhone, _iPad)
@end

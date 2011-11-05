//
//  ShelbyAppDelegate.m
//  Shelby
//
//  Created by Mark Johnson on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShelbyAppDelegate.h"
#import "URLParser.h"
#import "ShelbyApp.h"
#import "LoginHelper.h"
#import "NavigationViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ShelbyWindow.h"

@implementation ShelbyAppDelegate


@synthesize window=_window;

@synthesize managedObjectContext=__managedObjectContext;

@synthesize managedObjectModel=__managedObjectModel;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  //[super application: application didFinishLaunchingWithOptions: launchOptions];
  // Make sure the singleton is initialized.
  [ShelbyApp sharedApp];

  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  NSLog(@"Received URL: %@", url);
  if ([[url scheme] isEqualToString:@"shelby"]) {
    NSLog(@"Received shelby URL");
    // Example:
    // shelby://ios.shelby.tv/auth?oauth_token=WuhQpEQuyPaS1EczFnfRBA7ThXCwWerX3rhECBIz&oauth_verifier=NPkCVIlxYXYiBYYfGsB6

    URLParser *parser = [[[URLParser alloc] initWithURLString: [url absoluteString]] autorelease];

    NSString *oauthVerifier = [parser valueForVariable: @"oauth_verifier"];

    LOG(@"oauthToken: %@", [parser valueForVariable: @"oauth_token"]);
    LOG(@"oauthVerifier: %@", oauthVerifier);

    // If we're coming from oAuth, capture the incoming verifier.
    LoginHelper *loginHelper = [ShelbyApp sharedApp].loginHelper;
    [loginHelper verifierReturnedFromAuth:oauthVerifier];

    return YES;
  }
  return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSLog(@"HERE!");
        NSLog(@"rootViewController: %@", [UIApplication sharedApplication].keyWindow.rootViewController);
        [(NavigationViewController *)[UIApplication sharedApplication].keyWindow.rootViewController pauseCurrentVideo];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSLog(@"HERE2!");
        NSLog(@"rootViewController: %@", [UIApplication sharedApplication].keyWindow.rootViewController);
        [(NavigationViewController *)[UIApplication sharedApplication].keyWindow.rootViewController pauseCurrentVideo];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */

    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
    
    // make sure we fetch new broadcasts as least once a day. should prevent video link timeouts...
    if ([[ShelbyApp sharedApp].loginHelper loggedIn] && NOT_NULL([ShelbyApp sharedApp].loginHelper.lastFetchBroadcasts)) {
        NSTimeInterval diff = abs([[ShelbyApp sharedApp].loginHelper.lastFetchBroadcasts timeIntervalSinceNow]);
        NSInteger days = floor(diff / 86400.0);
        if (days >= 1) {
            [[ShelbyApp sharedApp].loginHelper fetchBroadcasts];
        }
    }
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (setCategoryError) { /* should really handle the error condition */ }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            LOG(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        [__managedObjectContext setUndoManager:nil];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Shelby" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Shelby.sqlite"];

    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        // just delete our datastore if there's a conflict. user can just log in again, no big deal.
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        // now try again. If we don't get it this time, there's actually a problem.
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            LOG(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (UINavigationBar *)findNavigationBarInView:(UIView *)view
{
    UINavigationBar *button = nil;
    
    if ([view isKindOfClass:[UINavigationBar class]]) {
        NSLog(@"Found Navigation Bar!");
        return (UINavigationBar *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findNavigationBarInView:subview];
            if (button) return button;
        }
    }
    
    return button;
}

- (void)removeAllAnimationsInView:(UIView *)view inWindow:(UIWindow *)window
{
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            [self removeAllAnimationsInView:subview inWindow:window];
        }
    }
    
    if (view.layer.sublayers && [view.layer.sublayers count] > 0) {
        for (CALayer *layer in [[view.layer.sublayers copy] autorelease]) {
            for (NSString *animationKey in layer.animationKeys) {
                CAAnimation *animation = [layer animationForKey:animationKey];
                NSLog(@"animationDelegate = %@", animation.delegate);
            }
            [layer removeAllAnimations];
        }
    }
    
    for (NSString *animationKey in view.layer.animationKeys) {
        CAAnimation *animation = [view.layer animationForKey:animationKey];
        NSLog(@"animationDelegate = %@", animation.delegate);
    }
    [view.layer removeAllAnimations];

}

- (void)clearWebViewAnimations
{   
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
                
        if (window == shelbyWindow || window == self.window) {
            continue;
        }
        
        [self removeAllAnimationsInView:window inWindow:window];
    }
}

- (void)resetShelbyWindowRotation
{
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"e",@"n",@"d",@"D",@"i",@"s",@"a",@"b",@"l",@"i",@"n",@"g",@"I",@"n",@"t",@"e",@"r",@"f",@"a",@"c",@"e",@"A",@"u",@"t",@"o",@"r",@"o",@"t",@"a",@"t",@"i",@"o",@"n"]);
    [shelbyWindow performSelector:sel];
}

- (void)raiseShelbyWindow
{
    shelbyWindow.windowLevel = UIWindowLevelStatusBar;
}

- (void)lowerShelbyWindow
{
    shelbyWindow.windowLevel = UIWindowLevelNormal;
}

- (BOOL) correctKeyWindow
{
    return [UIApplication sharedApplication].keyWindow == shelbyWindow;
}

@end

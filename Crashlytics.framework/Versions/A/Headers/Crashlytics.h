//
//  Crashlytics.h
//  Crashlytics
//
//  Created by Jeff Seibert on 3/5/11.
//  Copyright 2012 Crashlytics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Crashlytics : NSObject {
	NSString *_apiKey;
	NSString *_dataDirectory;
	NSString *_bundleIdentifier;
	BOOL _installed;
	NSMutableDictionary *_customAttributes;
	id _user;
	NSInteger _sendButtonIndex;
	NSInteger _alwaysSendButtonIndex;
}

@property (readonly) NSString *apiKey;
@property (readonly) NSString *version;
@property (assign) BOOL debugMode;

/**
 *
 * The recommended way to install Crashlytics into your application is to place a call
 * to +startWithAPIKey: in your -application:didFinishLaunchingWithOptions: method.
 *
 * This delay defaults to 1 second in order to generally give the application time to 
 * fully finish launching.
 *
 **/
+ (Crashlytics *)startWithAPIKey:(NSString *)apiKey;
+ (Crashlytics *)startWithAPIKey:(NSString *)apiKey afterDelay:(NSTimeInterval)delay;

/**
 *
 * Access the singleton Crashlytics instance.
 *
 **/
+ (Crashlytics *)sharedInstance;

/**
 *
 * The easiest way to cause a crash - great for testing!
 *
 **/
- (void)crash;

@end
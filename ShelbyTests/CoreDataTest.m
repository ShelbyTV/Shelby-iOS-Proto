//
//  CoreDataTest.m
//  Shelby
//
//  Created by David Kay on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTest.h"
#import "LoginHelper.h"

@implementation CoreDataTest

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void)testAppDelegate {

    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");

}

#else                           // all code under test must be linked into the Unit Test bundle

- (void)testMath {

    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );

}

#endif

- (void)setUp
{
    model = [[NSManagedObjectModel mergedModelFromBundles: nil] retain];
    NSLog(@"model: %@", model);
    coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
    store = [coord addPersistentStoreWithType: NSInMemoryStoreType
                                configuration: nil
                                          URL: nil
                                      options: nil
                                        error: NULL];
    ctx = [[NSManagedObjectContext alloc] init];
    [ctx setPersistentStoreCoordinator: coord];
}

- (void)tearDown
{
    [ctx release];
    ctx = nil;
    NSError *error = nil;
    STAssertTrue([coord removePersistentStore: store error: &error],
                 @"couldn't remove persistent store: %@", error);
    store = nil;
    [coord release];
    coord = nil;
    [model release];
    model = nil;
}

- (void)testThatEnvironmentWorks
{
    STAssertNotNil(store, @"no persistent store");
}

- (void)testStoreUser {
    NSDictionary *sampleDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"David Kay" , @"name"       ,
        @"DavidYKay" , @"nickname"   ,
        @"image.jpg" , @"user_image" ,
        @"1234"      , @"_id"        ,
        nil];

    LoginHelper *loginHelper = [[[LoginHelper alloc] initWithContext: ctx] autorelease];
    [loginHelper storeUserWithDictionary: sampleDict];
    NSManagedObject * user = [loginHelper retrieveUser];

    STAssertNotNil(user, @"User was nil!");
    // Make sure that our data persisted.
    NSString *before;
    NSString *after;
    before = [sampleDict objectForKey: @"name"];
    after = [user valueForKey: @"name"];
    STAssertTrue(
            [before isEqualToString: after], @"Before: %@ After: %@", before, after
            );
}

- (void)testStoreChannels {

    NSDictionary *sampleChannel1 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"4e385abdf6db24106c000004"     , @"_id"        ,
        @"2011-08-02T20:14:53.000Z"     , @"created_at" ,
        @"2011-08-02T20:14:53.000Z"     , @"updated_at" ,
        @"The David Y. Kay Broadcast"   , @"name"       ,
        [NSNumber numberWithInteger: 1] , @"public"     ,
        @"4e385abdf6db24106c000001"     , @"user_id"    ,
    nil];
    NSDictionary *sampleChannel2 = [NSDictionary dictionaryWithObjectsAndKeys:
          @"4e385abdf6db24106c000006"     , @"_id"        ,
          @"2011-08-02T20:14:53.000Z"     , @"created_at" ,
          @"Watch Later"                  , @"name"       ,
          [NSNumber numberWithInteger: 0] , @"public"     ,
          @"2011-08-02T20:14:53.000Z"     , @"updated_at" ,
          @"4e385abdf6db24106c000001"     , @"user_id"    ,
    nil];

    NSArray *sampleChannels = [NSArray arrayWithObjects:
        sampleChannel1,
        sampleChannel2,
        nil];

    LoginHelper *loginHelper = [[[LoginHelper alloc] initWithContext: ctx] autorelease];
    [loginHelper storeChannelsWithArray: sampleChannels];
    NSArray *channels = [loginHelper retrieveChannels];
    STAssertNotNil(channels, @"Channels was nil!");
    STAssertTrue([channels count] == 2, @"Channels count was: %d.", [channels count]);

    //NSManagedObject * user = [loginHelper retrieveUser];
    //STAssertNotNil(user, @"User was nil!");
    //// Make sure that our data persisted.
    //NSString *before;
    //NSString *after;
    //before = [sampleDict objectForKey: @"name"];
    //after = [user valueForKey: @"name"];
    //STAssertTrue(
    //        [before isEqualToString: after], @"Before: %@ After: %@", before, after
    //        );

}

//- (void)testStoreBroadcasts {
//}

@end

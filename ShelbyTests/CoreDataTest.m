//
//  CoreDataTest.m
//  Shelby
//
//  Created by David Kay on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataTest.h"
#import "LoginHelper.h"
#import "Channel.h"
#import "User.h"

@implementation CoreDataTest

#pragma mark - Set Up & Tear Down

- (void)setUp {
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

- (void)tearDown {
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

#pragma mark - Helper Functions

- (NSDictionary *)sampleUserDictionary {
    NSDictionary *sampleDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"David Kay" , @"name"       ,
        @"DavidYKay" , @"nickname"   ,
        @"image.jpg" , @"user_image" ,
        @"1234"      , @"_id"        ,
        nil];
    return sampleDict;
}

- (NSDictionary *)sampleChannelDictionary:(NSUInteger)index {
    switch (index) {
        case 0:
        return [NSDictionary dictionaryWithObjectsAndKeys:
            @"4e385abdf6db24106c000004"     , @"_id"        ,
            @"2011-08-02T20:14:53.000Z"     , @"created_at" ,
            @"2011-08-02T20:14:53.000Z"     , @"updated_at" ,
            @"The David Y. Kay Broadcast"   , @"name"       ,
            [NSNumber numberWithInteger: 1] , @"public"     ,
            @"4e385abdf6db24106c000001"     , @"user_id"    ,
        nil];
        case 1:
        default:
        return [NSDictionary dictionaryWithObjectsAndKeys:
              @"4e385abdf6db24106c000006"     , @"_id"        ,
              @"2011-08-02T20:14:53.000Z"     , @"created_at" ,
              @"Watch Later"                  , @"name"       ,
              [NSNumber numberWithInteger: 0] , @"public"     ,
              @"2011-08-02T20:14:53.000Z"     , @"updated_at" ,
              @"4e385abdf6db24106c000001"     , @"user_id"    ,
        nil];
    }
}

#pragma mark - Tests

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
- (void)testThatEnvironmentWorks {
    STAssertNotNil(store, @"no persistent store");
}

- (void)testStoreUser {
    // Insert a user.
    NSDictionary *sampleDict = [self sampleUserDictionary];
    LoginHelper *loginHelper = [[[LoginHelper alloc] initWithContext: ctx] autorelease];
    [loginHelper storeUserWithDictionary: sampleDict];
    User *user = [loginHelper retrieveUser];

    STAssertNotNil(user, @"User was nil!");
    // Make sure that our data persisted.
    NSString *before;
    NSString *after;
    before = [sampleDict objectForKey: @"name"];
    after = [user valueForKey: @"name"];
    STAssertTrue(
            [before isEqualToString: after], @"Before: %@ After: %@", before, after
            );

    // Insert the channels.
    NSDictionary *sampleChannel1 = [self sampleChannelDictionary: 0];
    NSDictionary *sampleChannel2 = [self sampleChannelDictionary: 1];

    NSArray *sampleChannels = [NSArray arrayWithObjects:
        sampleChannel1,
        sampleChannel2,
        nil];

    [loginHelper storeChannelsWithArray: sampleChannels user: user];
    NSArray *channels = [loginHelper retrieveChannels];
    STAssertNotNil(channels, @"Channels was nil!");
    STAssertTrue([channels count] == 2, @"Channels count was: %d.", [channels count]);

    Channel *channel1 = [channels objectAtIndex: 0];
    Channel *channel2 = [channels objectAtIndex: 1];
    NSLog(@"Before: %@, After: %@",
          [sampleChannel1 objectForKey: @"_id"],
          channel1.shelbyId);
    NSLog(@"Before: %@, After: %@",
          [sampleChannel2 objectForKey: @"_id"],
          channel2.shelbyId);
    STAssertTrue([channel1.public boolValue] != [channel2.public boolValue], @"Channel public bools weren't equal");
    STAssertTrue([channel1.shelbyId isEqualToString: [sampleChannel1 objectForKey: @"_id"]], @"Channel1's id: %@", channel1.shelbyId);
    STAssertTrue([channel2.shelbyId isEqualToString: [sampleChannel2 objectForKey: @"_id"]], @"Channel2's id: %@", channel2.shelbyId);
    STAssertFalse([channel1.shelbyId isEqualToString: [sampleChannel2 objectForKey: @"_id"]], @"Channel1's key shouldn't be equal to channel 2's starting key");
    STAssertFalse([channel2.shelbyId isEqualToString: [sampleChannel1 objectForKey: @"_id"]], @"Channel2's key shouldn't be equal to channel 1's starting key");

    // See if we can navigate from channels to user.
    STAssertEqualObjects(user, channel1.user, @"User == channel1.user");
    STAssertEqualObjects(user, channel2.user, @"User == channel2.user");

    // See if we can navigate from user to channels.
    NSSet *userChannels =  user.channels;
    STAssertTrue([userChannels count] > 0, @"Count: %d", [userChannels count]);
}

@end

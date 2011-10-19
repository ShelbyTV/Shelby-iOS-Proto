//
//  ApiTest.m
//  Shelby
//
//  Created by David Kay on 9/22/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import "ApiTest.h"
#import "LoginHelper.h"
#import "Broadcast.h"

#import "SBJsonParser.h"

@implementation ApiTest

#pragma mark - Set Up & Tear Down

- (void)setUp {
    _loginHelper = [[LoginHelper alloc] init];
}

- (void)tearDown {
    [_loginHelper release];
}

#pragma mark - Helper Functions

//NSString *sampleJson = @"{ \"_id\" = 4e7179b8fa44c4166b005e8c, \"channel_id\" = 4e385abdf6db24106c000006, \"created_at\" = \"2011-09-15T04:06:16.000Z\", description = \"True Heroism - Citizens lift burning car off a wrecked motorcyclist http://t.co/y0Czgkxq\", \"liked_by_owner\" = 0, name = \"<null>\", \"total_plays\" = 0, \"updated_at\" = \"2011-09-15T04:06:16.000Z\", \"user_id\" = 4e385abdf6db24106c000001, \"user_nickname\" = DavidYKay, \"user_thumbnail\" = \"http://a3.twimg.com/profile_images/1128216386/29a016a_normal.jpg\", \"video_description\" = \"A Utah motorcyclist who was pinned under a burning car, expressed his gratitude on Tuesday for the help of strangers who lifted up the the 4,000 pound (1.8 tonne) vehicle to rescue him, in an act of bravery captured on amateur video.\", \"video_id_at_provider\" = BmzSEYNTkHA, \"video_origin\" = twitter, \"video_originator_network_object_id\" = 114188221474275330, \"video_originator_user_image\" = \"http://a3.twimg.com/profile_images/1327677048/smallerpic_normal.JPG\", \"video_originator_user_name\" = \"Dark Guardian\", \"video_originator_user_nickname\" = DarkGuardianSH, \"video_player\" = youtube, \"video_provider_name\" = youtube, \"video_thumbnail_url\" = \"http://i3.ytimg.com/vi/BmzSEYNTkHA/hqdefault.jpg\", \"video_title\" = \"Flame Throwers: Video of crash victim saved from burning car in Utah\", \"video_user_id\" = 4e385abdf6db24106c000001, \"video_user_nickname\" = DavidYKay, \"video_user_thumbnail\" = \"http://a3.twimg.com/profile_images/1128216386/29a016a_normal.jpg\", \"watched_by_owner\" = 0, }";
NSString *sampleJson = @"{ \"_id\" : 4e7179b8fa44c4166b005e8c, \"channel_id\" : 4e385abdf6db24106c000006, \"created_at\" : \"2011-09-15T04:06:16.000Z\", description : \"True Heroism - Citizens lift burning car off a wrecked motorcyclist http://t.co/y0Czgkxq\", \"liked_by_owner\" : 0, name : \"<null>\", \"total_plays\" : 0, \"updated_at\" : \"2011-09-15T04:06:16.000Z\", \"user_id\" : 4e385abdf6db24106c000001, \"user_nickname\" : DavidYKay, \"user_thumbnail\" : \"http://a3.twimg.com/profile_images/1128216386/29a016a_normal.jpg\", \"video_description\" : \"A Utah motorcyclist who was pinned under a burning car, expressed his gratitude on Tuesday for the help of strangers who lifted up the the 4,000 pound (1.8 tonne) vehicle to rescue him, in an act of bravery captured on amateur video.\", \"video_id_at_provider\" : BmzSEYNTkHA, \"video_origin\" : twitter, \"video_originator_network_object_id\" : 114188221474275330, \"video_originator_user_image\" : \"http://a3.twimg.com/profile_images/1327677048/smallerpic_normal.JPG\", \"video_originator_user_name\" : \"Dark Guardian\", \"video_originator_user_nickname\" : DarkGuardianSH, \"video_player\" : youtube, \"video_provider_name\" : youtube, \"video_thumbnail_url\" : \"http://i3.ytimg.com/vi/BmzSEYNTkHA/hqdefault.jpg\", \"video_title\" : \"Flame Throwers: Video of crash victim saved from burning car in Utah\", \"video_user_id\" : 4e385abdf6db24106c000001, \"video_user_nickname\" : DavidYKay, \"video_user_thumbnail\" : \"http://a3.twimg.com/profile_images/1128216386/29a016a_normal.jpg\", \"watched_by_owner\" : 0, }";
//NSString *sampleJson = @"{ \"_id\"                                                                           : \"4e7179b8fa44c4166b005e8c\", \"channel_id\"                                                                        : \"4e385abdf6db24106c000006\", \"created_at\"                                                                        : \"2011-09-15T04:06:16.000Z\", description                                                                           : \"True Heroism - Citizens lift burning car off a wrecked motorcyclist http : //t.co/y0Czgkxq\", \"liked_by_owner\"                                                                    : 0, name                                                                                  : \"<null>\", \"total_plays\"                                                                       : 0, \"updated_at\"                                                                        : \"2011-09-15T04:06:16.000Z\", \"user_id\"                                                                           : \"4e385abdf6db24106c000001\", \"user_nickname\"                                                                     : \"DavidYKay\", \"user_thumbnail\"                                                                    : \"http://a3.twimg.com/profile_images/1128216386/29a016a_normal.jpg\", \"video_description\"                                                                 : \"A Utah motorcyclist who was pinned under a burning car, expressed his gratitude on Tuesday for the help of strangers who lifted up the the 4, 000 pound (1.8 tonne) vehicle to rescue him, in an act of bravery captured on amateur video.\", \"video_id_at_provider\"                                                              : \"BmzSEYNTkHA\", \"video_origin\"                                                                      : \"twitter\", \"video_originator_network_object_id\"                                                : \"114188221474275330\", \"video_originator_user_image\"                                                       : \"http://a3.twimg.com/profile_images/1327677048/smallerpic_normal.JPG\", \"video_originator_user_name\"                                                        : \"Dark Guardian\", \"video_originator_user_nickname\"                                                    : \"DarkGuardianSH\", \"video_player\"                                                                      : \"youtube\", \"video_provider_name\"                                                               : \"youtube\", \"video_thumbnail_url\"                                                               : \"http://i3.ytimg.com/vi/BmzSEYNTkHA/hqdefault.jpg\", \"video_title\"                                                                       : \"Flame Throwers: Video of crash victim saved from burning car in Utah\", \"video_user_id\"                                                                     : \"4e385abdf6db24106c000001\", \"video_user_nickname\"                                                               : \"DavidYKay\", \"video_user_thumbnail\"                                                              : \"http://a3.twimg.com/profile_images/1128216386/29a016a_normal.jpg\", \"watched_by_owner\"                                                                  : 0 }";

- (NSDictionary *)sampleBroadcastDictionary {
    NSError *error = nil;
    NSString *string = sampleJson;
    //NSString *string = [[[NSString alloc]
    //    initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"broadcast" ofType: @"json"]
    //                  encoding: NSUTF8StringEncoding
    //                     error: &error
    //    ] autorelease];

    if (error) {
        // Throw exception
    } else {
        NSLog(@"Json string: %@", string);
        // convert string to dict
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dict = [parser objectWithString: string];
      
        if (parser.error) {
            NSLog(@"json parsing error: %@", parser.error);
        }
        [parser release];
        return dict;
    }
    return nil;
}

#pragma mark - Tests

- (void)testLikeBroadcast {
//    // Find a broadcast
//    //NSDictionary *dict = [self sampleBroadcastDictionary];
//    //NSString *videoId = [dict objectForKey: @"_id"];
//
//    NSString *videoId = @"4e7179b8fa44c4166b005e8c";
//    Broadcast *original = [_loginHelper fetchBroadcastWithId: videoId];
//    NSLog(@"Original: %@", [original description]);
//    // Mark it liked
//    STAssertNotNil(videoId, @"VideoID should not be nil. Was: %@", videoId);
//    STAssertNotNil(original, @"Original should not be nil. Was: %@", original);
//    STAssertNotNil(original.shelbyId, @"Original id should not be nil. Was: %@", original.shelbyId);
//
//    // Tell the API
//    [_loginHelper likeBroadcastWithId: videoId];
//
//    // Get it back
//    Broadcast *newBroadcast = [_loginHelper fetchBroadcastWithId: videoId];
//    NSLog(@"newBroadcast: %@", [original description]);
//
//    STAssertEqualObjects(newBroadcast.shelbyId, videoId, @"Broadcast.shelbyId %@ should be == to original %@", newBroadcast.shelbyId, videoId);
//    // It should be marked liked
//    STAssertTrue([newBroadcast.liked boolValue], @"Video should come back as liked");
    return;
}

- (void)testShareBroadcast {
    STAssertTrue(1 == 1, @"We are sane!");
    // Find a broadcast
    // Mark it watched
    // Tell the API
}

- (void)testWatchedBroadcast {
    STAssertTrue(1 == 1, @"We are sane!");
    // Find a broadcast
    // Mark it watched
    // Tell the API
    // Get it back
    // It should be marked watched
}

@end

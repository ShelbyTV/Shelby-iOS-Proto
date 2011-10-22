//
//  ApiConstants.h
//  Shelby
//
//  Created by Mark Johnson on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kAppName               @"Shelby.tv iOS"
#define kProviderName          @"shelby.tv"

#define kUserIdName            @"user_id"
#define kChannelIdName         @"channel_id"
#define kRequestTokenName      @"request"
#define kAccessTokenName       @"access"
#define kAccessTokenSecretName @"access_secret"

#define kShelbyConsumerKey	   @"oQjjKJ0GvQc8TX9VliW1gN16KKXkPHh9nLfGAGBB"
#define kShelbyConsumerSecret  @"WInhWrxHCje3T1U3hk3qHj7m5Lj2ThwwQ53OefA9"

#define kRequestTokenUrl       @"http://dev.shelby.tv/oauth/request_token"
#define kUserAuthorizationUrl  @"http://dev.shelby.tv/oauth/authorize"
#define kAccessTokenUrl        @"http://dev.shelby.tv/oauth/access_token"

#define kUserUrl               @"http://api.shelby.tv/v2/users.json"
#define kChannelsUrl           @"http://api.shelby.tv/v2/channels.json"
#define kBroadcastUrl          @"http://api.shelby.tv/v2/broadcasts/%@.json"
#define kBroadcastsUrl         @"http://api.shelby.tv/v2/channels/%@/broadcasts.json?video_player=youtube,vimeo"
#define kSocializationsUrl     @"http://api.shelby.tv/v2/socializations.json"
#define kAuthenticationsUrl    @"http://api.shelby.tv/v2/authentications.json"

#define kCallbackUrl           @"shelby://ios.shelby.tv"

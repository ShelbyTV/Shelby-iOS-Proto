//
//  BroadcastApi.m
//  Shelby
//
//  Created by Mark Johnson on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BroadcastApi.h"
#import "ApiConstants.h"
#import "ApiMutableURLRequest.h"
#import "SBJsonParser.h"
#import "ShelbyApp.h"
#import "ApiHelper.h"
#import "GraphiteStats.h"
#import "NSURLConnection+AsyncBlock.h"
#import "NSString+URLEncoding.h"
#import "Video.h"

@implementation BroadcastApi

#pragma mark - Helper Methods

+ (void)makeRequest:(ApiMutableURLRequest *)request
    withRequestType:(NSString *)requestType
          withVideo:(Video *)video
           withBody:(NSString *)body
        withCounter:(NSString *)counter
{
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request sign];
    [request setUserInfoDict:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", requestType, @"requestType", nil]];
    
    [NSURLConnection sendAsyncRequest:request delegate:self completionSelector:@selector(receivedResponse:data:error:forRequest:)];
    
    [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
    if (NOT_NULL(counter)) {
        [GraphiteStats incrementCounter:counter];
    }
}

+ (void)receivedResponse:(NSURLResponse *)resp
                    data:(NSData *)data
                   error:(NSError *)error
              forRequest:(NSURLRequest *)request
{
    NSString *requestType = [((ApiMutableURLRequest *)request).userInfoDict objectForKey:@"requestType"];
    
    if (NOT_NULL(error)) {
        LOG(@"%@ error: %@", requestType, error);
    } else {
        SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *dict = [parser objectWithData:data];
        NSString *apiError = [dict objectForKey:@"err"];
        
        NSString *notificationName = nil;
        if (NOT_NULL(apiError)) {
            LOG(@"%@ error: %@", requestType, apiError);
            notificationName = [NSString stringWithFormat:@"%@Failed", requestType];
        } else {
            LOG(@"%@ success", requestType);
            notificationName = [NSString stringWithFormat:@"%@Succeeded", requestType];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:self
                                                          userInfo:((ApiMutableURLRequest *)request).userInfoDict];
    }
    
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
}

#pragma mark - Watch

+ (void)watch:(Video *)video
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: kBroadcastUrl, video.shelbyId]];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"PUT"];

    [BroadcastApi makeRequest:req
              withRequestType:@"WatchBroadcast"
                    withVideo:video 
                     withBody:@"watched_by_owner=true"
                  withCounter:@"watchedByOwnerRequest"];
}

#pragma mark - Like

+ (void)like:(Video *)video
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: kBroadcastUrl, video.shelbyId]];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"PUT"];

    [BroadcastApi makeRequest:req
              withRequestType:@"LikeBroadcast"
                    withVideo:video 
                     withBody:@"liked_by_owner=true" 
                  withCounter:@"likedByOwnerRequest"];
}

+ (void)dislike:(Video *)video
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: kBroadcastUrl, video.shelbyId]];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"PUT"];
    
    [BroadcastApi makeRequest:req
              withRequestType:@"DislikeBroadcast"
                    withVideo:video 
                     withBody:@"liked_by_owner=false"
                  withCounter:@"dislikedByOwnerRequest"];
}

#pragma mark - Share

+ (NSString *)parseNetworks:(NSArray *)networks
{
    assert([networks count] > 0);
    
    NSString *networksString = nil;
    for (NSString *network in networks) {
        if ([network isEqualToString:@"twitter"]) {
            [GraphiteStats incrementCounter:@"shareViaTwitterRequest"];
        } else if ([network isEqualToString:@"facebook"]) {
            [GraphiteStats incrementCounter:@"shareViaFacebookRequest"];
        } else if ([network isEqualToString:@"tumblr"]) {
            [GraphiteStats incrementCounter:@"shareViaTumblrRequest"];
        } else if ([network isEqualToString:@"email"]) {
            [GraphiteStats incrementCounter:@"shareViaEmailRequest"];
        }
        
        if (IS_NULL(networksString)) {
            networksString = network;
        } else {
            networksString = [NSString stringWithFormat:@"%@,%@", networksString, network];
        }
    }
    
    return networksString;
}

+ (NSString *)shareBodyForVideo:(Video *)video
                   withNetworks:(NSString *)networksString
                    withComment:(NSString *)comment
                  withRecipient:(NSString *)recipient
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   networksString, @"destination",
                                   video.shelbyId, @"broadcast_id",
                                   [comment URLEncodedString], @"comment",
                                   nil];
    
    if (NOT_NULL(recipient)) {
        [params setObject:[recipient URLEncodedString] forKey: @"to"];
    }
    
    NSString *formString = nil;
    for (NSString *key in [params allKeys]) {
        NSString *pair = [NSString stringWithFormat:@"%@=%@", key, [params objectForKey: key]];
        if (!formString) {
            formString = pair;
        } else {
            formString = [NSString stringWithFormat:@"%@&%@", formString, pair];
        }
    }

    return formString;
}

+ (void)share:(Video *)video
      comment:(NSString *)comment
     networks:(NSArray *)networks
    recipient:(NSString *)recipient
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kSocializationsUrl]];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"POST"];

    NSString *networksString = [BroadcastApi parseNetworks:networks];
    NSString *body = [BroadcastApi shareBodyForVideo:video
                                        withNetworks:networksString
                                         withComment:comment
                                       withRecipient:recipient];
    [BroadcastApi makeRequest:req
              withRequestType:@"ShareBroadcast"
                    withVideo:video 
                     withBody:body
                  withCounter:nil];
}

@end

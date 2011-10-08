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

#pragma mark - Watch

+ (void)watch:(Video *)video
{
    NSString *urlString = [NSString stringWithFormat: kBroadcastUrl, video.shelbyId];
    NSURL *url = [NSURL URLWithString: urlString];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"PUT"];

    if (req) {
        // Set watched
        [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSString *watchedString = @"watched_by_owner=true";
        [req setHTTPBody:[watchedString dataUsingEncoding:NSUTF8StringEncoding]];

        [req sign];

        [req setUserInfoDict:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]];

        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedWatchResponse:data:error:forRequest:)];
        [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];

        [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"watchedByOwnerRequest"];
    } else {
        // We failed to send the request. Let the caller know.
    }
}

+ (void)receivedWatchResponse:(NSURLResponse *)resp
                         data:(NSData *)data
                        error:(NSError *)error
                   forRequest:(NSURLRequest *)request
{
    LOG(@"receivedWatchBroadcastResponse");

    if (NOT_NULL(error)) {
        LOG(@"Watch Broadcast error: %@", error);
    } else {
        SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *dict = [parser objectWithData:data];
        NSString *apiError = [dict objectForKey:@"err"];

        if (NOT_NULL(apiError)) {
            LOG(@"Watch Broadcast error: %@", apiError);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WatchBroadcastFailed"
                                                                object:self
                                                              userInfo:((ApiMutableURLRequest *)request).userInfoDict];
        } else {
            LOG(@"Watch Broadcast success");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WatchBroadcastSucceeded"
                                                                object:self
                                                              userInfo:((ApiMutableURLRequest *)request).userInfoDict];
        }

        //NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
        //NSLog(@"receivedWatchBroadcastResponse: %@", string);
    }

    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
}

#pragma mark - Like

+ (void)like:(Video *)video
{
    NSString *urlString = [NSString stringWithFormat: kBroadcastUrl, video.shelbyId];
    NSURL *url = [NSURL URLWithString: urlString];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"PUT"];

    if (req) {
        [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

        NSString *likeString = @"liked_by_owner=true";

        [req setHTTPBody: [likeString dataUsingEncoding:NSUTF8StringEncoding]];

        // Sign in HMAC-SHA1
        [req sign];

        req.userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil];

        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedLikeResponse:data:error:forRequest:)];

        [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];

        [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"likedByOwnerRequest"];
    } else {
        // We failed to send the request. Let the caller know.
    }
}

+ (void)receivedLikeResponse:(NSURLResponse *)resp
                        data:(NSData *)data
                       error:(NSError *)error
                  forRequest:(NSURLRequest *)request
{
    LOG(@"receivedLikeBroadcastResponse");

    if (NOT_NULL(error)) {
        LOG(@"Like Broadcast error: %@", error);
    } else {
        SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *dict = [parser objectWithData:data];
        NSString *apiError = [dict objectForKey:@"err"];

        if (NOT_NULL(apiError)) {
            LOG(@"Like Broadcast error: %@", apiError);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeBroadcastFailed"
                                                                object:self
                                                              userInfo:((ApiMutableURLRequest *)request).userInfoDict];
        } else {
            LOG(@"Like Broadcast success");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeBroadcastSucceeded"
                                                                object:nil
                                                              userInfo:((ApiMutableURLRequest *)request).userInfoDict];
        }
    }

    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
}

+ (void)dislike:(Video *)video
{
    NSString *urlString = [NSString stringWithFormat: kBroadcastUrl, video.shelbyId];
    NSURL *url = [NSURL URLWithString: urlString];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"PUT"];
    
    if (req) {
        [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSString *likeString = @"liked_by_owner=false";
        
        [req setHTTPBody: [likeString dataUsingEncoding:NSUTF8StringEncoding]];
        
        // Sign in HMAC-SHA1
        [req sign];
        
        req.userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil];
                
        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedDislikeResponse:data:error:forRequest:)];
        
        [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
        
        [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"dislikedByOwnerRequest"];
    } else {
        // We failed to send the request. Let the caller know.
    }
}

+ (void)receivedDislikeResponse:(NSURLResponse *)resp
                           data:(NSData *)data
                          error:(NSError *)error
                     forRequest:(NSURLRequest *)request
{
    LOG(@"receivedDislikeBroadcastResponse");
    
    if (NOT_NULL(error)) {
        LOG(@"Dislike Broadcast error: %@", error);
    } else {
        SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *dict = [parser objectWithData:data];
        NSString *apiError = [dict objectForKey:@"err"];
        
        if (NOT_NULL(apiError)) {
            LOG(@"Dislike Broadcast error: %@", apiError);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DislikeBroadcastFailed"
                                                                object:self
                                                              userInfo:((ApiMutableURLRequest *)request).userInfoDict];
        } else {
            LOG(@"Dislike Broadcast success");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DislikeBroadcastSucceeded"
                                                                object:nil
                                                              userInfo:((ApiMutableURLRequest *)request).userInfoDict];
        }
    }
    
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
}

#pragma mark - Share

+ (void)share:(Video *)video
      comment:(NSString *)comment
     networks:(NSArray *)networks
    recipient:(NSString *)recipient
{
    NSString *urlString = [NSString stringWithFormat:kSocializationsUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    ApiMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"POST"];

    //POST /v2/socializations.json
    //{destination : 'twitter,facebook,tumblr,email',
    //broadcast_id : '4d93900f8ebcf670c0000676',
    //     comment : 'this is the comment',

    if (req) {
        NSString *networksString = nil;
        for (NSString *network in networks) {

            if ([network isEqualToString:@"twitter"]) {
                [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"shareViaTwitterRequest"];
            } else if ([network isEqualToString:@"facebook"]) {
                [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"shareViaFacebookRequest"];
            } else if ([network isEqualToString:@"tumblr"]) {
                [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"shareViaTumblrRequest"];
            } else if ([network isEqualToString:@"email"]) {
                [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"shareViaEmailRequest"];
            }

            if (!networksString) {
                networksString = network;
            } else {
                networksString = [NSString stringWithFormat:@"%@,%@", networksString, network];
            }
        }

        // no networks passed in
        if (networksString == nil) {
            return;
        }

        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                networksString, @"destination",
                                video.shelbyId, @"broadcast_id",
                                [comment URLEncodedString], @"comment",
                                nil];

        if (NOT_NULL(recipient)) {
            // If email, send who's
            //[params setObject: recipient forKey: @"to"];
            [params setObject: [recipient URLEncodedString] forKey: @"to"];
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

        [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [req setHTTPBody: [formString dataUsingEncoding:NSUTF8StringEncoding]];

        [req sign];

        [req setUserInfoDict:[NSDictionary dictionaryWithObjectsAndKeys:video, @"video", nil]];

        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedShareBroadcastResponse:data:error:forRequest:)];
        [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
    } else {
        // We failed to send the request. Let the caller know.
    }
}

+ (void)receivedShareBroadcastResponse:(NSURLResponse *)resp
                                  data:(NSData *)data
                                 error:(NSError *)error
                            forRequest:(NSURLRequest *)request
{
    LOG(@"receivedShareBroadcastResponse");

    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)resp;

    if (NOT_NULL(error)) {
        LOG(@"Share Broadcast error: %@", error);
    } else {
        if ([httpResp statusCode] != 200) {
            LOG(@"Share Broadcast error! Status code: %d", [httpResp statusCode]);

        } else {
            SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
            NSDictionary *dict = [parser objectWithData:data];
            NSString *apiError = [dict objectForKey:@"err"];

            if (NOT_NULL(apiError)) {
                LOG(@"Share Broadcast error: %@", apiError);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareBroadcastFailed"
                                                                    object:self
                                                                  userInfo:((ApiMutableURLRequest *)request).userInfoDict];
            } else {
                LOG(@"Share Broadcast success");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareBroadcastSucceeded"
                                                                    object:self
                                                                  userInfo:((ApiMutableURLRequest *)request).userInfoDict];
            }

            //NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
            //NSLog(@"receivedShareBroadcastResponse: %@", string);
        }
    }

    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
}

@end

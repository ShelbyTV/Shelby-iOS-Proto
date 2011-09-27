//
//  BroadcastApi.m
//  Shelby
//
//  Created by Mark Johnson on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BroadcastApi.h"
#import "ApiConstants.h"
#import "OAuthMutableURLRequest.h"
#import "SBJsonParser.h"
#import "ShelbyApp.h"
#import "ApiHelper.h"
#import "GraphiteStats.h"
#import "NSURLConnection+AsyncBlock.h"
#import "NSString+URLEncoding.h"

@implementation BroadcastApi

#pragma mark - Watch

+ (void)watch:(NSString *)videoId
{
    NSString *urlString = [NSString stringWithFormat: kBroadcastUrl, videoId];
    NSURL *url = [NSURL URLWithString: urlString];
    OAuthMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"PUT"];
    
    if (req) {
        // Set watched
        [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSString *watchedString = @"watched_by_owner=true";
        [req setHTTPBody:[watchedString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [req sign];
                
        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedWatchResponse:data:error:forRequest:)];
        [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
        
        [[ShelbyApp sharedApp].graphiteStats incrementCounter:@"watchVideo"];
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
    
    if (NOTNULL(error)) {
        LOG(@"Watch Broadcast error: %@", error);
    } else {
        SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *dict = [parser objectWithData:data];
        NSString *apiError = [dict objectForKey:@"err"];
        
        if (NOTNULL(apiError)) {
            LOG(@"Watch Broadcast error: %@", apiError);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WatchBroadcastFailed"
                                                                object:self];
        } else {
            LOG(@"Watch Broadcast success");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WatchBroadcastSucceeded"
                                                                object:self];
        }
        
        //NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
        //NSLog(@"receivedWatchBroadcastResponse: %@", string);
    }
    
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
}

#pragma mark - Like

+ (void)like:(NSString *)videoId
{
    NSString *urlString = [NSString stringWithFormat: kBroadcastUrl, videoId];
    NSURL *url = [NSURL URLWithString: urlString];
    OAuthMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"PUT"];
    
    if (req) {        
        [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSString *likeString = @"liked_by_owner=true";
        
        [req setHTTPBody: [likeString dataUsingEncoding:NSUTF8StringEncoding]];
        
        // Sign in HMAC-SHA1
        [req sign];
                
        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedLikeResponse:data:error:forRequest:)];
        
        [[ShelbyApp sharedApp].apiHelper incrementNetworkCounter];
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
    
    if (NOTNULL(error)) {
        LOG(@"Like Broadcast error: %@", error);
    } else {
        SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *dict = [parser objectWithData:data];
        NSString *apiError = [dict objectForKey:@"err"];
        
        if (NOTNULL(apiError)) {
            LOG(@"Like Broadcast error: %@", apiError);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeBroadcastFailed"
                                                                object:self];
        } else {
            LOG(@"Like Broadcast success");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeBroadcastSucceeded"
                                                                object:self];
        }
        
        //NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
        //NSLog(@"receivedLikeBroadcastResponse: %@", string);
    }
    
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
}

#pragma mark - Share

+ (void)share:(NSString *)videoId 
      comment:(NSString *)comment 
     networks:(NSArray *)networks 
    recipient:(NSString *)recipient
{
    NSString *urlString = [NSString stringWithFormat:kSocializationsUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    OAuthMutableURLRequest *req = [[ShelbyApp sharedApp].apiHelper requestForURL:url withMethod:@"POST"];
    
    //POST /v2/socializations.json
    //{destination : 'twitter,facebook,tumblr,email',
    //broadcast_id : '4d93900f8ebcf670c0000676',
    //     comment : 'this is the comment',
    
    if (req) {
        NSString *networksString = nil;
        for (NSString *network in networks) {
            if (!networksString) {
                networksString = network;
            } else {
                networksString = [NSString stringWithFormat:@"%@,%@", networksString, network];
            }
        }
        
        //if (NOTNULL(recipient)) {
        //    // If email, send who's
        //    [req setValue: recipient forOAuthParameter: @"to"];
        //}
                
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                networksString, @"destination", 
                                videoId, @"broadcast_id", 
                                [comment URLEncodedString], @"comment", 
                                nil];
        
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
    
    if (NOTNULL(error)) {
        LOG(@"Share Broadcast error: %@", error);
    } else {
        if ([httpResp statusCode] != 200) {
            LOG(@"Share Broadcast error! Status code: %d", [httpResp statusCode]);
            
        } else {
            SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
            NSDictionary *dict = [parser objectWithData:data];
            NSString *apiError = [dict objectForKey:@"err"];
            
            if (NOTNULL(apiError)) {
                LOG(@"Share Broadcast error: %@", apiError);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareBroadcastFailed"
                                                                    object:self];
            } else {
                LOG(@"Share Broadcast success");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareBroadcastSucceeded"
                                                                    object:self];
            }
            
            //NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
            //NSLog(@"receivedShareBroadcastResponse: %@", string);
        }
    }
    
    [[ShelbyApp sharedApp].apiHelper decrementNetworkCounter];
}

@end

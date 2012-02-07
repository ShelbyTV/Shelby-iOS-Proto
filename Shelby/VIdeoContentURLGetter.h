//
//  VideoContentURLGetter.h
//  Shelby
//
//  Created by Mark Johnson on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkObject.h"

@class Video;

@interface VideoContentURLGetter : NSObject <UIWebViewDelegate, NetworkObject>
{
    UIWebView *_webView;
    NSMutableArray *_videoQueue;
    double _lastGetBegan;
    double _lastGetEnded;
    NSMutableDictionary *_seenPaths;
}

@property (readonly) NSInteger networkCounter;
@property (nonatomic, retain) Video * currentVideo;

+ (VideoContentURLGetter*)singleton;
- (void)processVideo:(Video *)video;
- (UIWebView *)getView;

@end

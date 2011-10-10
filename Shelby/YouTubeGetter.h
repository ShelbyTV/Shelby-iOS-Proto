//
//  YouTubeGetter.h
//  Shelby
//
//  Created by Mark Johnson on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Video;

@interface YouTubeGetter : UIViewController <UIWebViewDelegate>
{
    UIWebView *_webView;
    NSMutableArray *_videoQueue;
    Video *_currentVideo;
    double _lastGetBegan;
    NSMutableDictionary *_seenPaths;
}

+ (YouTubeGetter*)singleton;
- (void)processVideo:(Video *)video;

@end

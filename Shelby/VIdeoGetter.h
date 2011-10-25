//
//  VideoGetter.h
//  Shelby
//
//  Created by Mark Johnson on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Video;

@interface VideoGetter : UIViewController <UIWebViewDelegate>
{
    UIWebView *_webView;
    NSMutableArray *_videoQueue;
    double _lastGetBegan;
    NSMutableDictionary *_seenPaths;
}

@property (nonatomic, retain) Video * currentVideo;

+ (VideoGetter*)singleton;
- (void)processVideo:(Video *)video;
- (UIWebView *)getView;

@end

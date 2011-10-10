//
//  YouTubeGetter.m
//  Shelby
//
//  Created by Mark Johnson on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "YouTubeGetter.h"
#import "Video.h"

#import <QuartzCore/QuartzCore.h>

@implementation YouTubeGetter

static YouTubeGetter *singletonYouTubeGetter = nil;

+ (YouTubeGetter*)singleton
{
    if (singletonYouTubeGetter == nil) {
        NSLog(@"allocating new singletonYouTubeGetter");
        singletonYouTubeGetter = [[super allocWithZone:NULL] init];
    }
    return singletonYouTubeGetter;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self singleton] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _webView = [[UIWebView alloc] init];
        _webView.frame = CGRectMake(0, 0, 640, 480);
        _webView.delegate = self;
        _videoQueue = [[NSMutableArray alloc] init];
        _seenPaths = [[NSMutableDictionary alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkQueue) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)checkQueue
{
    @synchronized(self)
    {
        // wait a maximum of 3 seconds to get a response
        double now = CACurrentMediaTime();
        if (now - _lastGetBegan > 3 && _currentVideo != nil)
        {
            NSLog(@"_lastGetBegan = %f", _lastGetBegan);
            NSLog(@"currentTime = %f", now);
            NSLog(@"REAPING JOB THAT WAS CURRENT TOO LONG");
            _currentVideo = nil;
            static NSString *htmlString = @"<html><body></body></html>";
            [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        
        if ([_videoQueue count] != 0 && _currentVideo == nil) {
            NSLog(@"PROCESSING ENQUEUED JOB");
            _lastGetBegan = CACurrentMediaTime();
            NSLog(@"_lastGetBegan = %f", _lastGetBegan);

            _currentVideo = (Video *)[_videoQueue objectAtIndex:0];
            [_videoQueue removeObjectAtIndex:0];
            
            [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(getYouTubeURL) userInfo:nil repeats:NO];
        }
    }
}

- (void)processVideo:(Video *)video
{
    @synchronized(self)
    {
        if (_currentVideo != video && ![_videoQueue containsObject:video]) { 
            [_videoQueue insertObject:video atIndex:0];
        }
    }
}

- (void)getYouTubeURL
{
    static NSString *htmlFormatString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 640\"/></head>\
    <body style=\"background:#FF0000;margin-top:0px;margin-left:0px\">\
    <div><object width=\"640\" height=\"480\">\
    <param name=\"movie\" value=\"http://www.youtube.com/watch?v=%@\"></param>\
    <param name=\"wmode\" value=\"transparent\"></param>\
    <embed src=\"http://www.youtube.com/watch?v=%@\"\
    type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"640\" height=\"480\"></embed>\
    </object></div></body></html>";
    
    @synchronized(self) {
        if (_currentVideo == nil) {
            return;
        }
        _lastGetBegan = CACurrentMediaTime();
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:nil object:nil];
        NSString *htmlString = [NSString stringWithFormat:htmlFormatString, _currentVideo.providerId, _currentVideo.providerId];
        [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
    }
}

- (void)processNotification:(NSNotification *)notification
{
    if (IS_NULL(notification.userInfo)) {
        return;
    }
    
    NSAutoreleasePool* myPool = [[NSAutoreleasePool alloc] init];

    static NSString *htmlString = @"<html><body></body></html>";
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", @"p",@"a",@"t",@"h"]);
    NSArray *allValues = [notification.userInfo allValues];
    for (id i in allValues) {
        if (![i respondsToSelector:sel]) {
            continue;
        }
        // should really check to see if the string contains youtube stuff...
        NSString *path = [i performSelector:sel withObject:nil];
        if ([_seenPaths objectForKey:path] != nil) {
            break; // already seen
        }
        
        [_seenPaths setObject:_currentVideo.providerId forKey:path];
        NSURL *contentURL = [NSURL URLWithString:path];
        
        @synchronized(self) {
            if (_currentVideo == nil || _currentVideo.contentURL != nil) {
                break;
            }
            _currentVideo.contentURL = contentURL;
            [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            NSLog(@"posting ContentURLAvailable notification");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ContentURLAvailable"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:contentURL, @"contentURL", _currentVideo, @"video", nil]];
            
            _currentVideo = nil;
        }
    }

    [myPool release];
}

- (void)dealloc
{
    [super dealloc];
}


- (UIButton *)findButtonInView:(UIView *)view
{
    UIButton *button = nil;
    
    if ([view isMemberOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findButtonInView:subview];
            if (button) return button;
        }
    }
    
    return button;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView didFailLoadWithError");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{   
    NSLog(@"webViewDidFinishLoad");
    UIButton *b = [self findButtonInView:webView];
    if (b == nil) {
        NSLog(@"button is nil");
    } else {
        [b sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end


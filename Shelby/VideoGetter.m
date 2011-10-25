//
//  VideoGetter.m
//  Shelby
//
//  Created by Mark Johnson on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoGetter.h"
#import "Video.h"
#import "ShelbyAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

@implementation VideoGetter

@synthesize currentVideo;

static VideoGetter *singletonYouTubeGetter = nil;

+ (VideoGetter*)singleton
{
    if (singletonYouTubeGetter == nil) {
        NSLog(@"allocating new singletonYouTubeGetter");
        singletonYouTubeGetter = [[super allocWithZone:NULL] init];
        NSLog(@"alloc'ed new singletonYouTubeGetter");
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
        _webView.frame = CGRectMake(0, 240, 320, 1);
        _webView.delegate = self;
        _webView.allowsInlineMediaPlayback = NO;
        _webView.mediaPlaybackRequiresUserAction = NO;
        _webView.hidden = YES;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
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
        // wait a maximum of 8 seconds to get a response
        double now = CACurrentMediaTime();
        if (now - _lastGetBegan > 8 && self.currentVideo != nil)
        {
            LOG(@"_lastGetBegan = %f", _lastGetBegan);
            LOG(@"currentTime = %f", now);
            LOG(@"REAPING JOB THAT WAS CURRENT TOO LONG");
            self.currentVideo = nil;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] resetRootController];
            } else {
                static NSString *htmlString = @"<html><body></body></html>";
                [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
        }
        
        if ([_videoQueue count] != 0 && self.currentVideo == nil) {
            LOG(@"PROCESSING ENQUEUED JOB");
            _lastGetBegan = CACurrentMediaTime();
            LOG(@"_lastGetBegan = %f", _lastGetBegan);

            self.currentVideo = (Video *)[_videoQueue objectAtIndex:0];
            [_videoQueue removeObjectAtIndex:0];
            
            [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(getYouTubeURL) userInfo:nil repeats:NO];
        }
    }
}

- (UIWebView *)getView
{
    return _webView;
}

- (void)processVideo:(Video *)video
{
    [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] resetRootController];

    @synchronized(self)
    {
        if (self.currentVideo != video && ![_videoQueue containsObject:video]) { 
            [_videoQueue removeAllObjects];
            [_videoQueue insertObject:video atIndex:0];
        }
    }
}

- (void)getYouTubeURL
{
    static NSString *youtubeFormatString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 640\"/></head>\
    <body style=\"background:#FF0000;margin-top:0px;margin-left:0px\">\
    <div><object width=\"640\" height=\"480\">\
    <param name=\"movie\" value=\"http://www.youtube.com/watch?v=%@\"></param>\
    <param name=\"wmode\" value=\"transparent\"></param>\
    <embed src=\"http://www.youtube.com/watch?v=%@\"\
    type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"640\" height=\"480\"></embed>\
    </object></div></body></html>";
    
    static NSString *vimeoFormatString = @"<html><body><center><iframe id=\"player_1\" src=\"http://player.vimeo.com/video/%@?api=1&amp;player_id=player_1\"></iframe><script src=\"http://a.vimeocdn.com/js/froogaloop2.min.js?cdbdb\"></script><script>(function(){var vimeoPlayers = document.querySelectorAll('iframe');$f(vimeoPlayers[0]).addEvent('ready', ready);function ready(player_id) {$f(player_id).api('play');}})();</script></center></body></html>";
    
    @synchronized(self) {
        if (self.currentVideo == nil) {
            return;
        }
        _lastGetBegan = CACurrentMediaTime();
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:nil object:nil];
                
        NSString *htmlString;
        if ([self.currentVideo.provider isEqualToString:@"youtube"]) {
            htmlString = [NSString stringWithFormat:youtubeFormatString, self.currentVideo.providerId, self.currentVideo.providerId];
        } else if ([self.currentVideo.provider isEqualToString:@"vimeo"]) {
            htmlString = [NSString stringWithFormat:vimeoFormatString, self.currentVideo.providerId];
        }
        
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
        // should really check to see if the string contains a valid movie URL...
        NSString *path = [i performSelector:sel withObject:nil];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([_seenPaths objectForKey:path] != nil) {
                break; // already seen
            }
            
            [_seenPaths setObject:self.currentVideo.providerId forKey:path];
        }
        NSURL *contentURL = [NSURL URLWithString:path];
        
        @synchronized(self) {
            if (self.currentVideo == nil || self.currentVideo.contentURL != nil) {
                break;
            }
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.currentVideo.contentURL = contentURL;
                [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            LOG(@"posting ContentURLAvailable notification");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ContentURLAvailable"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:contentURL, @"contentURL", self.currentVideo, @"video", nil]];
            
            self.currentVideo = nil;
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{   
    LOG(@"webViewDidFinishLoad");
    UIButton *b = [self findButtonInView:webView];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end


//
//  VideoContentURLGetter.m
//  Shelby
//
//  Created by Mark Johnson on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoContentURLGetter.h"
#import "Video.h"
#import "ShelbyAppDelegate.h"
#import "KitchenSinkUtilities.h"

#import <QuartzCore/QuartzCore.h>

@interface VideoContentURLGetter () 

@property (readwrite) NSInteger networkCounter;

@end

@implementation VideoContentURLGetter

@synthesize currentVideo;
@synthesize networkCounter;

static VideoContentURLGetter *singletonVideoContentURLGetter = nil;

+ (VideoContentURLGetter *)singleton
{
    if (singletonVideoContentURLGetter == nil) {
        singletonVideoContentURLGetter = [[super allocWithZone:NULL] init];
    }
    return singletonVideoContentURLGetter;
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

- (void)initWebView
{
    _webView = [[UIWebView alloc] init];
    _webView.frame = CGRectMake(0, 240, 320, 1);
    _webView.delegate = self;
    _webView.allowsInlineMediaPlayback = YES;
    _webView.mediaPlaybackRequiresUserAction = NO;
    if ([_webView respondsToSelector:@selector(setMediaPlaybackAllowsAirplay:)]) {
        _webView.mediaPlaybackAllowsAirPlay = NO;
    }
    _webView.hidden = YES;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initWebView];
        _videoQueue = [[NSMutableArray alloc] init];
        _seenPaths = [[NSMutableDictionary alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkQueue) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)resetWebView
{
    @synchronized(self)
    {
        [_webView stopLoading];
        [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [KitchenSinkUtilities clearAllCookies];
    }
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ContentURLAvailable"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.currentVideo, @"video", nil]];
            
            self.currentVideo = nil;
            self.networkCounter = 0;
            [[NSNotificationCenter defaultCenter] removeObserver:self];

            [self resetWebView];

            _lastGetEnded = CACurrentMediaTime();
        }
        
        if (now - _lastGetEnded > 0.5 && 
            now - _lastGetBegan > 0.5 && 
            [_videoQueue count] != 0 && 
            self.currentVideo == nil) {
            
            LOG(@"PROCESSING ENQUEUED JOB");
            _lastGetBegan = CACurrentMediaTime();
            LOG(@"_lastGetBegan = %f", _lastGetBegan);

            self.currentVideo = (Video *)[_videoQueue objectAtIndex:0];
            [_videoQueue removeObjectAtIndex:0];
            self.networkCounter = 1;
            
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
    @synchronized(self)
    {
        if (self.currentVideo != video && ![_videoQueue containsObject:video]) { 
            [_videoQueue removeAllObjects];
            [_videoQueue insertObject:video atIndex:0];
        }
    }
    
    [self checkQueue];
}

- (void)getYouTubeURL
{
    static NSString *youtubeFormatString = @"<html><body><div id=\"player\"></div><script>var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { height: '1', width: '1', videoId: '%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script></body></html>";
    
    static NSString *vimeoFormatString = @"<html><body><center><iframe id=\"player_1\" src=\"http://player.vimeo.com/video/%@?api=1&amp;player_id=player_1\" webkit-playsinline ></iframe><script src=\"http://a.vimeocdn.com/js/froogaloop2.min.js?cdbdb\"></script><script>(function(){var vimeoPlayers = document.querySelectorAll('iframe');$f(vimeoPlayers[0]).addEvent('ready', ready);function ready(player_id) {$f(player_id).api('play');}})();</script></center></body></html>";
        
    @synchronized(self) {
        if (self.currentVideo == nil || NOT_NULL(self.currentVideo.contentURL)) {
            return;
        }
        _lastGetBegan = CACurrentMediaTime();
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:nil object:nil];
                
        NSString *htmlString;
        if ([self.currentVideo.provider isEqualToString:@"youtube"]) {
            htmlString = [NSString stringWithFormat:youtubeFormatString, self.currentVideo.providerId];
        } else { // ([self.currentVideo.provider isEqualToString:@"vimeo"]) {
            htmlString = [NSString stringWithFormat:vimeoFormatString, self.currentVideo.providerId];
        }
        [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
    }
}

- (void)processNotification:(NSNotification *)notification
{
    static BOOL processingNotifications = FALSE;
    if (processingNotifications) {
        // prevent infinite loops
        return;
    }
    NSAutoreleasePool* myPool = [[NSAutoreleasePool alloc] init];
    
    processingNotifications = TRUE;
    
    @synchronized(self) {
        if (NOT_NULL(notification.userInfo)) {
            SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", @"p",@"a",@"t",@"h"]);
            NSArray *allValues = [notification.userInfo allValues];
            for (id i in allValues) {
                if (![i respondsToSelector:sel]) {
                    continue;
                }
                NSString *path = [i performSelector:sel];
                
                if ([_seenPaths objectForKey:path] != nil) {
                    break; // already seen
                }

                [[NSNotificationCenter defaultCenter] removeObserver:self];
                [self resetWebView];

                self.networkCounter = 0;
                _lastGetEnded = CACurrentMediaTime();
                
                if (self.currentVideo == nil || self.currentVideo.contentURL != nil) {
                    break;
                }
                NSURL *contentURL = [NSURL URLWithString:path];
                [_seenPaths setObject:self.currentVideo.providerId forKey:path];
                self.currentVideo.contentURL = contentURL;
                LOG(@"posting ContentURLAvailable notification");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ContentURLAvailable"
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.currentVideo, @"video", nil]];
                self.currentVideo = nil;

                NSLog(@"------------------------------------------");
                break;
            }
        }
    }
    
    [myPool release];
    processingNotifications = FALSE;
}

- (void)dealloc
{
    [super dealloc];
}

@end
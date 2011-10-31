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

@interface VideoGetter () 

@property (readwrite) NSInteger networkCounter;

@end

@implementation VideoGetter

@synthesize currentVideo;
@synthesize networkCounter;

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

- (void)resetWebView
{
    @synchronized(self)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] clearWebViewAnimations];
        }
        static NSString *htmlString = @"<html><body></body></html>";
        [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [(ShelbyAppDelegate *)[[UIApplication sharedApplication] delegate] resetShelbyWindowRotation];
        }
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
    static NSString *youtubeFormatString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 640\"/></head>\
    <body style=\"background:#FF0000;margin-top:0px;margin-left:0px\">\
    <div><object width=\"640\" height=\"480\">\
    <param name=\"movie\" value=\"http://www.youtube.com/watch?v=%@\"></param>\
    <param name=\"wmode\" value=\"transparent\"></param>\
    <embed src=\"http://www.youtube.com/watch?v=%@\"\
    type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"640\" height=\"480\"></embed>\
    </object></div></body></html>";
    
    static NSString *vimeoFormatString = @"<html><body><center><iframe id=\"player_1\" src=\"http://player.vimeo.com/video/%@?api=1&amp;player_id=player_1\" webkit-playsinline ></iframe><script src=\"http://a.vimeocdn.com/js/froogaloop2.min.js?cdbdb\"></script><script>(function(){var vimeoPlayers = document.querySelectorAll('iframe');$f(vimeoPlayers[0]).addEvent('ready', ready);function ready(player_id) {$f(player_id).api('play');}})();</script></center></body></html>";
        
    @synchronized(self) {
        if (self.currentVideo == nil || NOT_NULL(self.currentVideo.contentURL)) {
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
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(resetWebView) userInfo:nil repeats:NO];
                } else {
                    [self resetWebView];
                }
                [[NSNotificationCenter defaultCenter] removeObserver:self];

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
    UIButton *b = [self findButtonInView:webView];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end


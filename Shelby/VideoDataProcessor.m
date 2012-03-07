//
//  VideoDataProcessor.m
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoDataProcessor.h"
#import "Video.h"
#import "ShelbyApp.h"
#import "Enums.h"
#import "VideoCoreDataInterface.h"
#import "Broadcast.h"

@implementation VideoDataProcessor

@synthesize delegate;

#pragma mark - Constants

#define kMaxVideoThumbnailHeight 163
#define kMaxVideoThumbnailWidth 290
#define kMaxSharerImageHeight 120
#define kMaxSharerImageWidth 120

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self)
    {
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:3];
    }
    
    return self;
}

#pragma mark - Network Operation Tracking

// sync just needed for writes to make sure two simultaneous inc/decrements don't result in same value
// this is because OSAtomicInc* doesn't exist on iOS
- (void)incrementNetworkCounter
{
//    @synchronized(self) { self.networkCounter++; }
}

- (void)decrementNetworkCounter
{
//    @synchronized(self) { self.networkCounter--; }
}

- (BOOL)isLoading
{
    // no synchronized needed for reads, since networkCounter is an int
    //return self.networkCounter != 0;
    return FALSE;
}

#pragma mark - Unorganized

- (UIImage *)scaleImage:(UIImage *)image 
                 toSize:(CGSize)targetSize
{
    //If scaleFactor is not touched, no scaling will occur      
    CGFloat scaleFactor = 1.0;
    
    if (!((scaleFactor = (targetSize.width / image.size.width)) > (targetSize.height / image.size.height))) //scale to fit width, or
        scaleFactor = targetSize.height / image.size.height; // scale to fit heigth.
    
    UIGraphicsBeginImageContext(targetSize); 
    
    //Creating the rect where the scaled image is drawn in
    CGRect rect = CGRectMake((targetSize.width - image.size.width * scaleFactor) / 2,
                             (targetSize.height -  image.size.height * scaleFactor) / 2,
                             image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    [image drawInRect:rect];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


- (void)downloadSharerImage:(Video *)video
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:video.sharerImageURL];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (NOT_NULL(data)) {
        
        // resize down to the largest size we use anywhere. this should speed up table view scrolling.
        video.sharerImage = [self scaleImage:[UIImage imageWithData:data] toSize:CGSizeMake(kMaxSharerImageWidth,
                                                                                            kMaxSharerImageHeight)];
        
        [delegate updateVideoTableCell:video];
        [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:[VideoCoreDataInterface class] selector:@selector(storeSharerImage:) object:video] autorelease]];
    }
    
    [pool release];
}


- (void)downloadVideoThumbnail:(Video *)video
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        return;
    }
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:video.thumbnailURL];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (NOT_NULL(data)) {
        // resize down to the largest size we use anywhere. this should speed up table view scrolling.
        video.thumbnailImage = [self scaleImage:[UIImage imageWithData:data] toSize:CGSizeMake(kMaxVideoThumbnailWidth,
                                                                                               kMaxVideoThumbnailHeight)];
        
        [delegate updateVideoTableCell:video];
        [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:[VideoCoreDataInterface class] selector:@selector(storeVideoThumbnail:) object:video] autorelease]];
    } 
    
    [pool release];
}


- (BOOL)checkVimeoPlayable:(NSString *)providerId
{
    if ([providerId isEqualToString:[NSString stringWithFormat:@"%d", [providerId intValue]]])
    {
        return TRUE;
    } else {
        return FALSE;
    }
    
//    NSError *error = nil;
//    NSString *requestString = [NSString stringWithFormat:@"http://vimeo.com/api/v2/video/%@.json", providerId];    
//    NSString *vimeoVideoData = [[[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:requestString] encoding:NSASCIIStringEncoding error:&error] autorelease];
//    
//    NSRange mobileURL = [vimeoVideoData rangeOfString:@"\"mobile_url\""];
//    
//    if (mobileURL.location == NSNotFound) { // means there's no mobile version
//        return FALSE;
//    }
}

- (BOOL)checkYouTubePlayable:(NSString *)providerId
{
    NSError *error = nil;
    NSString *requestString = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos/%@?v=2", providerId];    
    NSString *youTubeVideoData = [[[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:requestString] encoding:NSASCIIStringEncoding error:&error] autorelease];
    
    NSRange syndicateDenied = [youTubeVideoData rangeOfString:@"yt:accessControl action='syndicate' permission='denied'"];
    NSRange syndicateLimited = [youTubeVideoData rangeOfString:@"yt:state name='restricted' reasonCode='limitedSyndication'"];
    NSRange liveEvent = [youTubeVideoData rangeOfString:@"http://gdata.youtube.com/schemas/2007#live.event"];
    
    if (syndicateDenied.location != NSNotFound || syndicateLimited.location != NSNotFound || liveEvent.location != NSNotFound) { 
        // means syndication on mobile devices is disallowed or it's a live event
        return FALSE;
    }
    
    return TRUE;
}

- (void)checkPlayable:(Video *)video
{    
    BOOL needsCoreDataUpdate = FALSE;
    
    if (video.isPlayable == PLAYABLE_UNSET || [ShelbyApp sharedApp].demoModeEnabled) {
        needsCoreDataUpdate = TRUE;
        
        // assume NOT_PLAYABLE, override if PLAYABLE
        video.isPlayable = NOT_PLAYABLE;
        
        if ([ShelbyApp sharedApp].demoModeEnabled) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.mp4", video.provider, video.providerId]];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) 
            {
                video.contentURL = [NSURL fileURLWithPath:path];
                video.isPlayable = IS_PLAYABLE;
            }
        } else {
            if ([video.provider isEqualToString: @"vimeo"] &&
                [self checkVimeoPlayable:video.providerId]) {
                video.isPlayable = IS_PLAYABLE;
            }
            if ([video.provider isEqualToString: @"youtube"] &&
                [self checkYouTubePlayable:video.providerId]) {
                video.isPlayable = IS_PLAYABLE;
            }
        }
    }
    
    if (video.isPlayable == IS_PLAYABLE && self.delegate) {
        [delegate videoTableNeedsUpdate];
    }

    if (needsCoreDataUpdate && self.delegate) {
        [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:[VideoCoreDataInterface class] selector:@selector(storePlayableStatus:) object:video] autorelease]];
    }
}

- (void)clearPendingOperations
{
    @synchronized(self)
    {
        [operationQueue cancelAllOperations];
    }
}

- (void)loadSharerImageFromCoreData:(Video *)video
{
    [VideoCoreDataInterface loadSharerImageFromCoreData:video];
    [delegate updateVideoTableCell:video];
}

- (void)loadVideoThumbnailFromCoreData:(Video *)video
{
    [VideoCoreDataInterface loadVideoThumbnailFromCoreData:video];
    [delegate updateVideoTableCell:video];
}

- (void)scheduleCheckPlayable:(Video *)video
{
    [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(checkPlayable:) object:video] autorelease]];
}

- (void)scheduleImageAcquisitionWithBroadcast:(Broadcast *)broadcast withVideo:(Video *)video;
{
    // need the sharerImage even for dupes
    if (IS_NULL(broadcast.sharerImage)) {
        [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadSharerImage:) object:video] autorelease]];
    } else {
        [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadSharerImageFromCoreData:) object:video] autorelease]];
    }
    
    // could optimize to not re-download for dupes, but don't bother for now...
    if (IS_NULL(broadcast.thumbnailImage)) {
        [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadVideoThumbnail:) object:video] autorelease]];
    } else {
        [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadVideoThumbnailFromCoreData:) object:video] autorelease]];
    }
}

- (void)suspendOperations
{
    [operationQueue setSuspended:YES];
}

- (void)resumeOperations
{
    [operationQueue setSuspended:NO];
}

@end

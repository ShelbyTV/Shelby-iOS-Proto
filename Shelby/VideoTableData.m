//
//  VideoTableData.m
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoTableData.h"
#import "Broadcast.h"
#import "ShelbyApp.h"
#import "NSURLConnection+AsyncBlock.h"
#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"
#import "Video.h"

#define kMaxVideoThumbnailHeight 163
#define kMaxVideoThumbnailWidth 290
#define kMaxSharerImageHeight 45
#define kMaxSharerImageWidth 45

@interface VideoDataURLRequest : NSURLRequest
@property (nonatomic, retain) Video *video;
@end

@implementation VideoDataURLRequest
@synthesize video;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) dealloc
{
    [video release];
    
    [super dealloc];
}
@end

@interface VideoTableData ()
// redeclare as readwrite for internal use; setter still accessible, but should generate
// compiler warnings if used outside
@property (readwrite) NSInteger networkCounter;
@end

@implementation VideoTableData

@synthesize delegate;
@synthesize networkCounter;
@synthesize likedOnly;

- (void)incrementNetworkCounter
{
    // sync just needed for writes to make sure two simultaneous inc/decrements don't result in same value
    // this is because OSAtomicInc* doesn't exist on iOS
    @synchronized(self)
    {
        self.networkCounter++;
    }
}

- (void)decrementNetworkCounter
{
    // sync just needed for writes to make sure two simultaneous inc/decrements don't result in same value
    // this is because OSAtomicDec* doesn't exist on iOS
    @synchronized(self)
    {
        self.networkCounter--;
    }
}


- (BOOL)isLoading
{
    // no synchronized needed for reads, since networkCounter is an int
    return self.networkCounter != 0;
}

- (NSUInteger)numItemsInserted
{
    return lastInserted;

}

- (NSUInteger)numItems
{
    @synchronized(videoDataArray)
    {
        return [videoDataArray count];
    }
}

#pragma mark - Index Methods

- (NSString *)videoShelbyIdAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [[videoDataArray objectAtIndex:index] shelbyId];
    }
}

- (NSString *)videoTitleAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [[videoDataArray objectAtIndex:index] title];
    }
}

- (NSString *)videoSharerAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(Video *)[videoDataArray objectAtIndex:index] sharer];
    }
}

- (UIImage *)videoSharerImageAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(Video *)[videoDataArray objectAtIndex:index] sharerImage];
    }
}

- (NSString *)videoSharerCommentAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(Video *)[videoDataArray objectAtIndex:index] sharerComment];
    }
}

- (UIImage *)videoThumbnailAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(Video *)[videoDataArray objectAtIndex:index] thumbnailImage];
    }
}

- (NSString *)videoSourceAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(Video *)[videoDataArray objectAtIndex:index] source];
    }
}

- (NSDate *)videoCreatedAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(Video *)[videoDataArray objectAtIndex:index] createdAt];
    } 
}

- (BOOL)videoLikedAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(Video *)[videoDataArray objectAtIndex:index] isLiked];
    } 
}

- (BOOL)videoWatchedAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(Video *)[videoDataArray objectAtIndex:index] isWatched];
    } 
}

- (Video *)videoAtIndex:(NSUInteger)index
{
    return (Video *)[videoDataArray objectAtIndex:index];
}

#ifdef OFFLINE_MODE
// DEBUG Only
- (NSURL *)movieURL
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath = [bundle
        pathForResource:@"SampleMovie"
                 ofType:@"mov"];
    if (moviePath) {
        return [NSURL fileURLWithPath:moviePath];
    } else {
        return nil;
    }
}
#endif

- (NSURL *)videoContentURLAtIndex:(NSUInteger)index
{
#ifdef OFFLINE_MODE
    return [self movieURL];
#else
    Video *videoData = nil;
    NSURL *contentURL = nil;

    @synchronized(videoDataArray)
    {
        if (index >= [videoDataArray count])
        {
            // something racy happened, and our index is no longer valid
            return nil;
        }
        videoData = [[[videoDataArray objectAtIndex:index] retain] autorelease];
    }

    contentURL = [[[[videoDataArray objectAtIndex:index] contentURL] retain] autorelease];

    if (contentURL == nil) {

        /*
         * Content URL
         */

        NSURL *youTubeURL = videoData.youTubeVideoInfoURL;
        NSError *error = nil;
        NSString *youTubeVideoDataRaw = [[NSString alloc] initWithContentsOfURL:youTubeURL encoding:NSASCIIStringEncoding error:&error];
        NSString *youTubeVideoDataReadable = [[[[youTubeVideoDataRaw stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"%2C" withString:@","] stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];

        /*
         * The code below tries to parse out the MPEG URL from a YouTube video info page.
         * We have to do this because YouTube encodes some parameters into the string
         * that make it valid only on the machine that accessed the YouTube video URL.
         */

        // useful for debugging
        // LOG(@"%@", youTubeVideoDataReadable);

        NSRange statusFailResponse = [youTubeVideoDataReadable rangeOfString:@"status=fail"];

        if (statusFailResponse.location == NSNotFound) { // means we probably got good data; still need better error checking

            NSRange format18 = [youTubeVideoDataReadable rangeOfString:@"itag=18"];
            NSRange roughMpegHttpStream;
            roughMpegHttpStream.location = 0;
            roughMpegHttpStream.length = format18.location;

            NSRange mpegHttpStreamStart = [youTubeVideoDataReadable rangeOfString:@"url=http" options:NSBackwardsSearch range:roughMpegHttpStream];

            roughMpegHttpStream.location = mpegHttpStreamStart.location;
            roughMpegHttpStream.length = [youTubeVideoDataReadable length] - mpegHttpStreamStart.location;

            NSRange httpAtStart = [youTubeVideoDataReadable rangeOfString:@"http" options:0 range:roughMpegHttpStream];

            NSRange fallbackHostAtEnd = [youTubeVideoDataReadable rangeOfString:@"&fallback_host" options:0 range:roughMpegHttpStream];

            NSRange finalMpegHttpStream;
            finalMpegHttpStream.location = httpAtStart.location;
            finalMpegHttpStream.length = fallbackHostAtEnd.location - httpAtStart.location;

            NSString *movieURLString = [[youTubeVideoDataReadable substringWithRange:finalMpegHttpStream] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

            // useful for debugging YouTube page changes
            LOG(@"movieURLString = %@", movieURLString);

            videoData.contentURL = contentURL = [[NSURL URLWithString:movieURLString] retain];
        }
    }

    return contentURL;
#endif
}

- (void)updateTableVideoThumbnail:(Video *)video
{
    @synchronized(videoDataArray)
    {
        // might be able to do this faster by just storing the index in the Video
        int videoIndex = [videoDataArray indexOfObject:video];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:videoIndex inSection:0]];
        
        // sucks that this knowledge is leaking out of VideoTableViewController... need to make this nicer
        UIImageView *videoThumbnail = (UIImageView *)[cell viewWithTag:2];
        videoThumbnail.image = video.thumbnailImage;
    }
}

- (void)updateTableSharerImage:(Video *)video
{
    @synchronized(videoDataArray)
    {
        // might be able to do this faster by just storing the index in the Video
        int videoIndex = [videoDataArray indexOfObject:video];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:videoIndex inSection:0]];
        
        // sucks that this knowledge is leaking out of VideoTableViewController... need to make this nicer
        UIImageView *sharerImage = (UIImageView *)[cell viewWithTag:4];
        sharerImage.image = video.sharerImage;
    }
}

// helper method -- maybe better to just embed in this file?
+ (NSString *)createYouTubeVideoInfoURLWithVideo:(NSString *)video
{
    assert(NOT_NULL(video));
    NSString *baseURL = @"http://www.youtube.com/get_video_info?video_id=";
    return [baseURL stringByAppendingString:video];
}


/*
 * Cancel any pending operations, bump array generation number so any in-flight ops are no-ops,
 * clear the existing video table, and update the table view to delete all entries
 */
- (void)clearVideos
{
    @synchronized(videoDataArray)
    {
        [videoDataArray removeAllObjects];
        
        NSMutableArray* indexPaths = [[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < lastInserted; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        lastInserted = 0;
        [tableView endUpdates];
    }
}

- (void)downloadSharerImage:(Video *)video
{
    VideoDataURLRequest *req = [VideoDataURLRequest requestWithURL:video.sharerImageURL];
    
    if (req) {
        req.video = video;
        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedSharerImage:data:error:forRequest:)];
        [self incrementNetworkCounter];
    } else {
        // We failed to send the request. Let the caller know.
    }
}

- (void)receivedSharerImage:(NSURLResponse *)resp
                       data:(NSData *)data
                      error:(NSError *)error
                 forRequest:(NSURLRequest *)request
{
    //LOG(@"receivedSharerImage");
    
    if (NOT_NULL(error)) {
        LOG(@"receivedSharerImage error: %@", error);
    } else {
        // resize down to the largest size we use anywhere. this should speed up table view scrolling.
        ((VideoDataURLRequest*)request).video.sharerImage = [[[UIImage imageWithData:data] imageWithAlpha] resizedImageWithContentMode:UIViewContentModeScaleAspectFill 
                                                                                                                                bounds:CGSizeMake(kMaxSharerImageWidth,
                                                                                                                                                  kMaxSharerImageHeight) 
                                                                                                                  interpolationQuality:kCGInterpolationHigh];
        [self updateTableSharerImage:((VideoDataURLRequest*)request).video];
    }
    
    [self decrementNetworkCounter];
}

- (void)downloadVideoThumbnail:(Video *)video
{
    VideoDataURLRequest *req = [VideoDataURLRequest requestWithURL:video.thumbnailURL];
    
    if (req) {
        req.video = video;
        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedVideoThumbnail:data:error:forRequest:)];
        [self incrementNetworkCounter];
    } else {
        // We failed to send the request. Let the caller know.
    }
}

- (void)receivedVideoThumbnail:(NSURLResponse *)resp
                          data:(NSData *)data
                         error:(NSError *)error
                    forRequest:(NSURLRequest *)request
{
    //LOG(@"receivedVideoThumbnail");
    
    if (NOT_NULL(error)) {
        LOG(@"receivedVideoThumbnail error: %@", error);
    } else {
        // resize down to the largest size we use anywhere. this should speed up table view scrolling.
        ((VideoDataURLRequest*)request).video.thumbnailImage = [[[UIImage imageWithData:data] imageWithAlpha] resizedImageWithContentMode:UIViewContentModeScaleAspectFill 
                                                                                                                                   bounds:CGSizeMake(kMaxSharerImageWidth,
                                                                                                                                                     kMaxSharerImageHeight) 
                                                                                                                     interpolationQuality:kCGInterpolationHigh];
        [self updateTableVideoThumbnail:((VideoDataURLRequest*)request).video];
    }
    
    [self decrementNetworkCounter];
}

- (void)gotNewCoreDataBroadcasts
{
    NSLog(@"here in gotNewCoreDataBroadcasts");
    NSManagedObjectContext *context = [ShelbyApp sharedApp].context;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Broadcast" 
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel.public=0"];
    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sorter]];
    
    NSError *error = nil;
    NSArray *broadcasts = [context executeFetchRequest:fetchRequest error:&error];
    
    [fetchRequest release];
    [sorter release];
    
    if (IS_NULL(broadcasts)) {
        return;
    } 
    
    LOG(@"Found %d broadcasts for channel.public=0.", [broadcasts count]);
    
    // Clear out the old broadcasts.
    [self clearVideos];
    
    @synchronized(videoDataArray)
    {
        // Load up the new broadcasts.
        for (Broadcast *broadcast in broadcasts) {
            // For now, we only handle YouTube.
            if (IS_NULL(broadcast.provider) || ![broadcast.provider isEqualToString: @"youtube"]) {
                continue;
            }
            
            if (likedOnly && (IS_NULL(broadcast.liked) || ![broadcast.liked boolValue])) {
                continue;
            }
            
            if (IS_NULL(broadcast.providerId)) {
                continue;
            }
            
            NSURL *youTubeVideo = [[[NSURL alloc] initWithString:[VideoTableData createYouTubeVideoInfoURLWithVideo:broadcast.providerId]] autorelease];
            NSAssert(NOT_NULL(youTubeVideo), @"NSURL allocation failed. Must be out of memory. Give up.");
            
            Video *video = [[[Video alloc] init] autorelease];
            NSAssert(NOT_NULL(video), @"Video allocation failed. Must be out of memory. Give up.");
            
            NSString *sharerName = [broadcast.sharerName uppercaseString];
            if ([broadcast.origin isEqualToString:@"twitter"]) {
                sharerName = [NSString stringWithFormat:@"@%@", sharerName];
            }
            
            // We need the video to get anything done
            video.youTubeVideoInfoURL = youTubeVideo;
            
            if (NOT_NULL(broadcast.thumbnailImageUrl)) video.thumbnailURL = [NSURL URLWithString:broadcast.thumbnailImageUrl];
            if (NOT_NULL(broadcast.sharerImageUrl)) video.sharerImageURL = [NSURL URLWithString:broadcast.sharerImageUrl];
            
            SET_IF_NOT_NULL(video.shelbyId, broadcast.shelbyId);
            SET_IF_NOT_NULL(video.title, broadcast.title)
            SET_IF_NOT_NULL(video.sharer, sharerName)
            SET_IF_NOT_NULL(video.sharerComment, broadcast.sharerComment)
            SET_IF_NOT_NULL(video.source, broadcast.origin)
            SET_IF_NOT_NULL(video.createdAt, broadcast.createdAt)
            
            if (NOT_NULL(broadcast.liked)) video.isLiked = [broadcast.liked boolValue];
            if (NOT_NULL(broadcast.watched)) video.isWatched = [broadcast.watched boolValue];
            
            int index = [videoDataArray count];
            [videoDataArray addObject:video];
            
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            lastInserted = index + 1;
            [tableView endUpdates];
            
            [self downloadVideoThumbnail:video];
            [self downloadSharerImage:video];
        }
    }
    
    [self.delegate videoTableDataDidFinishRefresh:self];
}

#pragma mark - Notifications

- (void)receivedBroadcastsNotification:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(gotNewCoreDataBroadcasts) userInfo:nil repeats:NO];
}

#pragma mark - Cleanup

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: @"ReceivedBroadcasts"
                                                  object: nil];
	[super dealloc];
}

#pragma mark - Initialization

- (id)initWithUITableView:(UITableView *)linkedTableView
{
    self = [super init];
    if (self) {
        // we use this to gracefully insert new entries into the UITableView
        tableView = linkedTableView;

        lastInserted = 0;
        videoDataArray = [[NSMutableArray alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedBroadcastsNotification:)
                                                     name: @"ReceivedBroadcasts"
                                                   object: nil];
        [[ShelbyApp sharedApp] addNetworkObject: self];
    }
    return self;
}

@end

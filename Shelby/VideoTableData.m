//
//  VideoTableData.m
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoTableData.h"
#import "Broadcast.h"

@interface URLIndex : NSObject
@property (nonatomic, retain) NSURL *youTubeVideoInfoURL;
@property (nonatomic, retain) NSURL *thumbnailURL;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *sharer;
@property (nonatomic, retain) NSString *sharerComment;
@property (nonatomic, retain) NSURL *sharerImageURL;
@property (nonatomic, retain) NSString *source;
@end
@implementation URLIndex
@synthesize youTubeVideoInfoURL, thumbnailURL, title, sharer, sharerComment, sharerImageURL, source;
@end

@interface VideoData : NSObject
@property (nonatomic, retain) NSURL *youTubeVideoInfoURL;
@property (nonatomic, retain) NSURL *contentURL;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *sharer;
@property (nonatomic, retain) NSString *sharerComment;
@property (nonatomic, retain) UIImage *sharerImage;
@property (nonatomic, retain) NSString *source;
@end
@implementation VideoData
@synthesize youTubeVideoInfoURL, contentURL, thumbnailImage, title, sharer, sharerComment, sharerImage, source;
@end

@implementation VideoTableData

@synthesize delegate;

/*
 * The following should only be used to @synchronize tableView updates.
 * Using it elsewhere could result in a lock ordering problem and deadlocks.
 */
static NSString *updateTableViewSync = @"Prevents multiple concurrent tableView updates";

- (NSUInteger)numItems
{
    @synchronized(videoDataArray)
    {
        return [videoDataArray count];
    }
}

#pragma mark - Index Methods

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
        return [(VideoData *)[videoDataArray objectAtIndex:index] sharer];
    }
}

- (UIImage *)videoSharerImageAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(VideoData *)[videoDataArray objectAtIndex:index] sharerImage];
    }
}

- (NSString *)videoSharerCommentAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(VideoData *)[videoDataArray objectAtIndex:index] sharerComment];
    }
}

- (UIImage *)videoThumbnailAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(VideoData *)[videoDataArray objectAtIndex:index] thumbnailImage];
    }
}

- (NSString *)videoSourceAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(VideoData *)[videoDataArray objectAtIndex:index] source];
    }
}

#pragma mark - Loading Data

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
    VideoData *videoData = nil;
    NSURL *contentURL = nil;

    @synchronized(videoDataArray)
    {
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
            // LOG(@"movieURLString = %@", movieURLString);

            videoData.contentURL = contentURL = [[NSURL URLWithString:movieURLString] retain];
        }
    }

    return contentURL;
#endif
}

- (void)retrieveAndStoreYouTubeVideoData:(id)youTubeVideo
{
    URLIndex *youTubeVideoURLIndex = (URLIndex *)youTubeVideo;

    /*
     * Thumbnail image
     */

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:youTubeVideoURLIndex.thumbnailURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    UIImage *thumbnailImage = [[UIImage imageWithData:data] retain];

    /*
     * Sharer image
     */

    request = [NSURLRequest requestWithURL:youTubeVideoURLIndex.sharerImageURL];
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    UIImage *sharerImage = [[UIImage imageWithData:data] retain];

    /*
     * Create data object and store it
     */

    VideoData *videoData = [[[VideoData alloc] init] retain];

    videoData.youTubeVideoInfoURL = youTubeVideoURLIndex.youTubeVideoInfoURL;
    videoData.contentURL = nil;
    videoData.thumbnailImage = thumbnailImage;
    videoData.title = youTubeVideoURLIndex.title;
    videoData.sharer = youTubeVideoURLIndex.sharer;
    videoData.sharerComment = youTubeVideoURLIndex.sharerComment;
    videoData.sharerImage = sharerImage;
    videoData.source = youTubeVideoURLIndex.source;

    @synchronized(videoDataArray)
    {
        [videoDataArray addObject:videoData];
    }

    [youTubeVideo release];
}

- (void)updateTableView
{
    /*
     * We need to be careful with lock ordering here. updateTableViewSync needs to be
     * ordered correctly with the videoDataArray synchronization variable.
     */
    @synchronized(updateTableViewSync)
    {
        NSUInteger currentCount;

        @synchronized(videoDataArray)
        {
            currentCount = [videoDataArray count];

            if (lastInserted != currentCount) {
                NSMutableArray* indexPaths = [[[NSMutableArray alloc] init] autorelease];

                for (int i = lastInserted; i < currentCount; i++) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }

                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                [tableView endUpdates];

                lastInserted = currentCount;
            }
        }
    }
}

// helper method -- maybe better to just embed in this file?
+ (NSString *)createYouTubeVideoInfoURLWithVideo:(NSString *)video
{
    assert(NOTNULL(video));
    NSString *baseURL = @"http://www.youtube.com/get_video_info?video_id=";
    return [baseURL stringByAppendingString:video];
}

- (void)clearVideos
{
    /*
     * We need to be careful with lock ordering here. updateTableViewSync needs to be
     * ordered correctly with the videoDataArray synchronization variable.
     */
    @synchronized(updateTableViewSync)
    {
        @synchronized(videoDataArray)
        {
            [videoDataArray removeAllObjects];
            lastInserted = 0;
        }

        [tableView reloadData];
    }
}

/**
 * This method called when we've pulled down new data from the API.
 */
- (void)gotNewJSONBroadcasts:(NSArray *)broadcasts
{
    // Clear out the old broadcasts.
    [self clearVideos];

    // Load up the new broadcasts.
    for (NSDictionary *broadcast in broadcasts) {
        if ([[broadcast objectForKey: @"video_provider_name"] isEqualToString: @"youtube"]) {
            NSString *videoId      = [broadcast objectForKey: @"video_id_at_provider"];
            NSString *thumbnailUrl = [broadcast objectForKey: @"video_thumbnail_url"];
            NSString *title        = [broadcast objectForKey: @"video_title"];
            //NSString *description  = [broadcast objectForKey: @"video_description"];

            NSString *comment      = [broadcast objectForKey: @"description"];
            NSString *sharerName = [[broadcast objectForKey: @"video_originator_user_nickname"] uppercaseString];
            if ([[broadcast objectForKey: @"video_origin"] isEqualToString:@"twitter"]) {
                sharerName = [NSString stringWithFormat:@"@%@", sharerName]; 
            }
            NSString *sharerThumbnailUrl   = [broadcast objectForKey: @"video_originator_user_image"];
            NSString *source = [broadcast objectForKey: @"video_origin"];

            NSURL *youTubeVideo;
            if (NOTNULL(videoId)) {
                youTubeVideo = [[NSURL alloc] initWithString:[VideoTableData createYouTubeVideoInfoURLWithVideo: videoId]];
            }

            if (NOTNULL(youTubeVideo)) {
                URLIndex *video = [[URLIndex alloc] init];

                // We need the video to get anything done
                video.youTubeVideoInfoURL = youTubeVideo;
                if (NOTNULL(thumbnailUrl)) video.thumbnailURL = [NSURL URLWithString: thumbnailUrl];
                if (NOTNULL(title)) video.title = title;

                if (NOTNULL(sharerName)) video.sharer = sharerName;
                if (NOTNULL(comment)) video.sharerComment = comment;
                if (NOTNULL(sharerThumbnailUrl)) video.sharerImageURL = [NSURL URLWithString: sharerThumbnailUrl];
                if (NOTNULL(source)) video.source = source;

                NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                      selector:@selector(retrieveAndStoreYouTubeVideoData:)
                                                                                        object:video];

                [operationQueue addOperation:operation];
            }
        }
        // For now, we only handle YouTube.
    }
}

- (void)gotNewCoreDataBroadcasts:(NSArray *)broadcasts
{
    //for (Broadcast *broadcast in broadcasts) {
    //    if ([broadcast.provider isEqualToString: @"youtube"]) {
    //        // We only handle youtube for now.
    //        if (NOTNULL(broadcast.providerId)) {
    //            youTubeVideo = [[NSURL alloc] initWithString:[VideoTableData createYouTubeVideoInfoURLWithVideo: videoId]];
    //        }

    //        if (NOTNULL(youTubeVideo)) {
    //            URLIndex *video = [[URLIndex alloc] init];

    //            // We need the video to get anything done
    //            video.youTubeVideoInfoURL = youTubeVideo;
    //            if (NOTNULL(thumbnailUrl)) video.thumbnailURL = [NSURL URLWithString: thumbnailUrl];
    //            if (NOTNULL(title)) video.title = title;

    //            if (NOTNULL(sharerName)) video.sharer = sharerName;
    //            if (NOTNULL(comment)) video.sharerComment = comment;
    //            if (NOTNULL(sharerThumbnailUrl)) video.sharerImageURL = [NSURL URLWithString: sharerThumbnailUrl];

    //            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
    //                                                                                    selector:@selector(retrieveAndStoreYouTubeVideoData:)
    //                                                                                      object:video];

    //            [operationQueue addOperation:operation];
    //        }
    //    }
    //}
}

#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == operationQueue && [keyPath isEqualToString:@"operations"]) {
        if ([operationQueue.operations count] == 0) {
            LOG(@"queue has completed");
            if (self.delegate) {
                // Inform the delegate
                [self.delegate videoTableDataDidFinishRefresh: self];
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}

#pragma mark - Notifications

- (void)receivedBroadcastsNotification:(NSNotification *)notification
{
    NSArray *broadcasts = [notification.userInfo objectForKey: @"broadcasts"];
    [self gotNewJSONBroadcasts: broadcasts];
    //[self gotNewCoreDataBroadcasts: broadcasts];
}

#pragma mark - Cleanup

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: @"LoginHelperReceivedBroadcasts"
                                                  object: nil];
	[super dealloc];
}

#pragma mark - Initialization

- (id)initWithUITableView:(UITableView *)linkedTableView
{
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount: 2];
        [operationQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];

        // we use this to gracefully insert new entries into the UITableView
        tableView = linkedTableView;

        lastInserted = 0;

        // use timer so that updates to the UITableView are smoothly animated, coming in once per second
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTableView) userInfo:nil repeats:YES];

        videoDataArray = [[NSMutableArray alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedBroadcastsNotification:)
                                                     name: @"LoginHelperReceivedBroadcasts"
                                                   object: nil];
    }

    return self;
}

@end

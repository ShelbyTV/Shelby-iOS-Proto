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
 * Eventually we'll be getting data like this from the Shelby API -- the "broadcast" data
 * structure should pretty much have this data and more.
 *
 * For now we just pretend like we did the initial call to get all this data, and now we just
 * have to download the thumbnails and parse the YouTube pages to get the MPEG URLs.
 *
 * It seems okay to include the YouTube MPEG URLs in this object even though it's not displayed
 * in the actual table Cell -- this way videos load more quickly after being selected, and it *is*
 * data associated with videos in the table.
 */

static NSString *fakeAPIData[] = {
    @"http://i1.ytimg.com/vi/4NW3RLnXmTY/hqdefault.jpg",@"How the KKK got beat by 1 black guy",                                               @"4NW3RLnXmTY",@"balls!",@"http://graph.facebook.com/227700022/picture",@"Timothy Kua",
    @"http://i4.ytimg.com/vi/CJQU22Ttpwc/hqdefault.jpg",@"Reggie Watts:  F_ck Sh_t Stack",                                                    @"CJQU22Ttpwc",@"it's a stack!\n",@"http://graph.facebook.com/503482796/picture",@"Emily Zisman",
    @"http://i2.ytimg.com/vi/MevXQ-pJabk/hqdefault.jpg",@"We Can (Do Anything) - Michael Olaf",                                               @"MevXQ-pJabk",@"Please do \"Like\" and \"Share\" this. Thanks all!  \n\nhttp://www.youtube.com/watch?v=MevXQ-pJabk&playnext=1&list=PL9AC51F62C064A343",@"http://graph.facebook.com/133215493364547/picture",@"Michael Olaf",
    @"http://i2.ytimg.com/vi/iiIpOK46LYg/hqdefault.jpg",@"Sean Maloney rowing video",                                                         @"iiIpOK46LYg",@"This guy is amazing. Not just as a leader of Intel, but as an inspirational person.",@"http://graph.facebook.com/1080368082/picture",@"Rashmi Bachrach",
    @"http://i3.ytimg.com/vi/bDRTzmuwMnQ/hqdefault.jpg",@"Awake Endotracheal Intubation",                                                     @"bDRTzmuwMnQ",@"Freaking AMAZING.  ",@"http://graph.facebook.com/821955396/picture",@"Molly Drum",
    @"http://i3.ytimg.com/vi/njmHh0Egihw/hqdefault.jpg",@"Sleigh Bells seq",                                                                  @"njmHh0Egihw",@"yeah!",@"http://graph.facebook.com/683079809/picture",@"Torie McHone Westendorf",
    @"http://i2.ytimg.com/vi/-znHzHafMlQ/hqdefault.jpg",@"Football Cops Trailer",                                                             @"-znHzHafMlQ",@"This will do until the NFL season starts.",@"http://graph.facebook.com/29909625/picture",@"Victor Costa",
    @"http://i3.ytimg.com/vi/bbCT6_HAOmM/hqdefault.jpg",@"'Beats, Rhymes & Life: The Travels of a Tribe Called Quest' Trailer",               @"bbCT6_HAOmM",@"Looks like it could be good.",@"http://graph.facebook.com/897435213/picture",@"Ken Deeter",
    @"http://i2.ytimg.com/vi/uhNPTbbINxs/hqdefault.jpg",@"America's Got Talent - Team iLuminate NEW!",                                        @"uhNPTbbINxs",@"Is this how groups get their break now?",@"http://graph.facebook.com/897435213/picture",@"Ken Deeter",
    @"http://i2.ytimg.com/vi/9gQriejr-O0/hqdefault.jpg",@"MICappella - Video invite to our 2011 EP launch concert!",                          @"9gQriejr-O0",@"doin a shout-out for some pals of mine from e awesome acappella group micappella, they're holding a concert on july 15th...go watch go watch go watch...Adrian Yuen Mark Cheng",@"http://graph.facebook.com/227700022/picture",@"Timothy Kua",
    @"http://i1.ytimg.com/vi/H3GiqHm5rQA/hqdefault.jpg",@"Two Awesome Dancing Kids",                                                          @"H3GiqHm5rQA",@"Wow!",@"http://graph.facebook.com/1080368082/picture",@"Rashmi Bachrach",
    @"http://i2.ytimg.com/vi/ap-Xvb7KRrc/hqdefault.jpg",@"You and Tequila HD- Kenny Chesney ft. Grace Potter (with lyrics)",                  @"ap-Xvb7KRrc",@"*NO COPYRIGHT INFRINGEMENT INTENDED* Disclaimer: All material belongs to their appropriate owners. I do not own anything. This is purely a fan-made video, fo...",@"http://graph.facebook.com/40504819/picture",@"Ashley Chunn",
    @"http://i2.ytimg.com/vi/uk2bias6yCU/hqdefault.jpg",@"Life On Jupiter - Michael Olaf",                                                    @"uk2bias6yCU",@"Please \"Like\" and \"Share.\"  Thanks everybody!  \n\nhttp://www.youtube.com/watch?v=uk2bias6yCU",@"http://graph.facebook.com/133215493364547/picture",@"Michael Olaf",
    @"http://i3.ytimg.com/vi/fnGc96M7qbk/hqdefault.jpg",@"These Images (Demo Version) - Michael Olaf",                                        @"fnGc96M7qbk",@"An older song.  Enjoy!  http://www.youtube.com/watch?v=fnGc96M7qbk&feature=grec_index",@"http://graph.facebook.com/133215493364547/picture",@"Michael Olaf",
    @"http://i4.ytimg.com/vi/saWCZVggQAs/hqdefault.jpg",@"PSA for Teabaggers",                                                                @"saWCZVggQAs",@"\"government is the problem, and now you have Cholera.\"",@"http://graph.facebook.com/503482796/picture",@"Emily Zisman",
    @"http://i3.ytimg.com/vi/2FjZkJJx3bc/hqdefault.jpg",@"Chinese 9 Yrs old girl shuffling",                                                  @"2FjZkJJx3bc",@"Adrian Yuen, keep practicing man...hopefully this inspires u more.",@"http://graph.facebook.com/227700022/picture",@"Timothy Kua",
    @"http://i4.ytimg.com/vi/OCt6M3bNVW0/hqdefault.jpg",@"Weird Al Yankovic - Whatever You Like - Lyrics",                                    @"OCt6M3bNVW0",@"http://www.youtube.com/watch?v=OCt6M3bNVW0  This how a good man treats his lady..",@"http://graph.facebook.com/570821565/picture",@"Adam Desautels",
    @"http://i4.ytimg.com/vi/C4YhbpuGdwQ/hqdefault.jpg",@"The Muppets Official Trailer",                                                      @"C4YhbpuGdwQ",@"Adrian Yuen, Mark Cheng, Joanna Foo...we. must. watch.",@"http://graph.facebook.com/227700022/picture",@"Timothy Kua",
    @"http://i1.ytimg.com/vi/dDVv6_YwOf4/hqdefault.jpg",@"Tia Carroll - TV Show - (Todo Seu) - Ronnie Von - SP/BRAZIL - \"Purple Rain\"",     @"dDVv6_YwOf4",@"My girl, Tia Carroll <3  ",@"http://graph.facebook.com/503482796/picture",@"Emily Zisman",
    @"http://i1.ytimg.com/vi/PgNqe7m5kK4/hqdefault.jpg",@"Billie Jean, The Civil Wars",                                                       @"PgNqe7m5kK4",@"yeah....",@"http://graph.facebook.com/503482796/picture",@"Emily Zisman",
    @"http://i1.ytimg.com/vi/lSTS4aS1BBs/hqdefault.jpg",@"ABW 2011 - Jam 6_12",                                                               @"lSTS4aS1BBs",@"Good stuff!",@"http://graph.facebook.com/4706141/picture",@"Abigail Browning",
    @"http://i2.ytimg.com/vi/m6tiaooiIo0/hqdefault.jpg",@"Stephen Colbert 2011 Commencement Speech at Northwestern University",               @"m6tiaooiIo0",@"Pardon the capture errors.",@"http://graph.facebook.com/5521514/picture",@"Adarsh Jagadeeshwaran",
    @"http://i2.ytimg.com/vi/Ul_NLXwmxVs/hqdefault.jpg",@"\"It Gets Better: CBS Employees\"",                                                 @"Ul_NLXwmxVs",@"My awesome coworkers reach out to GLBT teens, including the extra-awesome Danny Chung",@"http://graph.facebook.com/500073814/picture",@"Jessica Dolcourt",
};


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

- (BOOL)isLoading
{
    return ([operationQueue.operations count] != 0);
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
 * Loads videos from dummy data.
 */
- (void)loadVideos
{
    for (int i = 0; i < 23; i++) {
        NSURL *youTubeVideo = [[NSURL alloc] initWithString:[VideoTableData createYouTubeVideoInfoURLWithVideo:fakeAPIData[i * 6 + 2]]];
        URLIndex *youTubeVideoIndex = [[URLIndex alloc] init];
        youTubeVideoIndex.youTubeVideoInfoURL = youTubeVideo;

        NSURL *thumbnailURL = [[NSURL alloc] initWithString:fakeAPIData[i * 6]];
        youTubeVideoIndex.thumbnailURL = thumbnailURL;

        youTubeVideoIndex.title = fakeAPIData[i * 6 + 1];
        youTubeVideoIndex.sharer = fakeAPIData[i * 6 + 5];
        youTubeVideoIndex.sharerComment = fakeAPIData[i * 6 + 3];
        youTubeVideoIndex.sharerImageURL = [[NSURL alloc] initWithString:fakeAPIData[i * 6 + 4]];

        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(retrieveAndStoreYouTubeVideoData:)
                                                                                  object:youTubeVideoIndex];

        [operationQueue addOperation:operation];
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

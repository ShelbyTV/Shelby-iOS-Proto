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


@interface URLIndex : NSObject
@property (nonatomic, retain) NSURL *youTubeVideoInfoURL;
@property (nonatomic, retain) NSURL *thumbnailURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sharer;
@property (nonatomic, copy) NSString *sharerComment;
@property (nonatomic, retain) NSURL *sharerImageURL;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *shelbyId;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic) BOOL isLiked;
@property (nonatomic) BOOL isWatched;
@property (readwrite) NSUInteger arrayGeneration;
@end
@implementation URLIndex
@synthesize youTubeVideoInfoURL, thumbnailURL, title, sharer, sharerComment, sharerImageURL, source, createdAt, shelbyId, isLiked, isWatched, arrayGeneration;

- (void) dealloc
{
    [youTubeVideoInfoURL release];
    [thumbnailURL release];
    [title release];
    [sharer release];
    [sharerComment release];
    [sharerImageURL release];
    [source release];
    [createdAt release];
    
    [super dealloc];
}
@end

@interface VideoData : NSObject
@property (nonatomic, retain) NSURL *youTubeVideoInfoURL;
@property (nonatomic, retain) NSURL *contentURL;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sharer;
@property (nonatomic, copy) NSString *sharerComment;
@property (nonatomic, retain) UIImage *sharerImage;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *shelbyId;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic) BOOL isLiked;
@property (nonatomic) BOOL isWatched;
@end
@implementation VideoData
@synthesize youTubeVideoInfoURL, contentURL, thumbnailImage, title, sharer, sharerComment, sharerImage, source, createdAt, shelbyId, isLiked, isWatched;

- (void) dealloc
{
    [youTubeVideoInfoURL release];
    [contentURL release];
    [thumbnailImage release];
    [title release];
    [sharer release];
    [sharerComment release];
    [sharerImage release];
    [source release];
    [createdAt release];
    
    [super dealloc];
}
@end

@implementation VideoTableData

@synthesize delegate;
@synthesize networkCounter;
@synthesize likedOnly;

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

- (NSUInteger)numItemsInserted
{
    // We reuse the videoDataArray lock here for simplicity -- mostly trying to proect this and updateTableView races
    @synchronized(videoDataArray)
    {
        return lastInserted;
    }
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

- (NSDate *)videoCreatedAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(VideoData *)[videoDataArray objectAtIndex:index] createdAt];
    } 
}

- (BOOL)videoLikedAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(VideoData *)[videoDataArray objectAtIndex:index] isLiked];
    } 
}

- (BOOL)videoWatchedAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [(VideoData *)[videoDataArray objectAtIndex:index] isWatched];
    } 
}

#pragma mark - Loading Data

- (BOOL)isLoading
{
    return self.networkCounter != 0;
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

- (void)retrieveAndStoreYouTubeVideoData:(id)youTubeVideo
{
    URLIndex *youTubeVideoURLIndex = (URLIndex *)youTubeVideo;
    
    // early exit if user's been switching channels
    if (youTubeVideoURLIndex.arrayGeneration != currentArrayGeneration) {
        return;
    }

    /*
     * Thumbnail image
     */

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:youTubeVideoURLIndex.thumbnailURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    UIImage *thumbnailImage = [UIImage imageWithData:data];

    /*
     * Sharer image
     */

    request = [NSURLRequest requestWithURL:youTubeVideoURLIndex.sharerImageURL];
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    UIImage *sharerImage = [UIImage imageWithData:data];

    /*
     * Create data object and store it
     */

    VideoData *videoData = [[[VideoData alloc] init] autorelease];

    videoData.youTubeVideoInfoURL = youTubeVideoURLIndex.youTubeVideoInfoURL;
    videoData.contentURL = nil;
    videoData.thumbnailImage = thumbnailImage;
    videoData.title = youTubeVideoURLIndex.title;
    videoData.sharer = youTubeVideoURLIndex.sharer;
    videoData.sharerComment = youTubeVideoURLIndex.sharerComment;
    videoData.sharerImage = sharerImage;
    videoData.source = youTubeVideoURLIndex.source;
    videoData.shelbyId = youTubeVideoURLIndex.shelbyId;
    videoData.createdAt = youTubeVideoURLIndex.createdAt;
    videoData.isLiked = youTubeVideoURLIndex.isLiked;
    videoData.isWatched = youTubeVideoURLIndex.isWatched;

    @synchronized(videoDataArray)
    {
        // this makes sure we don't accidentally keep adding videos when people switch channels
        if (youTubeVideoURLIndex.arrayGeneration == currentArrayGeneration) {
            [videoDataArray addObject:videoData];
        }
    }

    [youTubeVideo release];
}

- (void)updateTableView
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
            lastInserted = currentCount;
            [tableView endUpdates];
        }
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
        currentArrayGeneration++;
        //[operationQueue cancelAllOperations];
        
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
        youTubeVideoIndex.arrayGeneration = currentArrayGeneration;

        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(retrieveAndStoreYouTubeVideoData:)
                                                                                  object:youTubeVideoIndex];

        @synchronized(videoDataArray)
        {
            [operationQueue addOperation:operation];
        }
    }
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
        
        NSURL *youTubeVideo = [[NSURL alloc] initWithString:[VideoTableData createYouTubeVideoInfoURLWithVideo:broadcast.providerId]];
        NSAssert(NOT_NULL(youTubeVideo), @"NSURL allocation failed. Must be out of memory. Give up.");
        
        
        URLIndex *video = [[URLIndex alloc] init];
        NSAssert(NOT_NULL(video), @"URLIndex allocation failed. Must be out of memory. Give up.");
        
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
                
        video.arrayGeneration = currentArrayGeneration;
        
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(retrieveAndStoreYouTubeVideoData:)
                                                                                  object:video];
        
        @synchronized(videoDataArray)
        {
            [operationQueue addOperation:operation];
        }
    }
}

#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == operationQueue && [keyPath isEqualToString:@"operations"]) {
        NSInteger operationCount = 0;
        @synchronized(videoDataArray)
        {
            operationCount = [operationQueue operationCount];
        }
        //id object = [change objectForKey: NSKeyValueChangeOldKey];
        //NSLog(@"Previous count: %@", object);
        //NSInteger previousCount = [object integerValue];
        if (operationCount == 0) {
            LOG(@"queue has completed");
            if (self.delegate) {
                // Inform the delegate
                [self.delegate videoTableDataDidFinishRefresh: self];
            }
            self.networkCounter = 0;
        } else {
            self.networkCounter = operationCount;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
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
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount: 2];
        [operationQueue addObserver: self
                         forKeyPath: @"operations"
                            options: NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                            context: NULL
                            ];

        // we use this to gracefully insert new entries into the UITableView
        tableView = linkedTableView;

        lastInserted = 0;

        // use timer so that updates to the UITableView are smoothly animated, coming in once per second
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTableView) userInfo:nil repeats:YES];

        videoDataArray = [[NSMutableArray alloc] init];
        currentArrayGeneration = 0;

        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedBroadcastsNotification:)
                                                     name: @"ReceivedBroadcasts"
                                                   object: nil];
        [[ShelbyApp sharedApp] addNetworkObject: self];
    }
    return self;
}

@end

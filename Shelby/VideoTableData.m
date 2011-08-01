//
//  VideoTableData.m
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoTableData.h"

@interface URLIndex : NSObject
@property (nonatomic, retain) NSURL *videoURL;
@property (nonatomic, retain) NSURL *thumbnailURL;
@property (nonatomic) NSUInteger index;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *submitter;
@end
@implementation URLIndex
@synthesize videoURL, thumbnailURL, index, title, submitter;
@end

@interface VideoData : NSObject
@property (nonatomic, retain) NSURL *youTubeURL;
@property (nonatomic, retain) NSURL *contentURL;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, retain) NSString *submitter;
@property (nonatomic, retain) NSString *title;
@end
@implementation VideoData
@synthesize youTubeURL, contentURL, thumbnailImage, submitter, title;
@end

@implementation VideoTableData

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
    @"http://i1.ytimg.com/vi/4NW3RLnXmTY/hqdefault.jpg",@"How the KKK got beat by 1 black guy",                                          @"4NW3RLnXmTY",@"Timothy Kua",                  
    @"http://i4.ytimg.com/vi/CJQU22Ttpwc/hqdefault.jpg",@"Reggie Watts:  F_ck Sh_t Stack",                                               @"CJQU22Ttpwc",@"Emily Zisman",
    @"http://i2.ytimg.com/vi/MevXQ-pJabk/hqdefault.jpg",@"We Can (Do Anything) - Michael Olaf",                                          @"MevXQ-pJabk",@"Michael Olaf",
    @"http://i2.ytimg.com/vi/iiIpOK46LYg/hqdefault.jpg",@"Sean Maloney rowing video",                                                    @"iiIpOK46LYg",@"Rashmi Bachrach",
    @"http://i3.ytimg.com/vi/bDRTzmuwMnQ/hqdefault.jpg",@"Awake Endotracheal Intubation",                                                @"bDRTzmuwMnQ",@"Molly Drum",
    @"http://i3.ytimg.com/vi/njmHh0Egihw/hqdefault.jpg",@"Sleigh Bells seq",                                                             @"njmHh0Egihw",@"Torie McHone Westendorf",
    @"http://i2.ytimg.com/vi/-znHzHafMlQ/hqdefault.jpg",@"Football Cops Trailer",                                                        @"-znHzHafMlQ",@"Victor Costa",
    @"http://i3.ytimg.com/vi/bbCT6_HAOmM/hqdefault.jpg",@"'Beats, Rhymes & Life: The Travels of a Tribe Called Quest' Trailer",          @"bbCT6_HAOmM",@"Ken Deeter",
    @"http://i2.ytimg.com/vi/uhNPTbbINxs/hqdefault.jpg",@"America's Got Talent - Team iLuminate NEW!",                                   @"uhNPTbbINxs",@"Ken Deeter",
    @"http://i2.ytimg.com/vi/9gQriejr-O0/hqdefault.jpg",@"MICappella - Video invite to our 2011 EP launch concert!",                     @"9gQriejr-O0",@"Timothy Kua",
    @"http://i1.ytimg.com/vi/H3GiqHm5rQA/hqdefault.jpg",@"Two Awesome Dancing Kids",                                                     @"H3GiqHm5rQA",@"Rashmi Bachrach",
    @"http://i2.ytimg.com/vi/ap-Xvb7KRrc/hqdefault.jpg",@"You and Tequila HD- Kenny Chesney ft. Grace Potter (with lyrics)",             @"ap-Xvb7KRrc",@"Ashley Chunn",
    @"http://i2.ytimg.com/vi/uk2bias6yCU/hqdefault.jpg",@"Life On Jupiter - Michael Olaf",                                               @"uk2bias6yCU",@"Michael Olaf",
    @"http://i3.ytimg.com/vi/fnGc96M7qbk/hqdefault.jpg",@"These Images (Demo Version) - Michael Olaf",                                   @"fnGc96M7qbk",@"Michael Olaf",
    @"http://i4.ytimg.com/vi/saWCZVggQAs/hqdefault.jpg",@"PSA for Teabaggers",                                                           @"saWCZVggQAs",@"Emily Zisman",
    @"http://i3.ytimg.com/vi/2FjZkJJx3bc/hqdefault.jpg",@"Chinese 9 Yrs old girl shuffling",                                             @"2FjZkJJx3bc",@"Timothy Kua",
    @"http://i4.ytimg.com/vi/OCt6M3bNVW0/hqdefault.jpg",@"Weird Al Yankovic - Whatever You Like - Lyrics",                               @"OCt6M3bNVW0",@"Adam Desautels",
    @"http://i4.ytimg.com/vi/C4YhbpuGdwQ/hqdefault.jpg",@"The Muppets Official Trailer",                                                 @"C4YhbpuGdwQ",@"Timothy Kua",
    @"http://i1.ytimg.com/vi/dDVv6_YwOf4/hqdefault.jpg",@"Tia Carroll - TV Show - (Todo Seu) - Ronnie Von - SP/BRAZIL - \"Purple Rain\"",@"dDVv6_YwOf4",@"Emily Zisman",
    @"http://i1.ytimg.com/vi/PgNqe7m5kK4/hqdefault.jpg",@"Billie Jean, The Civil Wars",                                                  @"PgNqe7m5kK4",@"Emily Zisman",
    @"http://i1.ytimg.com/vi/lSTS4aS1BBs/hqdefault.jpg",@"ABW 2011 - Jam 6_12",                                                          @"lSTS4aS1BBs",@"Abigail Browning",
    @"http://i2.ytimg.com/vi/m6tiaooiIo0/hqdefault.jpg",@"Stephen Colbert 2011 Commencement Speech at Northwestern University",          @"m6tiaooiIo0",@"Adarsh Jagadeeshwaran",
    @"http://i2.ytimg.com/vi/Ul_NLXwmxVs/hqdefault.jpg",@"\"It Gets Better: CBS Employees\"",                                            @"Ul_NLXwmxVs",@"Jessica Dolcourt",            
};

- (NSUInteger)numItems
{
    @synchronized(videoDataArray)
    {
        return [videoDataArray count];
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
        return [[videoDataArray objectAtIndex:index] submitter];
    }
}

- (UIImage *)videoThumbnailAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        return [[videoDataArray objectAtIndex:index] thumbnailImage];
    }
}

- (NSURL *)videoContentURLAtIndex:(NSUInteger)index
{
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
        
        NSURL *youTubeURL = videoData.youTubeURL;        
        NSError *error = nil;
        NSString *youTubeVideoDataRaw = [[NSString alloc] initWithContentsOfURL:youTubeURL encoding:NSUTF8StringEncoding error:&error];
        NSString *youTubeVideoDataReadable = [[[youTubeVideoDataRaw stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"%2C" withString:@","] stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
        
        /*
         * The code below tries to parse out the MPEG URL from a YouTube video info page.
         * We have to do this because YouTube encodes some parameters into the string
         * that make it valid only on the machine that accessed the YouTube video URL.
         */
        
        // useful for debugging
        // NSLog(@"%@", youTubeVideoDataReadable);
        
        NSRange statusFailResponse = [youTubeVideoDataReadable rangeOfString:@"status=fail"];
        
        if (statusFailResponse.location == NSNotFound) { // means we probably got good data; still need better error checking
        
            NSRange mpegHttpStreamStart = [youTubeVideoDataReadable rangeOfString:@"18|http"];
            
            NSRange roughMpegHttpStream;
            roughMpegHttpStream.location = mpegHttpStreamStart.location;
            roughMpegHttpStream.length = youTubeVideoDataReadable.length - mpegHttpStreamStart.location;
            
            NSRange pipesAtEnd = [youTubeVideoDataReadable rangeOfString:@"||" options:0 range:roughMpegHttpStream];
            NSRange httpAtStart = [youTubeVideoDataReadable rangeOfString:@"http" options:0 range:roughMpegHttpStream];
            
            NSRange finalMpegHttpStream;
            finalMpegHttpStream.location = httpAtStart.location;
            finalMpegHttpStream.length = pipesAtEnd.location - httpAtStart.location;
            
            NSString *movieURLString = [[youTubeVideoDataReadable substringWithRange:finalMpegHttpStream] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            // useful for debugging YouTube page changes
            // NSLog(@"movieURLString = %@", movieURLString);
            
            videoData.contentURL = contentURL = [[NSURL URLWithString:movieURLString] retain];
        }
    }
    
    return contentURL;
}

- (void)retrieveYouTubeThumbnailAndStoreVideoData:(id)youTubeVideo
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
     * Create data object and store it
     */
    
    VideoData *videoData = [[[VideoData alloc] init] retain];
    
    videoData.youTubeURL = youTubeVideoURLIndex.videoURL; 
    videoData.contentURL = nil;
    videoData.thumbnailImage = thumbnailImage;
    videoData.submitter = youTubeVideoURLIndex.submitter;
    videoData.title = youTubeVideoURLIndex.title;
    
    @synchronized(videoDataArray)
    {
        [videoDataArray addObject:videoData];
    }

    [youTubeVideo release];
}

- (void)updateTableView
{
    NSUInteger currentCount;
     
    @synchronized(videoDataArray)
    {
        currentCount = [videoDataArray count];
    }
    
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

// helper method -- maybe better to just embed in this file?
+ (NSString *)createYouTubeVideoInfoURLWithVideo:(NSString *)video
{
    NSString *baseURL = @"http://www.youtube.com/get_video_info?video_id=";
    return [baseURL stringByAppendingString:video];
}

- (void)loadVideos
{
    for (int i = 0; i < 23; i++) {
        NSURL *youTubeVideo = [[NSURL alloc] initWithString:[VideoTableData createYouTubeVideoInfoURLWithVideo:fakeAPIData[i * 4 + 2]]];
        URLIndex *youTubeVideoIndex = [[URLIndex alloc] init]; 
        youTubeVideoIndex.videoURL = youTubeVideo;
        youTubeVideoIndex.index = i;
        
        NSURL *thumbnailURL = [[NSURL alloc] initWithString:fakeAPIData[i * 4]];
        youTubeVideoIndex.thumbnailURL = thumbnailURL;
        
        youTubeVideoIndex.title = fakeAPIData[i * 4 + 1];
        youTubeVideoIndex.submitter = fakeAPIData[i * 4 + 3];
        
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self 
                                                                                selector:@selector(retrieveYouTubeThumbnailAndStoreVideoData:) 
                                                                                  object:youTubeVideoIndex];
        
        [operationQueue addOperation:operation];
    }
}

- (id)initWithUITableView:(UITableView *)linkedTableView
{
    self = [super init];
    if (self) {        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:2];
        
        // eventually we should use this to gracefully insert new entries into the UITableView
        tableView = linkedTableView;
        
        lastInserted = 0;
        
        // use timer so that updates to the UITableView are smoothly animated, coming in once per second
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTableView) userInfo:nil repeats:YES];
        
        videoDataArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end

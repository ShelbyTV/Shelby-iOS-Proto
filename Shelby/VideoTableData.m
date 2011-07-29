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
@property (nonatomic, retain) NSURL *contentURL;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, retain) NSString *submitter;
@property (nonatomic, retain) NSString *title;
@end
@implementation VideoData
@synthesize contentURL, thumbnailImage, submitter, title;
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
    @synchronized(videoDataArray)
    {
        return [[videoDataArray objectAtIndex:index] contentURL];
    }
}

- (void)retrieveYouTubeVideoData:(id)youTubeVideo
{
    
    /*
     * Content URL
     */
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:((URLIndex *)youTubeVideo).videoURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    /*
     * This complicated code below tries to parse out the MPEG URL from a YouTube movie page.
     * It seems like we have to do this in this way because YouTube encodes some parameters into the string
     * that make it valid only on the machine that accessed the YouTube watch URL.
     *
     * It's possible we can get around YouTube in the future server-side, or work with them to get access
     * to a private API that does it (Apple must do this).
     *
     * For now, we're working with what's publicly available and seems to work for now. We may have to adjust
     * this over time if YouTube changes their page structure.
     */
    
    NSString *utf8response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSRange mpegHttpStreamStart = [utf8response rangeOfString:@"18|http"];
    
    NSRange roughMpegHttpStream;
    roughMpegHttpStream.location = mpegHttpStreamStart.location;
    roughMpegHttpStream.length = [utf8response length] - mpegHttpStreamStart.location;
    
    NSRange commaAtEnd = [utf8response rangeOfString:@"," options:0 range:roughMpegHttpStream];
    NSRange pipesAtEnd = [utf8response rangeOfString:@"||" options:0 range:roughMpegHttpStream];
    NSRange httpAtStart = [utf8response rangeOfString:@"http" options:0 range:roughMpegHttpStream];
    
    NSAssert((commaAtEnd.location != NSNotFound) || (pipesAtEnd.location != NSNotFound), @"Accessed unparsable YouTube page!");
    
    NSRange finalMpegHttpStream;
    finalMpegHttpStream.location = httpAtStart.location;
    if (commaAtEnd.location == NSNotFound) {
        finalMpegHttpStream.length = pipesAtEnd.location - httpAtStart.location;
    } else if (pipesAtEnd.location == NSNotFound) {
        finalMpegHttpStream.length = commaAtEnd.location - httpAtStart.location;
    } else {
        finalMpegHttpStream.length = MIN(commaAtEnd.location, pipesAtEnd.location) - httpAtStart.location;
    }
        
    NSString *movieURLString = [[[[[[[utf8response substringWithRange:finalMpegHttpStream] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"] stringByReplacingOccurrencesOfString:@"%2C" withString:@","] stringByReplacingOccurrencesOfString:@"\\u0026" withString:@"&"] stringByReplacingOccurrencesOfString:@"%3A" withString:@":"] stringByReplacingOccurrencesOfString:@"%7C" withString:@"|"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 
//    useful for debugging YouTube page changes
//    NSLog(@"movieURLString = %@", movieURLString);
    
    /*
     * Thumbnail image
     */
    
    response = nil;
    error = nil;
    request = [NSURLRequest requestWithURL:((URLIndex *)youTubeVideo).thumbnailURL];
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    UIImage *thumbnailImage = [[UIImage imageWithData:data] retain];
    
    /*
     * Create data object and store it
     */
    
    VideoData *videoData = [[[VideoData alloc] init] retain];
    
    videoData.contentURL = [[NSURL URLWithString:movieURLString] retain];
    videoData.thumbnailImage = thumbnailImage;
    videoData.submitter = ((URLIndex *)youTubeVideo).submitter;
    videoData.title = ((URLIndex *)youTubeVideo).title;
    
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
+ (NSString *)createyouTubeVideoWithVideo:(NSString *)video
{
    NSString *baseURL = @"http://www.youtube.com/watch?v=";
    return [baseURL stringByAppendingString:video];
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
        
        for (int i = 0; i < 23; i++) {
            NSURL *youTubeVideo = [[NSURL alloc] initWithString:[VideoTableData createyouTubeVideoWithVideo:fakeAPIData[i * 4 + 2]]];
            URLIndex *youTubeVideoIndex = [[URLIndex alloc] init]; 
            youTubeVideoIndex.videoURL = youTubeVideo;
            youTubeVideoIndex.index = i;
            
            NSURL *thumbnailURL = [[NSURL alloc] initWithString:fakeAPIData[i * 4]];
            youTubeVideoIndex.thumbnailURL = thumbnailURL;
            
            youTubeVideoIndex.title = fakeAPIData[i * 4 + 1];
            youTubeVideoIndex.submitter = fakeAPIData[i * 4 + 3];
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(retrieveYouTubeVideoData:) object:youTubeVideoIndex];
            [operationQueue addOperation:operation];
        }
    }
    
    return self;
}

@end

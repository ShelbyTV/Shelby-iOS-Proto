//
//  VideoTableData.m
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoTableData.h"

@interface URLIndex : NSObject
@property (nonatomic, retain) NSURL *url;
@property (nonatomic) NSUInteger index;
@end
@implementation URLIndex
@synthesize url;
@synthesize index;
@end

@implementation VideoTableData

@synthesize numItems;

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

/*
 * This should really be a helper object defined above. Instead of declaring this global C-style array of structs,
 * we should really be using an NSArray.
 *
 * Currently this class gets the UITableView passed in. Ideally we'd restructure this code to load the thumbnail
 * and the YouTube MPEG URL in the same method, create the entire video data object, add it (in a threadsafe way) to
 * an NSArray, and then use UITableView beginUpdates, insertRow, and endUpdates to make only fully populated video data objects
 * show up in the UITableView in a graceful, animated way.
 *
 * Note, because we know our number of entries and the index is passed to the loading functions, using this already-sized
 * C-style array means we can put data into it threadsafe without any locks for now.
 */

typedef struct videoData {
    NSURL *contentURL;
    UIImage *thumbnailImage;
    NSString *submitter;
    NSString *title;
} videoData;

videoData videoDataArray[23];

- (NSString *)videoTitleAtIndex:(NSUInteger)index
{
    return videoDataArray[index].title;
}

- (NSString *)videoSharerAtIndex:(NSUInteger)index
{
    return videoDataArray[index].submitter;
}

- (UIImage *)videoThumbnailAtIndex:(NSUInteger)index
{
    return videoDataArray[index].thumbnailImage;
}

- (NSURL *)videoContentURLAtIndex:(NSUInteger)index
{
    return videoDataArray[index].contentURL;
}

/*
 * See above note about how this and the thumbnail loading should probably
 * be combined into one method.
 */
- (void)retrieveYouTubeVideoContentURL:(id)youTubeURL
{
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:((URLIndex *)youTubeURL).url];
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
    
    videoDataArray[((URLIndex *)youTubeURL).index].contentURL = [[NSURL URLWithString:movieURLString] retain];
    
    [youTubeURL release];
}


/*
 * See above note about how this and the MPEG URL loading should probably
 * be combined into one method.
 */
- (void)retrieveVideoThumbnail:(id)thumbnailURL
{
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:((URLIndex *)thumbnailURL).url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    UIImage *thumbnailImage = [[UIImage imageWithData:data] retain];
    
    videoDataArray[((URLIndex *)thumbnailURL).index].thumbnailImage = thumbnailImage;
    
    [thumbnailURL release];
}

// helper method -- maybe better to just embed in this file?
+ (NSString *)createYouTubeURLWithVideo:(NSString *)video
{
    NSString *baseURL = @"http://www.youtube.com/watch?v=";
    return [baseURL stringByAppendingString:video];
}

- (id)initWithUITableView:(UITableView *)linkedTableView
{
    self = [super init];
    if (self) {
        numItems = 23; // just hardcode number of fakeAPIData items for now
        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:4]; // seems slow on iPod Touch 2G -- too high?
        
        // eventually we should use this to gracefully insert new entries into the UITableView
        tableView = linkedTableView;
        
        for (int i = 0; i < numItems; i++) {
            NSURL *youTubeURL = [[NSURL alloc] initWithString:[VideoTableData createYouTubeURLWithVideo:fakeAPIData[i * 4 + 2]]];
            URLIndex *youTubeURLIndex = [[URLIndex alloc] init]; 
            youTubeURLIndex.url = youTubeURL;
            youTubeURLIndex.index = i;
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(retrieveYouTubeVideoContentURL:) object:youTubeURLIndex];
            [operationQueue addOperation:operation];
            
            NSURL *thumbnailURL = [[NSURL alloc] initWithString:fakeAPIData[i * 4]];
            URLIndex *thumbnailURLIndex = [[URLIndex alloc] init];
            thumbnailURLIndex.url = thumbnailURL;
            thumbnailURLIndex.index = i;
            [operationQueue addOperation:([[NSInvocationOperation alloc] initWithTarget:self selector:@selector(retrieveVideoThumbnail:) object:thumbnailURLIndex])];
            
            // fill out data we already know. nil out data filled in by the enqueued operations.
            videoDataArray[i].title = fakeAPIData[i * 4 + 1];
            videoDataArray[i].submitter = fakeAPIData[i * 4 + 3];
            videoDataArray[i].thumbnailImage = nil;
            videoDataArray[i].contentURL = nil;
        }
    }
    
    return self;
}

@end

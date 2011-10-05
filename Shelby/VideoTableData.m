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
#import "Video.h"
#import "LoginHelper.h"
#import "CoreDataHelper.h"

#pragma mark - Constants

#define kMaxVideoThumbnailHeight 163
#define kMaxVideoThumbnailWidth 290
#define kMaxSharerImageHeight 45
#define kMaxSharerImageWidth 45

#pragma mark - VideoDataURLRequest

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

#pragma mark - VideoTableData

@interface VideoTableData ()
// redeclare as readwrite for internal use; setter still accessible, but should generate
// compiler warnings if used outside
@property (readwrite) NSInteger networkCounter;
@end

@implementation VideoTableData

@synthesize delegate;
@synthesize networkCounter;
@synthesize likedOnly;

#pragma mark - Utility Methods

- (NSString *)dupeKeyWithProvider:(NSString *)provider withId:(NSString *)providerId
{
    return [NSString stringWithFormat:@"%@%@", provider, providerId];
}

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


// helper method -- maybe better to just embed in this file?
+ (NSString *)createYouTubeVideoInfoURLWithVideo:(NSString *)video
{
    assert(NOT_NULL(video));
    NSString *baseURL = @"http://www.youtube.com/get_video_info?video_id=";
    return [baseURL stringByAppendingString:video];
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize
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
    
    //Draw the image into the rect
    [image drawInRect:rect];
    
    //Saving the image, ending image context
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

#pragma mark - Accessors

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

- (int)videoDupeCountAtIndex:(NSUInteger)index
{
    @synchronized(videoDataArray)
    {
        Video *video = [videoDataArray objectAtIndex:index];
        return [[videoDupeDict objectForKey:[self dupeKeyWithProvider:video.provider withId:video.providerId]] count] - 1;
    } 
}

- (Video *)videoAtIndex:(NSUInteger)index
{
    return (Video *)[videoDataArray objectAtIndex:index];
}

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
        NSURL *youTubeURL = [[[NSURL alloc] initWithString:[VideoTableData createYouTubeVideoInfoURLWithVideo:videoData.providerId]] autorelease];
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

#pragma mark - Table Updates

- (void)updateTableVideoThumbnail:(Video *)video
{
    @synchronized(videoDataArray)
    {
        if (video.arrayGeneration != arrayGeneration) {
            return;
        }
        
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
        if (video.arrayGeneration != arrayGeneration) {
            return;
        }
        
        // might be able to do this faster by just storing the index in the Video
        int videoIndex = [videoDataArray indexOfObject:video];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:videoIndex inSection:0]];
        
        // sucks that this knowledge is leaking out of VideoTableViewController... need to make this nicer
        UIImageView *sharerImage = (UIImageView *)[cell viewWithTag:4];
        sharerImage.image = video.sharerImage;
    }
}

- (void)updateTableVideoWatchStatus:(Video *)video
{
    @synchronized(videoDataArray)
    {
        if (video.arrayGeneration != arrayGeneration) {
            return;
        }
        
        // might be able to do this faster by just storing the index in the Video
        int videoIndex = [videoDataArray indexOfObject:video];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:videoIndex inSection:0]];
        
        // sucks that this knowledge is leaking out of VideoTableViewController... need to make this nicer
        UIImageView *sourceTag = (UIImageView *)[cell viewWithTag:1];
        NSString *videoSource = video.source;
        BOOL isWatched = video.isWatched;
        
        if ([videoSource isEqualToString:@"twitter"]) {
            if (!isWatched) {
                sourceTag.image = [UIImage imageNamed:@"TwitterNew"];
            } else {
                sourceTag.image = [UIImage imageNamed:@"TwitterWatched"];
            }
        } else if ([videoSource isEqualToString:@"facebook"]) {
            if (!isWatched) {
                sourceTag.image = [UIImage imageNamed:@"FacebookNew"];
            } else {
                sourceTag.image = [UIImage imageNamed:@"FacebookWatched"];
            }
        } else if ([videoSource isEqualToString:@"tumblr"]) {
            if (!isWatched) {
                sourceTag.image = [UIImage imageNamed:@"TumblrNew"];
            } else {
                sourceTag.image = [UIImage imageNamed:@"TumblrWatched"];
            }
        } else if ([videoSource isEqualToString:@"bookmarklet"]) {
            // clear image, so no watched/unwatched. easier than hiding/unhiding in this case.
            sourceTag.image = [UIImage imageNamed:@"Bookmarklet"];
        }

    }
}

#pragma mark - Async Image Downloading

- (void)downloadSharerImage:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    VideoDataURLRequest *req = [VideoDataURLRequest requestWithURL:video.sharerImageURL];
    
    if (req) {
        req.video = video;
        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedSharerImage:data:error:forRequest:)];
        [self incrementNetworkCounter];
    } else {
        // We failed to send the request. Let the caller know.
    }
    [pool release];
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
        
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psCoordinator];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        // resize down to the largest size we use anywhere. this should speed up table view scrolling.
        ((VideoDataURLRequest*)request).video.sharerImage = [self scaleImage:[UIImage imageWithData:data] toSize:CGSizeMake(kMaxSharerImageWidth,
                                                                                                                            kMaxSharerImageHeight)];
        
        [[ShelbyApp sharedApp].loginHelper storeBroadcastVideo:((VideoDataURLRequest*)request).video 
                                           withSharerImageData:UIImagePNGRepresentation(((VideoDataURLRequest*)request).video.sharerImage)
                                                     inContext:context];
        
        [context release];
        
        [self updateTableSharerImage:((VideoDataURLRequest*)request).video];
    }
    
    [self decrementNetworkCounter];
}

- (void)downloadVideoThumbnail:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    VideoDataURLRequest *req = [VideoDataURLRequest requestWithURL:video.thumbnailURL];
    
    if (req) {
        req.video = video;
        [NSURLConnection sendAsyncRequest:req delegate:self completionSelector:@selector(receivedVideoThumbnail:data:error:forRequest:)];
        [self incrementNetworkCounter];
    } else {
        // We failed to send the request. Let the caller know.
    }
    [pool release];
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
        
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psCoordinator];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        // resize down to the largest size we use anywhere. this should speed up table view scrolling.
        ((VideoDataURLRequest*)request).video.thumbnailImage = [self scaleImage:[UIImage imageWithData:data] toSize:CGSizeMake(kMaxVideoThumbnailWidth,
                                                                                                                                kMaxVideoThumbnailHeight)];
        
        [[ShelbyApp sharedApp].loginHelper storeBroadcastVideo:((VideoDataURLRequest*)request).video 
                                             withThumbnailData:UIImagePNGRepresentation(((VideoDataURLRequest*)request).video.thumbnailImage)
                                                     inContext:context];
        
        [context release];
        
        [self updateTableVideoThumbnail:((VideoDataURLRequest*)request).video];
    }
    
    [self decrementNetworkCounter];
}

#pragma mark - Clearing

/*
 * Cancel any pending operations, bump array generation number so any in-flight ops are no-ops,
 * clear the existing video table, and update the table view to delete all entries
 */

- (void)clearVideosWithArrayLockHeld
{
    [videoDupeDict removeAllObjects];
    [videoDataArray removeAllObjects];
    
    arrayGeneration++;
    
    NSMutableArray* indexPaths = [[[NSMutableArray alloc] init] autorelease];
    for (int i = 0; i < lastInserted; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    lastInserted = 0;
    [tableView endUpdates];
}

- (void)clearVideos
{
    @synchronized(videoDataArray)
    {
        [self clearVideosWithArrayLockHeld];
    }
}

#pragma mark - Loading

- (void)copyBroadcast:(Broadcast *)broadcast intoVideo:(Video *)video
{
    NSString *sharerName = [broadcast.sharerName uppercaseString];
    if ([broadcast.origin isEqualToString:@"twitter"]) {
        sharerName = [NSString stringWithFormat:@"@%@", sharerName];
    }
    
    if (NOT_NULL(broadcast.thumbnailImageUrl)) video.thumbnailURL = [NSURL URLWithString:broadcast.thumbnailImageUrl];
    if (NOT_NULL(broadcast.sharerImageUrl)) video.sharerImageURL = [NSURL URLWithString:broadcast.sharerImageUrl];
    
    if (NOT_NULL(broadcast.thumbnailImage)) {
        video.thumbnailImage = [UIImage imageWithData:broadcast.thumbnailImage];
    }
    if (NOT_NULL(broadcast.sharerImage)) {
        video.sharerImage = [UIImage imageWithData:broadcast.sharerImage];
    }
    
    SET_IF_NOT_NULL(video.provider, broadcast.provider);
    SET_IF_NOT_NULL(video.providerId, broadcast.providerId);
    SET_IF_NOT_NULL(video.shelbyId, broadcast.shelbyId);
    SET_IF_NOT_NULL(video.title, broadcast.title)
    SET_IF_NOT_NULL(video.sharer, sharerName)
    SET_IF_NOT_NULL(video.sharerComment, broadcast.sharerComment)
    SET_IF_NOT_NULL(video.shortPermalink, broadcast.shortPermalink)
    SET_IF_NOT_NULL(video.source, broadcast.origin)
    SET_IF_NOT_NULL(video.createdAt, broadcast.createdAt)
    
    if (NOT_NULL(broadcast.liked)) video.isLiked = [broadcast.liked boolValue];
    if (NOT_NULL(broadcast.watched)) video.isWatched = [broadcast.watched boolValue];
}

- (NSArray *)fetchBroadcastsFromCoreDataContext:(NSManagedObjectContext *)context
{
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    [context setPersistentStoreCoordinator:psCoordinator];
    
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
    
    return broadcasts;
}

- (void)reloadCoreDataBroadcasts
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    NSArray *broadcasts = [self fetchBroadcastsFromCoreDataContext:context];

    if (IS_NULL(broadcasts)) {
        return;
    } 
    
    LOG(@"Found %d broadcasts for channel.public=0.", [broadcasts count]);
    
    @synchronized(videoDataArray)
    {
        // Clear out the old broadcasts.
        [self clearVideosWithArrayLockHeld];
        
        NSMutableArray *uniqueVideoKeys = [[NSMutableArray alloc] init];
        
        // Load up the new broadcasts.
        for (Broadcast *broadcast in broadcasts) {            
            // For now, we only handle YouTube.
            if (IS_NULL(broadcast.provider) || ![broadcast.provider isEqualToString: @"youtube"]) {
                continue;
            }

            // Need provider (checked above) and providerId to be able to display the video
            if (IS_NULL(broadcast.providerId)) {
                continue;
            }
            
            Video *video = [[[Video alloc] init] autorelease];

            NSMutableArray *dupeArray = [videoDupeDict objectForKey:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            if (NOT_NULL(dupeArray)) {
                [dupeArray insertObject:video atIndex:0];
            } else {
                dupeArray = [[NSMutableArray alloc] init];
                [dupeArray addObject:video];
                [videoDupeDict setObject:dupeArray forKey:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
                [uniqueVideoKeys addObject:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            }

            // create Video from Broadcast
            [self copyBroadcast:broadcast intoVideo:video];
            video.arrayGeneration = arrayGeneration;  

            // need the sharerImage even for dupes
            if (IS_NULL(video.sharerImage)) {
                [self performSelectorInBackground:@selector(downloadSharerImage:) withObject:video];
            }
            
            // could optimize to not re-download for dupes, but don't bother for now...
            if (IS_NULL(video.thumbnailImage)) {
                [self performSelectorInBackground:@selector(downloadVideoThumbnail:) withObject:video];
            }
        }
        
        for (NSString *key in uniqueVideoKeys)
        {
            NSArray *dupeArray = [videoDupeDict objectForKey:key];
            
            // If we're in the like view, only keep videos that are liked...
            if (likedOnly) {
                BOOL likedDupe = NO;
                for (Video *video in dupeArray) {
                    if (video.isLiked) {
                        likedDupe = YES;
                        break;
                    }
                }
                if (!likedDupe)
                {
                    continue;
                }
            }
            
            Video *video = [dupeArray objectAtIndex:0];
            
            int index = [videoDataArray count];
            [videoDataArray addObject:video];
            
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            lastInserted = index + 1;
            [tableView endUpdates];
        }
    }
    
    [context release];
    
    [self.delegate videoTableDataDidFinishRefresh:self];
}

#pragma mark - Notifications

- (void)receivedBroadcastsNotification:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(reloadCoreDataBroadcasts) userInfo:nil repeats:NO];
}

- (void)updateLikeStatusForVideo:(Video *)video withStatus:(BOOL)status
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    [context setPersistentStoreCoordinator:psCoordinator];
    
    video.isLiked = status;
    
    Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                        withShelbyId:video.shelbyId
                                                           inContext:context];
    if (IS_NULL(broadcast)) {
        return;
    }
    
    broadcast.liked = [NSNumber numberWithBool:status];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
}

- (void)likeVideoSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        [self updateLikeStatusForVideo:[notification.userInfo objectForKey:@"video"] withStatus:TRUE];
    }
}

- (void)dislikeVideoSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        [self updateLikeStatusForVideo:[notification.userInfo objectForKey:@"video"] withStatus:FALSE];
    }
}

- (void)watchVideoSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        Video *video = [notification.userInfo objectForKey:@"video"];
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        [context setPersistentStoreCoordinator:psCoordinator];
        
        video.isWatched = TRUE;
        
        Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                            withShelbyId:video.shelbyId
                                                               inContext:context];
        if (IS_NULL(broadcast)) {
            return;
        }
        
        broadcast.watched = [NSNumber numberWithBool:TRUE];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
        }
        
        [self updateTableVideoWatchStatus:video];
    }
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
        videoDupeDict = [[NSMutableDictionary alloc] init];
        arrayGeneration = 0;

        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(receivedBroadcastsNotification:)
                                                     name: @"ReceivedBroadcasts"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(likeVideoSucceeded:)
                                                     name:@"LikeBroadcastSucceeded"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dislikeVideoSucceeded:)
                                                     name:@"DislikeBroadcastSucceeded"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(watchVideoSucceeded:)
                                                     name:@"WatchBroadcastSucceeded"
                                                   object:nil];
        
        [[ShelbyApp sharedApp] addNetworkObject: self];
    }
    return self;
}

@end

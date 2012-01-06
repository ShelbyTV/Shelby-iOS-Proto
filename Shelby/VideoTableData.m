//
//  VideoTableData.m
//  Shelby
//
//  Created by Mark Johnson on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoTableData.h"

#import "Broadcast.h"
#import "ThumbnailImage.h"
#import "SharerImage.h"

#import "ShelbyApp.h"
#import "NSURLConnection+AsyncBlock.h"
#import "Video.h"
#import "LoginHelper.h"
#import "CoreDataHelper.h"
#import "VideoGetter.h"
#import "PlatformHelper.h"

#import "Foundation/Foundation.h"

#pragma mark - Constants

#define kMaxVideoThumbnailHeight 163
#define kMaxVideoThumbnailWidth 290
#define kMaxSharerImageHeight 120
#define kMaxSharerImageWidth 120

#pragma mark - VideoTableData

@interface VideoTableData ()

@property (readwrite) NSInteger networkCounter;
@property (readwrite) NSUInteger numItemsInserted;

@end

@implementation VideoTableData

@synthesize delegate;
@synthesize networkCounter;
@synthesize likedOnly;
@synthesize watchLaterOnly;
@synthesize numItemsInserted;

#pragma mark - Utility Methods

- (NSString *)dupeKeyWithProvider:(NSString *)provider 
                           withId:(NSString *)providerId
{
    return [NSString stringWithFormat:@"%@%@", provider, providerId];
}

// sync just needed for writes to make sure two simultaneous inc/decrements don't result in same value
// this is because OSAtomicInc* doesn't exist on iOS
- (void)incrementNetworkCounter
{
    @synchronized(self) { self.networkCounter++; }
}

- (void)decrementNetworkCounter
{
    @synchronized(self) { self.networkCounter--; }
}

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

#pragma mark - Accessors

- (BOOL)isLoading
{
    // no synchronized needed for reads, since networkCounter is an int
    return self.networkCounter != 0;
}

- (NSArray *)videoDupes:(Video *)video
{
    @synchronized(tableVideos)
    {
        return [[[videoDupeDict objectForKey:[self dupeKeyWithProvider:video.provider withId:video.providerId]] retain] autorelease];
    } 
}

- (Video *)videoAtIndex:(NSUInteger)index
{    
    @synchronized(tableVideos)
    {
        if (index > [tableVideos count] || index == 0)
        {
            // something racy happened, and our index is no longer valid
            return nil;
        }
        return [[(Video *)[tableVideos objectAtIndex:(index - 1)] retain] autorelease];
    }
}

- (void)getVideoContentURLSimulator:(Video *)videoData
{
    /*
     * Content URL
     */
    NSString *baseURL = @"http://www.youtube.com/get_video_info?video_id=";
    NSURL *youTubeURL = [[[NSURL alloc] initWithString:[baseURL stringByAppendingString:videoData.providerId]] autorelease];
    NSError *error = nil;
    NSString *youTubeVideoDataRaw = [[[NSString alloc] initWithContentsOfURL:youTubeURL encoding:NSASCIIStringEncoding error:&error] autorelease];
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
        
        videoData.contentURL = [NSURL URLWithString:movieURLString];
    }
}

- (void)getVideoContentURLDevice:(Video *)video
{
    [[VideoGetter singleton] processVideo:video];
    NSLog(@"after processVideo");
}

- (NSURL *)getVideoContentURL:(Video *)videoData
{
    
    NSURL *contentURL = videoData.contentURL;
    
    if (contentURL == nil) {
#if TARGET_IPHONE_SIMULATOR
        [self getVideoContentURLSimulator:videoData];
#else
        [self getVideoContentURLDevice:videoData];
#endif
        contentURL = videoData.contentURL;
    }
    
    
    return contentURL;
}

- (NSURL *)videoContentURLAtIndex:(NSUInteger)index
{
    Video *videoData = nil;

    @synchronized(tableVideos)
    {
        if (index > [tableVideos count] || index == 0)
        {
            // something racy happened, and our index is no longer valid
            return nil;
        }
        videoData = [[[tableVideos objectAtIndex:(index - 1)] retain] autorelease];
    }
    
    if (IS_NULL(videoData.contentURL) && ![ShelbyApp sharedApp].demoModeEnabled) {
        [self getVideoContentURL:videoData];
    }

    return [[videoData.contentURL retain] autorelease];
}

#pragma mark - Table Updates

- (void)updateVideoTableCell:(Video *)video
{
    UITableViewCell *cell;
    
    @synchronized(tableVideos)
    {
        int videoIndex = [tableVideos indexOfObject:video];
        if (videoIndex == NSNotFound) {
            return;
        }
        
        cell = [[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(videoIndex + 1) inSection:0]] retain] autorelease];
    }
    
    [cell performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

#pragma mark - Image Downloading

- (void)storeSharerImage:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    if (NOT_NULL(video.sharerImage)) 
    {
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setUndoManager:nil];
        [context setPersistentStoreCoordinator:psCoordinator];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        [[ShelbyApp sharedApp].loginHelper storeBroadcastVideo:video
                                           withSharerImageData:UIImagePNGRepresentation(video.sharerImage)
                                                     inContext:context];
        
        [context release];
    }
    
    [pool release];
}

- (void)loadSharerImageFromCoreData:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil];
    [context setPersistentStoreCoordinator:psCoordinator];
    [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    SharerImage *sharerImage = [CoreDataHelper fetchExistingUniqueEntity:@"SharerImage" withBroadcastShelbyId:video.shelbyId inContext:context];
    
    if (IS_NULL(sharerImage)) 
    {
        NSLog(@"Couldn't find CoreData sharerImage entry for video %@; aborting load of sharerImage", video.shelbyId);
    } else {
        video.sharerImage = [UIImage imageWithData:sharerImage.imageData];
        [self updateVideoTableCell:video];
    }
    
    [context release];
    [pool release];
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
        
        [self updateVideoTableCell:video];
        [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(storeSharerImage:) object:video] autorelease]];
    }
    
    [pool release];
}

- (void)storeVideoThumbnail:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (NOT_NULL(video.sharerImage)) 
    {
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setUndoManager:nil];
        [context setPersistentStoreCoordinator:psCoordinator];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        [[ShelbyApp sharedApp].loginHelper storeBroadcastVideo:video 
                                             withThumbnailData:UIImagePNGRepresentation(video.thumbnailImage)
                                                     inContext:context];
        
        [context release];
    }
    
    [pool release];
}

- (void)loadVideoThumbnailFromCoreData:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil];
    [context setPersistentStoreCoordinator:psCoordinator];
    [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    ThumbnailImage *thumbnailImage = [CoreDataHelper fetchExistingUniqueEntity:@"ThumbnailImage" withBroadcastShelbyId:video.shelbyId inContext:context];
    
    if (IS_NULL(thumbnailImage)) 
    {
        NSLog(@"Couldn't find CoreData thumbnailImage entry for video %@; aborting load of thumbnailImage", video.shelbyId);
    } else {
        video.thumbnailImage = [UIImage imageWithData:thumbnailImage.imageData];
        [self updateVideoTableCell:video];
    }
    
    [context release];
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
        
        [self updateVideoTableCell:video];
        [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(storeVideoThumbnail:) object:video] autorelease]];
    } 

    [pool release];
}

#pragma mark - Clearing

/*
 * Clear the existing video table, and update the table view to delete all entries
 */

- (void)clearVideoTableWithArrayLockHeld
{
    [tableVideos removeAllObjects];
        
    NSMutableArray* indexPaths = [[[NSMutableArray alloc] init] autorelease];
    for (int i = 0; i < self.numItemsInserted; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    self.numItemsInserted = 0;
    [tableView endUpdates];
}

- (void)clearVideoTableData
{
    @synchronized(tableVideos)
    {
        [videoDupeDict removeAllObjects];
        [uniqueVideoKeys removeAllObjects];
        [self clearVideoTableWithArrayLockHeld];
    }
}

#pragma mark - Loading

- (Channel *)fetchPublicChannelFromCoreDataContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Channel" 
                                              inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"public=0"];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *channels = [context executeFetchRequest:fetchRequest error:&error];
    
    [fetchRequest release];
    
    return [channels objectAtIndex:0];
}

- (NSArray *)fetchBroadcastsFromCoreDataContext:(NSManagedObjectContext *)context
{
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

- (BOOL)shouldIncludeVideo:(NSArray *)dupeArray
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        BOOL videoHasContentURL = FALSE;
        NSURL *dupeContentURL = nil;
        for (Video *video in dupeArray) {
            if (video.contentURL != nil) {
                videoHasContentURL = TRUE;
                dupeContentURL = video.contentURL;
                break;
            }
        }
        
        if (videoHasContentURL) {
            for (Video *video in dupeArray) {
                video.contentURL = dupeContentURL;
            }
        } else {
            return FALSE;
        }
    }
    
    
    // Depending on the view, only display certain videos...
    if (likedOnly || watchLaterOnly) {
        for (Video *video in dupeArray) {
            if ((likedOnly && video.isLiked) ||
                (watchLaterOnly && video.isWatchLater)) {
                return TRUE;
            }
        }
        return FALSE;
    }
    
    return TRUE;
}

- (void)insertTableVideos
{    
    if (self.numItemsInserted == 0) {
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        self.numItemsInserted = 1;
        [tableView endUpdates];
    }

    int videoTableIndex = 0;
    
    for (NSString *key in uniqueVideoKeys)
    {
        if (NOT_NULL([playableVideoKeys objectForKey:key]))
        {
            NSArray *dupeArray = [videoDupeDict objectForKey:key];
            Video *video = [dupeArray objectAtIndex:0];        

            if (![self shouldIncludeVideo:dupeArray]) {
                continue;
            }
            
            if ([tableVideos count] > videoTableIndex) 
            {
                Video *videoAtTableIndex = [tableVideos objectAtIndex:videoTableIndex];
                NSString *videoAtTableIndexDupeKey = [self dupeKeyWithProvider:videoAtTableIndex.provider withId:videoAtTableIndex.providerId];

                if ([[self dupeKeyWithProvider:video.provider withId:video.providerId] isEqualToString:videoAtTableIndexDupeKey])
                {
                    videoTableIndex++;
                    continue;
                }
            }
            
            [tableVideos insertObject:video atIndex:videoTableIndex];
            videoTableIndex++;
            
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:videoTableIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            self.numItemsInserted = [tableVideos count] + 1; // +1 is for the onboarding cell
            [tableView endUpdates];
        }
    }
}

- (void)loadNewTableVideos
{
    @synchronized(tableVideos)
    {
        [self insertTableVideos];
    }
    [self.delegate videoTableDataDidFinishRefresh:self];
}

- (void)reloadTableVideosInt
{
    @synchronized(tableVideos)
    {
        [self clearVideoTableWithArrayLockHeld];
        [self insertTableVideos];
        if (self.numItemsInserted > 1) {
            [tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:1 inSection: 0]
                             atScrollPosition: UITableViewScrollPositionTop
                                     animated: NO];
        }
    }
}

- (void)reloadTableVideos
{
    [self performSelectorOnMainThread:@selector(reloadTableVideosInt) withObject:nil waitUntilDone:NO];
}

- (BOOL)checkVimeoMobileURL:(NSString *)providerId
{
//    NSError *error = nil;
//    NSString *requestString = [NSString stringWithFormat:@"http://vimeo.com/api/v2/video/%@.json", providerId];    
//    NSString *vimeoVideoData = [[[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:requestString] encoding:NSASCIIStringEncoding error:&error] autorelease];
//    
//    NSRange mobileURL = [vimeoVideoData rangeOfString:@"\"mobile_url\""];
//    
//    if (mobileURL.location == NSNotFound) { // means there's no mobile version
//        return FALSE;
//    }
    
    return TRUE;
}

- (BOOL)checkYouTubePrivileges:(NSString *)providerId
{
    NSError *error = nil;
    NSString *requestString = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos/%@?v=2", providerId];    
    NSString *youTubeVideoData = [[[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:requestString] encoding:NSASCIIStringEncoding error:&error] autorelease];

    NSRange syndicateDenied = [youTubeVideoData rangeOfString:@"yt:accessControl action='syndicate' permission='denied'"];
    NSRange syndicateLimited = [youTubeVideoData rangeOfString:@"yt:state name='restricted' reasonCode='limitedSyndication'"];
    
    if (syndicateDenied.location != NSNotFound || syndicateLimited.location != NSNotFound) { // means syndication on mobile devices is disallowed
        return FALSE;
    }
    
    return TRUE;
}

- (void)checkPlayable:(Video *)video
{
    if ([ShelbyApp sharedApp].demoModeEnabled) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.mp4", video.provider, video.providerId]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) 
        {
            @synchronized(tableVideos)
            {
                video.contentURL = [NSURL fileURLWithPath:path];
                [playableVideoKeys setObject:self forKey:[self dupeKeyWithProvider:video.provider withId:video.providerId]];
                videoTableNeedsUpdate = TRUE;
            }
        }
        
        return;
    }
    
    // check for a valid Vimeo ID (should be a single number) 
    if ([video.provider isEqualToString: @"vimeo"] &&
        [self checkVimeoMobileURL:video.providerId])
    {
        @synchronized(tableVideos)
        {
            [playableVideoKeys setObject:self forKey:[self dupeKeyWithProvider:video.provider withId:video.providerId]];
            videoTableNeedsUpdate = TRUE;
        }
    }
    
    if ([video.provider isEqualToString: @"youtube"] &&
        [self checkYouTubePrivileges:video.providerId])
    {
        @synchronized(tableVideos)
        {
            [playableVideoKeys setObject:self forKey:[self dupeKeyWithProvider:video.provider withId:video.providerId]];
            videoTableNeedsUpdate = TRUE;
        }
    }
}

- (void)clearTempDataStructuresForNewBroadcasts
{
    [videoDupeDict removeAllObjects];
    [uniqueVideoKeys removeAllObjects];
    [playableVideoKeys removeAllObjects];
    [self clearVideoTableWithArrayLockHeld];
}

- (void)processBroadcastArray:(NSArray *)broadcasts
{
    for (Broadcast *broadcast in broadcasts) {
        Video *video = [[[Video alloc] initWithBroadcast:broadcast] autorelease];
        
        NSMutableArray *dupeArray = [videoDupeDict objectForKey:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
        if (NOT_NULL(dupeArray)) {
            [dupeArray insertObject:video atIndex:0];
        } else {
            dupeArray = [[[NSMutableArray alloc] init] autorelease];
            [dupeArray addObject:video];
            [videoDupeDict setObject:dupeArray forKey:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            [uniqueVideoKeys addObject:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            
            [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(checkPlayable:) object:video] autorelease]];
        }
        
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
}

- (NSDictionary *)createBroadcastShelbyIdentDict:(NSArray *)broadcasts
{
    NSMutableDictionary *returnDict = [[[NSMutableDictionary alloc] initWithCapacity:[broadcasts count]] autorelease];
    
    for (Broadcast *broadcast in broadcasts) {
        [returnDict setObject:broadcast forKey:broadcast.shelbyId];
    }
    
    return returnDict;
}

- (NSDictionary *)addOrUpdateBroadcasts:(NSMutableArray *)broadcasts 
                       withNewJSON:(NSArray *)jsonDictionariesArray 
                       withChannel:(Channel *)jsonChannel
                       withContext:(NSManagedObjectContext *)context
{
    NSMutableDictionary *jsonBroadcasts = [[[NSMutableDictionary alloc] init] autorelease];
    
    // create lookup dictionary of shelbyID => old broadast
    NSDictionary *existingBroadcastShelbyIDs = [self createBroadcastShelbyIdentDict:broadcasts];
    
    for (NSDictionary *dict in jsonDictionariesArray)
    {
        // easy checks, should do now rather than later
        NSString *provider = [dict objectForKey:@"video_provider_name"];
        NSString *providerId = [dict objectForKey:@"video_id_at_provider"];
        
        if (IS_NULL(provider) || !([provider isEqualToString: @"youtube"] ||
                                   [provider isEqualToString: @"vimeo"])) {
            continue;
        }
        
        if (IS_NULL(providerId) || [providerId isEqualToString:@""]) {
            continue;
        }
        
        if ([provider isEqualToString: @"vimeo"] &&
            ![providerId isEqualToString:[NSString stringWithFormat:@"%d", [providerId intValue]]])
        {
            continue;
        }
        
        Broadcast *upsert = [existingBroadcastShelbyIDs objectForKey:[dict objectForKey:@"_id"]];
        
        if (IS_NULL(upsert)) {
            upsert = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Broadcast"
                      inManagedObjectContext:context];
            
            [broadcasts addObject:upsert];
        }
        
        [jsonBroadcasts setObject:upsert forKey:[dict objectForKey:@"_id"]];
        [upsert populateFromApiJSONDictionary:dict];
        
        if (jsonChannel) {
           upsert.channel = jsonChannel; 
        }
    }
    
    return jsonBroadcasts;
}

- (void)sortBroadcasts:(NSMutableArray *)broadcasts 
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [broadcasts sortUsingDescriptors:sortDescriptors];
}

- (void)removeExtraBroadcasts:(NSMutableArray *)broadcasts 
                  withNewJSON:(NSDictionary *)jsonBroadcasts
                  withContext:(NSManagedObjectContext *)context
{
    int numBroadcasts = [broadcasts count];
    int numToKeep;
    
    int minRAM = [PlatformHelper minimumRAM];
    if (minRAM <= 128) {
        numToKeep = 60;
    } else if (minRAM <= 256) {
        numToKeep = 200;
    } else {
        numToKeep = 300;
    }
    
    int numToRemove = numBroadcasts - numToKeep;
    int numRemoved = 0;
    
    if (numToRemove <= 0) {
        return;
    }
    
    NSMutableArray *discardedBroadcasts = [[[NSMutableArray alloc] initWithCapacity:numToRemove] autorelease];
    
    int jsonBroadcastsCount = [jsonBroadcasts count];
    
    for (Broadcast *broadcast in [broadcasts reverseObjectEnumerator]) {
        if (numRemoved >= numToRemove) {
            break;
        }
        
        if ((numToKeep > jsonBroadcastsCount) && NOT_NULL([jsonBroadcasts objectForKey:broadcast.shelbyId])) {
            continue; // don't remove anything Shelby just told us about
        }
        
        [discardedBroadcasts addObject:broadcast];
        numRemoved++;
    }
    
    [broadcasts removeObjectsInArray:discardedBroadcasts];
    
    for (Broadcast *broadcast in discardedBroadcasts) {
        if (NOT_NULL(broadcast.sharerImage)) {
            [context deleteObject:broadcast.sharerImage];
        }
        if (NOT_NULL(broadcast.thumbnailImage)) {
            [context deleteObject:broadcast.thumbnailImage];
        }
        [context deleteObject:broadcast];
    }
}

/*
 * This is probably the most complicated piece of the entire iOS app.
 * Basically what we're trying to do here is process any new videos, make
 * sure we try not to download anything we don't have to, make sure any
 * videos we show are playable on mobile devices, and try to update the UI
 * as quickly and incrementally as possible for low latency.
 *
 * One thing we have to keep in mind through all of this is that accessing
 * CoreData for hundreds 
 */ 
- (void)loadNewBroadcastsFromJSON:(NSTimer*)timer
{
    // set up our CoreData context
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil]; // don't need undo, and this speeds things up / requires less memory
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    [context setPersistentStoreCoordinator:psCoordinator];
    
    // new JSON data
    NSArray *jsonDictionariesArray = [timer.userInfo objectForKey:@"jsonDictionariesArray"];
    
    @synchronized(tableVideos)
    {
        // get rid of old temporary data
        [self clearTempDataStructuresForNewBroadcasts];
        
        // fetch old broadcasts from CoreData
        NSMutableArray *broadcasts = [[[NSMutableArray alloc] init] autorelease];
        [broadcasts addObjectsFromArray:[self fetchBroadcastsFromCoreDataContext:context]];
        
        Channel *publicChannel = [self fetchPublicChannelFromCoreDataContext:context];
        
        // go through new JSON broadcast data and identify ones with same shelbyIDs as old broadcasts
        // if shelbyID already exists, update old broadcast object with any new data
        // if doesn't already exist, create new Broadcast in CoreData with new JSON data
        NSDictionary *jsonBroadcasts = [self addOrUpdateBroadcasts:broadcasts 
                                                       withNewJSON:jsonDictionariesArray 
                                                       withChannel:publicChannel
                                                       withContext:context];
        
        // sort array by createdAt date
        [self sortBroadcasts:broadcasts];
        
        // determine numToKeep and numToDelete
        // iterate through and delete broadcasts from CoreData and array somehow?
        [self removeExtraBroadcasts:broadcasts withNewJSON:jsonBroadcasts withContext:context];
        
        [operationQueue setSuspended:TRUE];
        
        // iterate through sorted broadcast array, finding dupes, creating operationQueue jobs, etc.
        [self processBroadcastArray:broadcasts];
        
        // save CoreData context
        [CoreDataHelper saveContextAndLogErrors:context];

        [operationQueue setSuspended:FALSE];
    }
    
    [context release];
}

#pragma mark - Notifications

- (void)receivedBroadcastsNotification:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(loadNewBroadcastsFromJSON:) userInfo:notification.userInfo repeats:NO];
}

- (void)updateLikeStatusForVideo:(Video *)video withStatus:(BOOL)status
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil];
    [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    [context setPersistentStoreCoordinator:psCoordinator];
    
    video.isLiked = status;
    
    Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                        withShelbyId:video.shelbyId
                                                           inContext:context];
    if (IS_NULL(broadcast)) {
        [context release];
        return;
    }
    
    broadcast.liked = [NSNumber numberWithBool:status];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
    
    [context release];
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

- (void)updateWatchLaterStatusForVideo:(Video *)video withStatus:(BOOL)status
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil];
    [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
    [context setPersistentStoreCoordinator:psCoordinator];
    
    video.isWatchLater = status;
    
    Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                        withShelbyId:video.shelbyId
                                                           inContext:context];
    if (IS_NULL(broadcast)) {
        [context release];
        return;
    }
    
    broadcast.watchLater = [NSNumber numberWithBool:status];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
    }
    
    [context release];
}

- (void)watchLaterSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        [self updateWatchLaterStatusForVideo:[notification.userInfo objectForKey:@"video"] withStatus:TRUE];
    }
}

- (void)unwatchLaterSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        [self updateWatchLaterStatusForVideo:[notification.userInfo objectForKey:@"video"] withStatus:FALSE];
    }
}

- (void)watchVideoSucceeded:(NSNotification *)notification
{
    if (NOT_NULL(notification.userInfo)) {
        Video *video = [notification.userInfo objectForKey:@"video"];
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setUndoManager:nil];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        [context setPersistentStoreCoordinator:psCoordinator];
        
        video.isWatched = TRUE;
        
        Broadcast *broadcast = [CoreDataHelper fetchExistingUniqueEntity:@"Broadcast"
                                                            withShelbyId:video.shelbyId
                                                               inContext:context];
        if (IS_NULL(broadcast)) {
            [context release];
            return;
        }
        
        broadcast.watched = [NSNumber numberWithBool:TRUE];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            [NSException raise:@"unexpected" format:@"Couldn't Save context! %@", [error localizedDescription]];
        }
        
        [context release];
        [self updateVideoTableCell:video];
    }
}

#pragma mark - Initialization

- (id)initWithUITableView:(UITableView *)linkedTableView
{
    self = [super init];
    
    if (self) {
        // we use this to gracefully insert new entries into the UITableView
        tableView = linkedTableView;

        self.numItemsInserted = 0;
        tableVideos = [[NSMutableArray alloc] init];
        videoDupeDict = [[NSMutableDictionary alloc] init];
        uniqueVideoKeys = [[NSMutableArray alloc] init];
        playableVideoKeys = [[NSMutableDictionary alloc] init];

        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:1];
        
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerCallback) userInfo:nil repeats:YES];

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
                                                 selector:@selector(watchLaterSucceeded:)
                                                     name:@"WatchLaterBroadcastSucceeded"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(unwatchLaterSucceeded:)
                                                     name:@"UnwatchLaterBroadcastSucceeded"
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(watchVideoSucceeded:)
                                                     name:@"WatchBroadcastSucceeded"
                                                   object:nil];
        
        [[ShelbyApp sharedApp] addNetworkObject: self];
    }
    
    return self;
}

- (void)updateTimerCallback
{
    self.networkCounter = [operationQueue operationCount];
    
    if (videoTableNeedsUpdate) {
        videoTableNeedsUpdate = FALSE;
        [self performSelectorOnMainThread:@selector(loadNewTableVideos) withObject:nil waitUntilDone:NO];
    }
}

- (void)enableDemoMode
{    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSMutableURLRequest *request = nil;

    for (NSString *key in uniqueVideoKeys)
    {
        if (NOT_NULL([playableVideoKeys objectForKey:key]))
        {
            NSArray *dupeArray = [videoDupeDict objectForKey:key];
            Video *video = [dupeArray objectAtIndex:0];        
            
            if (NOT_NULL(video.contentURL)) {
                
                NSLog(@"########## Creating NSURLRequest.");
                
                request = [NSMutableURLRequest requestWithURL:video.contentURL];
                
                NSLog(@"########## Sending SynchronousRequest.");
                
                [request setValue:[ShelbyApp sharedApp].safariUserAgent forHTTPHeaderField:@"User-Agent"];
                
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                NSLog(@"########## Data in MB: %.2f", (float)([data length] / 1024.0 / 1024.0));
                NSLog(@"########## Error: %@", [error localizedDescription]);
                
                NSLog(@"########## Creating fileURL in bundle.");
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                
                NSLog(@"########## Creating directory path in bundle.");
                [[NSFileManager defaultManager] createDirectoryAtPath:[paths objectAtIndex:0] withIntermediateDirectories:YES attributes:nil error:&error];
                
                NSLog(@"########## Error: %@", [error localizedDescription]);
                
                NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.mp4", video.provider, video.providerId]];
                
                NSLog(@"########## Writing video to file.");

                if ([data writeToFile:path options:0 error:&error]) {
                    NSLog(@"########## Write video file successful: %@", path);
                } else {
                    NSLog(@"########## Write video file failed: %@", path);
                }
                
                NSLog(@"########## Error: %@", [error localizedDescription]);
                
                video.contentURL = [NSURL fileURLWithPath:path];
            }
        }
    }
    
    [self reloadTableVideos];
    
    NSLog(@"########## Done.");
    
    [pool release];
}

@end

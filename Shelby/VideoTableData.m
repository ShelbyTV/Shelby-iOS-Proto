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
#import "VideoTableViewCellConstants.h"
#import "VideoGetter.h"

#pragma mark - Constants

#define kMaxVideoThumbnailHeight 163
#define kMaxVideoThumbnailWidth 290
#define kMaxSharerImageHeight 45
#define kMaxSharerImageWidth 45

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

    if (IS_NULL(videoData.contentURL)) {
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

- (void)downloadSharerImage:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:video.sharerImageURL];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (NOT_NULL(data)) {
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setUndoManager:nil];
        [context setPersistentStoreCoordinator:psCoordinator];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        // resize down to the largest size we use anywhere. this should speed up table view scrolling.
        video.sharerImage = [self scaleImage:[UIImage imageWithData:data] toSize:CGSizeMake(kMaxSharerImageWidth,
                                                                                            kMaxSharerImageHeight)];
        
        [[ShelbyApp sharedApp].loginHelper storeBroadcastVideo:video 
                                           withSharerImageData:UIImagePNGRepresentation(video.sharerImage)
                                                     inContext:context];
        
        [context release];
        
        [self updateVideoTableCell:video];
    }
    
    [pool release];
}

- (void)downloadVideoThumbnail:(Video *)video
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:video.thumbnailURL];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (NOT_NULL(data)) {
        NSPersistentStoreCoordinator *psCoordinator = [ShelbyApp sharedApp].persistentStoreCoordinator;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setUndoManager:nil];
        [context setPersistentStoreCoordinator:psCoordinator];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        // resize down to the largest size we use anywhere. this should speed up table view scrolling.
        video.thumbnailImage = [self scaleImage:[UIImage imageWithData:data] toSize:CGSizeMake(kMaxVideoThumbnailWidth,
                                                                                                                               kMaxVideoThumbnailHeight)];
        
        [[ShelbyApp sharedApp].loginHelper storeBroadcastVideo:video 
                                             withThumbnailData:UIImagePNGRepresentation(video.thumbnailImage)
                                                     inContext:context];
        
        [context release];
        
        [self updateVideoTableCell:video];
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
    if (NOT_NULL(broadcast.watchLater)) video.isWatchLater = [broadcast.watchLater boolValue];
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

- (void)insertTableVideos
{
    // insert 1 dummy entry for the onboarding
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    self.numItemsInserted = 1;
    [tableView endUpdates];
    
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
        
        if (watchLaterOnly) {
            BOOL watchLaterDupe = NO;
            for (Video *video in dupeArray) {
                if (video.isWatchLater) {
                    watchLaterDupe = YES;
                    break;
                }
            }
            if (!watchLaterDupe)
            {
                continue;
            }
        }
        
        Video *video = [dupeArray objectAtIndex:0];        
        int index = [tableVideos count] + 1; // +1 is for the onboarding cell
        [tableVideos addObject:video];
        
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        self.numItemsInserted = index + 1;
        [tableView endUpdates];
    }
    
    if (self.numItemsInserted > 1) {
        [tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:1 inSection: 0]
                         atScrollPosition: UITableViewScrollPositionTop
                                 animated: NO];
    }
}

- (void)reloadTableVideos
{
    @synchronized(tableVideos)
    {
        [self clearVideoTableWithArrayLockHeld];
        [self performSelectorOnMainThread:@selector(insertTableVideos) withObject:nil waitUntilDone:NO];
    }
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

- (void)reloadBroadcastsFromCoreData
{    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil];
    NSArray *broadcasts = [self fetchBroadcastsFromCoreDataContext:context];

    if (IS_NULL(broadcasts)) {
        [context release];
        return;
    } 
        
    @synchronized(tableVideos)
    {
        // Clear out the old broadcasts.
        [videoDupeDict removeAllObjects];
        [uniqueVideoKeys removeAllObjects];
        [self clearVideoTableWithArrayLockHeld];
        
        // Load up the new broadcasts.
        for (Broadcast *broadcast in broadcasts) {            
            // For now, we only handle YouTube.
            if (IS_NULL(broadcast.provider) || !([broadcast.provider isEqualToString: @"youtube"] ||
                                                 [broadcast.provider isEqualToString: @"vimeo"])) {
                continue;
            }

            // Need provider (checked above) and providerId to be able to display the video
            if (IS_NULL(broadcast.providerId) || [broadcast.providerId isEqualToString:@""]) {
                continue;
            }
            
            // check for a valid Vimeo ID (should be a single number) 
            if ([broadcast.provider isEqualToString: @"vimeo"] &&
                ![broadcast.providerId isEqualToString:[NSString stringWithFormat:@"%d", [broadcast.providerId intValue]]])
            {
                continue;
            }
            
            if ([broadcast.provider isEqualToString: @"youtube"] &&
                ![self checkYouTubePrivileges:broadcast.providerId])
            {
                continue;
            }
            
            Video *video = [[[Video alloc] init] autorelease];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                video.cellHeightCurrent = IPAD_CELL_HEIGHT;
            } else {
                video.cellHeightCurrent = IPHONE_CELL_HEIGHT;
            }

            NSMutableArray *dupeArray = [videoDupeDict objectForKey:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            if (NOT_NULL(dupeArray)) {
                [dupeArray insertObject:video atIndex:0];
            } else {
                dupeArray = [[[NSMutableArray alloc] init] autorelease];
                [dupeArray addObject:video];
                [videoDupeDict setObject:dupeArray forKey:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
                [uniqueVideoKeys addObject:[self dupeKeyWithProvider:broadcast.provider withId:broadcast.providerId]];
            }

            // create Video from Broadcast
            [self copyBroadcast:broadcast intoVideo:video];

            // need the sharerImage even for dupes
            if (IS_NULL(video.sharerImage)) {
                [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadSharerImage:) object:video] autorelease]];
            }
            
            // could optimize to not re-download for dupes, but don't bother for now...
            if (IS_NULL(video.thumbnailImage)) {
                [operationQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadVideoThumbnail:) object:video] autorelease]];
            }
        }
            
        [self performSelectorOnMainThread:@selector(insertTableVideos) withObject:nil waitUntilDone:NO];

    }
    
    [context release];
    
    [self.delegate videoTableDataDidFinishRefresh:self];
}

#pragma mark - Notifications

- (void)receivedBroadcastsNotification:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(reloadBroadcastsFromCoreData) userInfo:nil repeats:NO];
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
        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:8];
        [operationQueue addObserver: self
                         forKeyPath: @"operations"
                            options: NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                            context: NULL
         ];

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

#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == operationQueue && [keyPath isEqualToString:@"operations"]) {
        
        NSInteger operationCount = [operationQueue operationCount];

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

@end

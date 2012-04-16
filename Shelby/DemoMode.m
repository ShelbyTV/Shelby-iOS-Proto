//
//  DemoMode.m
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "DemoMode.h"
#import "VideoDupeArray.h"
#import "ShelbyApp.h"
#import "VideoData.h"
#import "Video.h"
#import "Enums.h"

@implementation DemoMode

+ (BOOL)passesDemoModeIncludeCheck:(NSArray *)dupeArray
{
    // sketchy place to put this... but it works
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
    
    return TRUE;
}

+ (void)enableDemoMode
{    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    for (VideoDupeArray *dupeArray in [ShelbyApp sharedApp].videoData.videoDupeArraysSorted)
    {
        NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
        
        NSArray *videos = [[dupeArray copyOfVideoArray] autorelease];
        Video *video = [videos objectAtIndex:0];
        
        if (video.isPlayable != IS_PLAYABLE || IS_NULL(video.contentURL)) {
            [loopPool drain];
            continue;
        }
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:video.contentURL];
        [request setValue:[ShelbyApp sharedApp].safariUserAgent forHTTPHeaderField:@"User-Agent"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[paths objectAtIndex:0] withIntermediateDirectories:YES attributes:nil error:&error];
        
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.mp4", video.provider, video.providerId]];      
        
        [data writeToFile:path options:0 error:&error];
        
        for (Video *iter in videos) {
            iter.contentURL = [NSURL fileURLWithPath:path];
        }
        
        [loopPool drain];
    }
    
    [[ShelbyApp sharedApp].videoData reloadTableVideos];
        
    [pool release];
}

@end

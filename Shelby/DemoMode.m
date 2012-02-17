//
//  DemoMode.m
//  Shelby
//
//  Created by Mark Johnson on 2/1/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "DemoMode.h"

@implementation DemoMode

- (void)enableDemoMode
{    
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//    
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSMutableURLRequest *request = nil;
//    
//    for (NSString *key in videoDupeArraysSorted)
//    {
//        NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
//        
//        if (NOT_NULL([playableVideoKeys objectForKey:key]))
//        {
//            NSArray *dupeArray = [videoDupeDict objectForKey:key];
//            Video *video = [dupeArray objectAtIndex:0];        
//            
//            if (NOT_NULL(video.contentURL)) {
//                
//                NSLog(@"########## Creating NSURLRequest.");
//                
//                request = [NSMutableURLRequest requestWithURL:video.contentURL];
//                
//                NSLog(@"########## Sending SynchronousRequest.");
//                
//                [request setValue:[ShelbyApp sharedApp].safariUserAgent forHTTPHeaderField:@"User-Agent"];
//                
//                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//                
//                NSLog(@"########## Data in MB: %.2f", (float)([data length] / 1024.0 / 1024.0));
//                NSLog(@"########## Error: %@", [error localizedDescription]);
//                
//                NSLog(@"########## Creating fileURL in bundle.");
//                
//                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                
//                NSLog(@"########## Creating directory path in bundle.");
//                [[NSFileManager defaultManager] createDirectoryAtPath:[paths objectAtIndex:0] withIntermediateDirectories:YES attributes:nil error:&error];
//                
//                NSLog(@"########## Error: %@", [error localizedDescription]);
//                
//                NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.mp4", video.provider, video.providerId]];
//                
//                NSLog(@"########## Writing video to file.");
//                
//                if ([data writeToFile:path options:0 error:&error]) {
//                    NSLog(@"########## Write video file successful: %@", path);
//                } else {
//                    NSLog(@"########## Write video file failed: %@", path);
//                }
//                
//                NSLog(@"########## Error: %@", [error localizedDescription]);
//                
//                video.contentURL = [NSURL fileURLWithPath:path];
//            }
//        }
//        
//        [loopPool drain];
//    }
//    
//    [self reloadTableVideos];
//    
//    NSLog(@"########## Done.");
//    
//    [pool release];
}

@end

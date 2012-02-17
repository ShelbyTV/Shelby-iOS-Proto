//
//  VideoTableSearchData.m
//  Shelby
//
//  Created by Mark Johnson on 2/3/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoTableSearchData.h"
#import "Video.h"
#import "Macros.h"
#import "DemoMode.h"

@implementation VideoTableSearchData

@synthesize searchString;

- (BOOL)shouldIncludeVideo:(NSArray *)dupeArray
{
    if (IS_NULL(searchString)) {
        return FALSE;
    }
    
    if (![DemoMode passesDemoModeIncludeCheck:dupeArray]) {
        return FALSE;
    }
    
    for (Video *video in dupeArray) {
        if (NOT_NULL(video.sharer) && [video.sharer rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            LOG(@"video.sharer (%@) contains searchString (%@)", video.sharer, searchString);
            return TRUE;
        }
        if (NOT_NULL(video.title) && [video.title rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            LOG(@"video.title (%@) contains searchString (%@)", video.title, searchString);
            return TRUE;
        }
        if (NOT_NULL(video.sharerComment) && [video.sharerComment rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) 
        {
            LOG(@"video.sharerComment (%@) contains searchString (%@)", video.sharerComment, searchString);
            return TRUE;
        }
    }
    
    return FALSE;
}

@end

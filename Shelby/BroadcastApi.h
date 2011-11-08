//
//  BroadcastApi.h
//  Shelby
//
//  Created by Mark Johnson on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video;

@interface BroadcastApi : NSObject {
}

+ (void)dislike:(Video *)video;
+ (void)like:(Video *)video;

+ (void)unwatchLater:(Video *)video;
+ (void)watchLater:(Video *)video;

+ (void)watch:(Video *)video;

+ (void)share:(Video *)video 
      comment:(NSString *)comment 
     networks:(NSArray *)networks    // twitter, facebook
    recipient:(NSString *)recipient; // email

@end

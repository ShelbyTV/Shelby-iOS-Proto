//
//  BroadcastApi.h
//  Shelby
//
//  Created by Mark Johnson on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BroadcastApi : NSObject

+ (void)dislike:(NSString *)videoId;
+ (void)like:(NSString *)videoId;
+ (void)watch:(NSString *)videoId;
+ (void)share:(NSString *)videoId 
      comment:(NSString *)comment 
     networks:(NSArray *)networks    // twitter, facebook
    recipient:(NSString *)recipient; // email

@end

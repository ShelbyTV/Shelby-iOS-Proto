//
//  PlatformHelper.h
//  Shelby
//
//  Created by Mark Johnson on 11/16/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlatformHelper : NSObject

+ (NSString *)platform;
+ (int)minimumRAM;
+ (int)maxVideos;

@end

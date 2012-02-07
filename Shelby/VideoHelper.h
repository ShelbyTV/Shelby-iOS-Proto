//
//  VideoHelper.h
//  Shelby
//
//  Created by Mark Johnson on 2/6/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoHelper : NSObject

+ (NSString *)dupeKeyWithProvider:(NSString *)provider 
                           withId:(NSString *)providerId;

@end

//
//  VideoHelper.m
//  Shelby
//
//  Created by Mark Johnson on 2/6/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoHelper.h"

@implementation VideoHelper

+ (NSString *)dupeKeyWithProvider:(NSString *)provider 
                           withId:(NSString *)providerId
{
    return [NSString stringWithFormat:@"%@%@", provider, providerId];
}

@end

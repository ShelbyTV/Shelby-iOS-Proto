//
//  KitchenSinkUtilities.m
//  Shelby
//
//  Created by Mark Johnson on 3/6/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "KitchenSinkUtilities.h"

@implementation KitchenSinkUtilities

+ (void)clearAllCookies
{
    NSHTTPCookie *cookie;
	for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		//NSLog(@"%@", [cookie description]);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
	}
}

@end

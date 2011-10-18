//
//  ApiMutableURLRequest.m
//  Shelby
//
//  Created by Mark Johnson on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ApiMutableURLRequest.h"

@implementation ApiMutableURLRequest

@synthesize userInfoDict;

- (void) dealloc
{
    userInfoDict = nil;
    [super dealloc];
}

@end

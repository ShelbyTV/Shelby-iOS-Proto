//
//  ApiMutableURLRequest.h
//  Shelby
//
//  Created by Mark Johnson on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OAuthMutableURLRequest.h"

@interface ApiMutableURLRequest : OAuthMutableURLRequest

@property (nonatomic, retain) NSDictionary *userInfoDict;

@end

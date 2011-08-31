//
//  NetworkManager.m
//  Shelby
//
//  Created by David Kay on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkManager.h"
#import "LoginHelper.h"

@implementation NetworkManager

@synthesize loginHelper;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.loginHelper = [[[LoginHelper alloc] init] autorelease];
    }
    return self;
}


- (void)beginOAuthHandshake {
    [self.loginHelper getRequestToken];
}

- (void)oAuthVerifierReturned:(NSString *)verifier {
    [self.loginHelper verifierReturnedFromAuth: verifier];
}

- (void)fetchBroadcasts {
    [self.loginHelper fetchBroadcasts];
}

@end

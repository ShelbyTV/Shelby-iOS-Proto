//
//  ShelbyApp.m
//  Shelby
//
//  Created by David Kay on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShelbyApp.h"

@implementation ShelbyApp

static ShelbyApp *gShelbyApp;

+ (ShelbyApp *)sharedApp {
  if (!gShelbyApp) {
    gShelbyApp = [[ShelbyApp alloc] init];
  }
  return gShelbyApp;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end

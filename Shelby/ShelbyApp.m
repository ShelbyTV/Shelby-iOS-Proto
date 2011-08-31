//
//  ShelbyApp.m
//  Shelby
//
//  Created by David Kay on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShelbyApp.h"
#import "LoginHelper.h"
#import "NetworkManager.h"

@implementation ShelbyApp

@synthesize networkManager;

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
      self.networkManager = [[[NetworkManager alloc] init] autorelease];
    }
    
    return self;
}

@end

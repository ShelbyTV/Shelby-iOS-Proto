//
//  ShelbyApp.h
//  Shelby
//
//  Created by David Kay on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Global singleton for maintaining state.
 */
@interface ShelbyApp : NSObject

+ (ShelbyApp *)sharedApp;

@end

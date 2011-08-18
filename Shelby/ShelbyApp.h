//
//  ShelbyApp.h
//  Shelby
//
//  Created by David Kay on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginHelper;

/*
 * Global singleton for maintaining state.
 */
@interface ShelbyApp : NSObject {
}
@property (nonatomic, retain) LoginHelper *loginHelper;

+ (ShelbyApp *)sharedApp;

@end

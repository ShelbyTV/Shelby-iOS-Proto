//
//  iRater.h
//  iRater
//
//  Created by Arthur on 4/15/12.
//  Copyright (c) 2012 ArtSabintsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iRater : NSObject

- (void)recordEvent;                // Event tracking method
+ (iRater*)sharedInstance;          // Singleton class method

@end
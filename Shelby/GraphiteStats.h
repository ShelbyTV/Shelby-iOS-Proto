//
//  GraphiteStats.h
//  Shelby
//
//  Created by Mark Johnson on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@interface GraphiteStats : NSObject {
}

+ (void)incrementCounter:(NSString *)counterName;

@end
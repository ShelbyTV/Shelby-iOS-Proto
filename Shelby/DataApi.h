//
//  DataApi.h
//  Shelby
//
//  Created by Mark Johnson on 2/7/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataApi : NSObject <NSURLConnectionDelegate>

+ (void)fetchCurrentUserAuthentications;
+ (void)fetchChannels;
+ (void)fetchAndStoreUserSessionData;

+ (void)fetchBroadcastsAndStoreInCoreData;
+ (void)synchronousFetchBroadcastsAndStoreInCoreData;
+ (void)fetchPollingBroadcastsAndStoreInCoreData;

@end

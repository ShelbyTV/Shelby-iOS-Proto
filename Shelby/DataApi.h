//
//  DataApi.h
//  Shelby
//
//  Created by Mark Johnson on 2/7/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJsonStreamParser.h"

typedef enum {
    ParserModeIdle,
    ParserModeUser,
    ParserModeBroadcasts,
    ParserModeChannels,
} ParserMode;

@interface DataApi : NSObject <SBJsonStreamParserDelegate>
{
    SBJsonStreamParser *_parser;
    ParserMode _parserMode;
}

@property (nonatomic, retain) NSDate *lastFetchBroadcasts;

- (void)fetchCurrentUserAuthentications;
- (void)fetchBroadcasts;
- (void)fetchUserId;

@end

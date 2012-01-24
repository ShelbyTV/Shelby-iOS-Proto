//
//  Broadcast.h
//  Shelby
//
//  Created by David Kay on 9/22/11.
//  Copyright (c) 2011 Gargoyle Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;
@class SharerImage;
@class ThumbnailImage;

@interface Broadcast : NSManagedObject {
}

@property (nonatomic, retain) Channel        *channel;
@property (nonatomic, retain) SharerImage    *sharerImage;
@property (nonatomic, retain) ThumbnailImage *thumbnailImage;

@property (nonatomic, retain) NSDate   *createdAt;
@property (nonatomic, retain) NSNumber *liked;
@property (nonatomic, retain) NSNumber *watchLater;
@property (nonatomic, retain) NSString *origin;
@property (nonatomic, retain) NSString *provider;
@property (nonatomic, retain) NSString *providerId;
@property (nonatomic, retain) NSString *sharerComment;
@property (nonatomic, retain) NSString *sharerImageUrl;
@property (nonatomic, retain) NSString *sharerName;
@property (nonatomic, retain) NSString *shelbyId;
@property (nonatomic, retain) NSString *shortPermalink;
@property (nonatomic, retain) NSString *thumbnailImageUrl;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *watched;
@property (nonatomic, retain) NSNumber *isPlayable;

- (void)populateFromApiJSONDictionary:(NSDictionary *)dict;

@end

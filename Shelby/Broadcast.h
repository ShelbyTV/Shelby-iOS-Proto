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
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSString *providerId;
@property (nonatomic, copy) NSString *sharerComment;
@property (nonatomic, copy) NSString *sharerImageUrl;
@property (nonatomic, copy) NSString *sharerName;
@property (nonatomic, copy) NSString *shelbyId;
@property (nonatomic, copy) NSString *shortPermalink;
@property (nonatomic, copy) NSString *thumbnailImageUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSNumber *watched;
@property (nonatomic, retain) NSNumber *isPlayable;

- (void)populateFromApiJSONDictionary:(NSDictionary *)dict;

@end

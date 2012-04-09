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

@property (strong, nonatomic) Channel        *channel;
@property (strong, nonatomic) SharerImage    *sharerImage;
@property (strong, nonatomic) ThumbnailImage *thumbnailImage;

@property (strong, nonatomic) NSDate   *createdAt;
@property (strong, nonatomic) NSNumber *liked;
@property (strong, nonatomic) NSNumber *watchLater;
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
@property (strong, nonatomic) NSNumber *watched;
@property (strong, nonatomic) NSNumber *isPlayable;

- (void)populateFromApiJSONDictionary:(NSDictionary *)dict;

@end

//
//  Video.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Broadcast;

@interface Video : NSObject {
}

@property (nonatomic, retain) NSString *provider;
@property (nonatomic, retain) NSString *providerId;
@property (nonatomic, retain) NSURL *contentURL;
@property (nonatomic, retain) NSURL *thumbnailURL;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sharer;
@property (nonatomic, copy) NSString *sharerComment;
@property (nonatomic, retain) NSURL *sharerImageURL;
@property (nonatomic, retain) UIImage *sharerImage;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *shelbyId;
@property (nonatomic, copy) NSString *shortPermalink;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic) BOOL isLiked;
@property (nonatomic) BOOL isWatchLater;
@property (nonatomic) BOOL isWatched;
@property (nonatomic) float cellHeightAllComments;
@property (nonatomic) BOOL allComments;
@property (nonatomic) float cellHeightCurrent;
@property (nonatomic) BOOL currentlyPlaying;
@property (nonatomic) int isPlayable;

- (id)initWithBroadcast:(Broadcast *)broadcast;

@end

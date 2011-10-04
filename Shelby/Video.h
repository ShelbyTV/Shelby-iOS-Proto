//
//  Video.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/11/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Video : NSObject {
    
}

@property (nonatomic, retain) NSURL *youTubeVideoInfoURL;
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
@property (nonatomic) BOOL isWatched;
@property (nonatomic) int arrayGeneration;

@end

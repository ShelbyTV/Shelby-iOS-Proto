//
//  ThumbnailImage.h
//  Shelby
//
//  Created by Mark Johnson on 11/17/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Broadcast;

@interface ThumbnailImage : NSManagedObject

@property (strong, nonatomic) Broadcast *broadcast;
@property (strong, nonatomic) NSData *imageData;

@end

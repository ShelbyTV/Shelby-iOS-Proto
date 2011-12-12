//
//  SharerImage.h
//  Shelby
//
//  Created by Mark Johnson on 11/17/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Broadcast;

@interface SharerImage : NSManagedObject

@property (nonatomic, retain) Broadcast *broadcast;
@property (nonatomic, retain) NSData *imageData;

@end

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

@property(nonatomic, retain) NSURL *contentURL;

@property(nonatomic, retain) UIImage *thumbnail;
@property(nonatomic, retain) NSString *title;

@property(nonatomic, retain) NSString *sharer;
@property(nonatomic, retain) NSString *sharerComment;
@property(nonatomic, retain) UIImage *sharerImage;

@end

//
//  Macros.h
//  Shelby
//
//  Created by David Young-Chan Kay on 8/5/11.
//  Copyright 2011 Gargoyle Software. All rights reserved.
//

#ifdef DEBUG
    #define LOG(...) NSLog(__VA_ARGS__)
#else
    #define LOG(...)
#endif

#define LogRect(rectname, rect) LOG(@"%@:(%f, %f, %f, %f)", rectname, \
                                      rect.origin.x, \
                                      rect.origin.y, \
                                      rect.size.width, \
                                      rect.size.height)


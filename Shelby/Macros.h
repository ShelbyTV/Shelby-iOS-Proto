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

#define IS_NULL(x) (x == nil || [(x) isKindOfClass:[NSNull class]])
#define NOT_NULL(x) ((x) && ![(x) isKindOfClass:[NSNull class]])
#define SET_IF_NOT_NULL(y, z) {if (NOT_NULL(z)) { y = z; } }

// Needed by sample code, but only included in Three20/Three20
#define TT_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define TT_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
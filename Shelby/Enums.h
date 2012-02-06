//
//  Enums.h
//  Shelby
//
//  Created by Mark Johnson on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

typedef enum isPlayableEnum {
    NOT_PLAYABLE = 0,
    IS_PLAYABLE = 1,
    PLAYABLE_UNSET = 2
} isPlayableEnum;

typedef enum videoTableType {
    TIMELINE = 0,
    FAVORITES = 1,
    WATCHLATER = 2,
    SEARCH = 3
} videoTableType;
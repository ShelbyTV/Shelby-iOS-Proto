//
//  PlatformHelper.m
//  Shelby
//
//  Created by Mark Johnson on 11/16/11.
//  Copyright (c) 2011 Shelby.tv. All rights reserved.
//

#import "PlatformHelper.h"
#import <sys/sysctl.h>

@implementation PlatformHelper

+ (NSString *)platform  
{  
    size_t size;  
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);  
    char *machine = malloc(size);  
    sysctlbyname("hw.machine", machine, &size, NULL, 0);  
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];  
    free(machine);
    return platform;  
}

+ (int)minimumRAM
{
    NSString *platform = [PlatformHelper platform];
    if ([platform hasPrefix:@"iPhone1,1"]) { // original iPhone
        return 128;
    }
    if ([platform hasPrefix:@"iPhone1,2"]) { // iPhone 3G
        return 128;
    }
    if ([platform hasPrefix:@"iPhone2,1"]) { // iPhone 3GS
        return 256;
    }
    if ([platform hasPrefix:@"iPhone3,1"]) { // iPhone 3GS
        return 512;
    }
    if ([platform hasPrefix:@"iPhone"]) { // later iPhones
        return 512;
    }
    if ([platform hasPrefix:@"iPod1,1"]) { // iPod Touch 1G
        return 128;
    }
    if ([platform hasPrefix:@"iPod2,1"]) { // iPod Touch 2G
        return 128;
    }
    if ([platform hasPrefix:@"iPod3,1"]) { // iPod Touch 3G
        return 256;
    }
    if ([platform hasPrefix:@"iPod4,1"]) { // iPod Touch 4G
        return 256;
    }
    if ([platform hasPrefix:@"iPod"]) { // later iPods
        return 512;
    }
    if ([platform hasPrefix:@"iPad1"]) { // iPad 1
        return 256;
    }
    if ([platform hasPrefix:@"iPad2"]) { // iPad 2
        return 512;
    }
    if ([platform hasPrefix:@"iPad"]) { // later iPads
        return 512;
    }
    
    // otherwise assume a lot of memory
    return 512;
}

@end

//
//  NSDate+CheckShutdownDate.m
//  Shelby
//
//  Created by Arthur Ariel Sabintsev on 7/1/12.
//
//

#import "NSDate+CheckShutdownDate.h"

@implementation NSDate (CheckShutdownDate)

+ (BOOL)checkShutdownDate
{
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy HH:mm"];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    [format setTimeZone:timeZone];
    
    NSString *shutdownString = @"07-01-2012 21:00";
    NSDate *shutdownDate = [format dateFromString:shutdownString];
    
    NSLog(@"\nToday's Date:%@\nShutdown Date: %@", currentDate, shutdownDate);
    
    return [currentDate timeIntervalSinceDate:shutdownDate] > 0 ? YES : NO;
}

@end

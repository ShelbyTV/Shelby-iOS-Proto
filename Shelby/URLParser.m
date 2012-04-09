//
//  URLParser.m
//  NSScannerTest
//
//  Created by Dimitris on 09/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "URLParser.h"

@implementation URLParser
@synthesize variables;

- (id)initWithURLString:(NSString *)url
{
    self = [super init];
    
    if (self != nil)
    {
        NSScanner *scanner = [NSScanner scannerWithString:url];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
        
        NSMutableArray *vars = [[NSMutableArray alloc] init];
        [scanner scanUpToString:@"?" intoString:nil]; // ignore the beginning of the string and skip to the vars
        
        NSString *tempString;
        while ([scanner scanUpToString:@"&" intoString:&tempString]) {
            [vars addObject:tempString];
        }
        self.variables = vars;
    }
    return self;
}

- (NSString *)valueForVariable:(NSString *)varName
{
    NSString *varNameWithEquals = [varName stringByAppendingString:@"="];
    
    for (NSString *var in self.variables)
    {
        if ([var hasPrefix:varNameWithEquals]) {
            return [var substringFromIndex:[varNameWithEquals length]];
        }
    }
    return nil;
}


@end

//
//  URLParser.h
//  NSScannerTest
//
//  Created by Dimitris on 09/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// Taken from: http://iphone.demay-fr.net/2010/04/parsing-url-parameters-in-a-nsstring/

#import <Foundation/Foundation.h>


@interface URLParser : NSObject {
  NSArray *variables;
}

@property (nonatomic, retain) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;

@end

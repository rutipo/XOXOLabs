//
//  NSString+URLEncodedString.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+URLEncodedString.h"

@implementation NSString (URLEncodedString)
- (NSString *)URLencodedString
{
    NSString *newString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                (__bridge CFStringRef)self,
                                                                                NULL,
                                                                                CFSTR("!*'();:@&=+$,/?%#[]\""),
                                                                                kCFStringEncodingUTF8));
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return newString;
}

@end

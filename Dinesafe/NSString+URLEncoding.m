//
//  NSString+URLEncoding.m
//  Dinesafe
//
//  Created by Matt Ruten on 2013-02-02.
//  Copyright (c) 2013 Matt Ruten. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

-(NSString *)urlEncode {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)self, NULL,
                                                                        (CFStringRef)@"!*'\"();:@&=+$,/?%#[] ",
                                                                        kCFStringEncodingUTF8);
}

@end

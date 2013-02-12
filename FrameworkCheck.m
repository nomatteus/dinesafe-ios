//
//  FrameworkCheck.m
//  Dinesafe
//
//  Created by Matt Ruten on 2013-02-12.
//  Copyright (c) 2013 Matt Ruten. All rights reserved.
//

#import "FrameworkCheck.h"

@implementation FrameworkCheck

// thnx: http://stackoverflow.com/a/12514036/76710

+(BOOL)isTwitterAvailable {
    return NSClassFromString(@"TWTweetComposeViewController") != nil;
}

+(BOOL)isSocialAvailable {
    return NSClassFromString(@"SLComposeViewController") != nil;
}

@end

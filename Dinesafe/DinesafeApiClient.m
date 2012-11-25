//
//  DinesafeApiClient.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-24.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeApiClient.h"

#define DINESAFE_API_BASE_URL @"http://dinesafe.dev/api/1.0/"

@implementation DinesafeApiClient

+ (id)sharedInstance {
    static DinesafeApiClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[DinesafeApiClient alloc] initWithBaseURL:
                            [NSURL URLWithString:DINESAFE_API_BASE_URL]];
    });
    
    return __sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        // custom settings/headers
        // [self setDefaultHeader:@"x-api-token" value:DinesafeApiToken];
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    
    return self;
}

@end

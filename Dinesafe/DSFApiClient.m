//
//  DinesafeApiClient.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-24.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFApiClient.h"

@implementation DSFApiClient

+ (id)sharedInstance {
    static DSFApiClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[DSFApiClient alloc] initWithBaseURL:
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

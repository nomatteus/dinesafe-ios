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
        if (DINE_SURREY) {
            __sharedInstance = [[DSFApiClient alloc] initWithBaseURL:[NSURL URLWithString:SURREY_API_BASE_URL]];
            NSLog(@"SURREY_API_BASE_URL = %@", SURREY_API_BASE_URL);
        } else {
            __sharedInstance = [[DSFApiClient alloc] initWithBaseURL:[NSURL URLWithString:DINESAFE_API_BASE_URL]];
            NSLog(@"DINESAFE_API_BASE_URL = %@", DINESAFE_API_BASE_URL);
        }
        
        
    });
    
    return __sharedInstance;
}

// Assumed to be ArcGIS - Surrey server
+ (id)sharedInstanceWithGeometries {
    static DSFApiClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[DSFApiClient alloc] initWithBaseURL:[NSURL URLWithString:SURREY_GEOMETRY_SERVICE_URL]];
        NSLog(@"SURREY_GEOMETRY_SERVICE_URL = %@", SURREY_GEOMETRY_SERVICE_URL);
    });
    
    return __sharedInstance;
}

+ (id)sharedInstanceRelatedRecords {
    static DSFApiClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[DSFApiClient alloc] initWithBaseURL:[NSURL URLWithString:SURREY_RELATED_RECORDS_URL]];
        NSLog(@"SURREY_RELATED_RECORDS_URL = %@", SURREY_RELATED_RECORDS_URL);
    });
    
    return __sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        // custom settings/headers
        // [self setDefaultHeader:@"x-api-token" value:DinesafeApiToken];
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        // Required by ArcGIS server at City of Surrey --dfd
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
        NSLog(@"AFJSONRequestOperation acceptableContentTypes = %@", [AFJSONRequestOperation acceptableContentTypes]);
        
    }
    
    return self;
}

@end

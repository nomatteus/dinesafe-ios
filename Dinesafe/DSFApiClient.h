//
//  DinesafeApiClient.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-24.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "AFNetworking.h"

#define DINESAFE_API_BASE_URL @"http://dinesafe.192.168.1.2.xip.io/api/1.0/"

@interface DSFApiClient : AFHTTPClient

+ (id)sharedInstance;

@end

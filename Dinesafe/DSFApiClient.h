//
//  DinesafeApiClient.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-24.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "AFNetworking.h"

#define DINESAFE_API_BASE_URL @"http://dinesafe.to/api/1.0/"
//#define DINESAFE_API_BASE_URL @"http://dinesafe.dev/api/1.0/"

// http://cosmos.surrey.ca/COSREST/rest/services/FH_Restaurants/MapServer/0/query?text=%25&geometry=&geometryType=esriGeometryPoint&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&objectIds=&where=&time=&returnCountOnly=false&returnIdsOnly=false&returnGeometry=true&maxAllowableOffset=&outSR=&outFields=&f=pjson

#define SURREY_API_BASE_URL @"http://cosmos.surrey.ca/COSREST/rest/services/FH_Restaurants/MapServer/0/"

// queryRelatedRecords example
// http://cosmos.surrey.ca/COSREST/rest/services/FH_Restaurants/MapServer/0/queryRelatedRecords?objectIds=225%2C+226%2C+227%2C+228%2C+229%2C+230%2C+231&relationshipId=0&definitionExpression=&returnGeometry=true&maxAllowableOffset=&outSR=&outFields=*&f=pjson"

// 0 == TORONTO | 1 == SURREY
#define DINE_SURREY 1

@interface DSFApiClient : AFHTTPClient

+ (id)sharedInstance;

@end

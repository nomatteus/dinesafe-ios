//
//  DSFEstablishment.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-12.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DSFInspection.h"

@interface DSFEstablishment : NSObject

@property (nonatomic) NSUInteger establishmentId;
@property (nonatomic, strong) NSString *latestName;
@property (nonatomic, strong) NSString *latestType;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) double distance;
@property (nonatomic, readwrite) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSMutableArray *inspections;

@property (nonatomic) int minimumInspectionsPerYear;

// Share Text/URL
@property (nonatomic, strong) NSString *shareTextShort;
@property (nonatomic, strong) NSString *shareTextLong;
@property (nonatomic, strong) NSString *shareTextLongHtml;
@property (nonatomic, strong) NSString *shareURL;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end

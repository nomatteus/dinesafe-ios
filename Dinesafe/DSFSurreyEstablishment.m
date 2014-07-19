//
//  DSFSurreyEstablishment.m
//  Dinesafe
//
//  Created by David Dumaresq on 2014-07-17.
//  Copyright (c) 2014 Matt Ruten. All rights reserved.
//

#import "DSFSurreyEstablishment.h"

@implementation DSFSurreyEstablishment

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.inspections = [NSMutableArray array];
        [self updateWithDictionary:dictionary];
    }
    return self;
}

/*
 updateWithDictionary = {
 FACTYPE = Restaurant;
 LATITUDE = "49.18981199";
 LONGITUDE = "-122.80140235";
 NAME = "Curry Express";
 OBJECTID = 249;
 PHYSICALADDRESS = "10355 152 St";
 PHYSICALCITY = Surrey;
 TRACKINGNUMBER = "NDAA-9H3PTE";
 */

- (void)updateWithDictionary:(NSDictionary *)dictionary {
//    NSLog(@"updateWithDictionary = %@", dictionary);
    
    self.establishmentId = [dictionary[@"id"] intValue];
    self.latestName      = dictionary[@"NAME"];
    self.latestType      = dictionary[@"FACTYPE"];
    self.address         = dictionary[@"PHYSICALADDRESS"];
    
/* too expensive to calculate here - calculate distance during table loading */
//    self.distance        = [dictionary[@"distance"] doubleValue];
    
    double lat           = [dictionary[@"LATITUDE"] doubleValue];
    double lng           = [dictionary[@"LONGITUDE"] doubleValue];
    self.location        = CLLocationCoordinate2DMake(lat, lng);
  
    // TODO
    if ([dictionary objectForKey:@"share"]) {
        self.shareTextShort = dictionary[@"share"][@"text_short"];
        self.shareTextLong = dictionary[@"share"][@"text_long"];
        self.shareTextLongHtml = dictionary[@"share"][@"text_long_html"];
        self.shareURL = dictionary[@"share"][@"url"];
    }
    
    // TODO
    for (id inspection in dictionary[@"inspections"]) {
        NSUInteger index = [self.inspections indexOfObjectPassingTest:
                            ^(DSFInspection *obj, NSUInteger idx, BOOL *stop) {
                                if (obj.inspectionId == [inspection[@"id"] intValue]) {
                                    return YES;
                                } else {
                                    return NO;
                                }
                            }];
        if (index == NSNotFound) {
            [self.inspections addObject:[[DSFInspection alloc] initWithDictionary:inspection]];
        } else {
            [self.inspections[index] updateWithDictionary:inspection];
        }
    }
/*
    if ([dictionary objectForKey:@"latlng"]
        && [dictionary[@"latlng"] isKindOfClass:[NSDictionary class]]
        && [dictionary[@"latlng"] objectForKey:@"lat"]
        && [dictionary[@"latlng"] objectForKey:@"lng"]) { // Checking for non-null latlng
        double lat = [dictionary[@"latlng"][@"lat"] doubleValue];
        double lng = [dictionary[@"latlng"][@"lng"] doubleValue];
        self.location = CLLocationCoordinate2DMake(lat, lng);
    }
*/
    [self setDefaultSharingValuesIfNil];
}

- (void)setDefaultSharingValuesIfNil {
    if (!self.shareTextShort) {
        self.shareTextShort = [NSString stringWithFormat:@"I'm looking at %@ results on Dinesafe TO app.", self.latestName];
    }
    if (!self.shareTextLong) {
        self.shareTextLong = self.shareTextShort;
    }
    if (!self.shareTextLongHtml) {
        self.shareTextLongHtml = self.shareTextLong;
    }
    if (!self.shareURL) {
        self.shareURL = @"http://dinesafe.to/app";
    }
}

- (int)minimumInspectionsPerYear {
    if (!_minimumInspectionsPerYear) {
        _minimumInspectionsPerYear = [self.inspections.lastObject minimumInspectionsPerYear];
    }
    return _minimumInspectionsPerYear;
}


@end

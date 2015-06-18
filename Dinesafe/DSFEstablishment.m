//
//  DSFEstablishment.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-12.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFEstablishment.h"


@interface DSFEstablishment ()

@end

@implementation DSFEstablishment

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.inspections = [NSMutableArray array];
        [self updateWithDictionary:dictionary];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    self.establishmentId = [dictionary[@"id"] intValue];
    self.latestName = dictionary[@"latest_name"];
    self.latestType = dictionary[@"latest_type"];
    self.address = dictionary[@"address"];
    self.distance = [dictionary[@"distance"] doubleValue];
    if ([dictionary objectForKey:@"share"]) {
        self.shareTextShort = dictionary[@"share"][@"text_short"];
        self.shareTextLong = dictionary[@"share"][@"text_long"];
        self.shareTextLongHtml = dictionary[@"share"][@"text_long_html"];
        self.shareURL = dictionary[@"share"][@"url"];
    }
    
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
    if ([dictionary objectForKey:@"latlng"]
        && [dictionary[@"latlng"] isKindOfClass:[NSDictionary class]]
        && [dictionary[@"latlng"] objectForKey:@"lat"]
        && [dictionary[@"latlng"] objectForKey:@"lng"]) { // Checking for non-null latlng
        double lat = [dictionary[@"latlng"][@"lat"] doubleValue];
        double lng = [dictionary[@"latlng"][@"lng"] doubleValue];
        self.location = CLLocationCoordinate2DMake(lat, lng);
    }
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

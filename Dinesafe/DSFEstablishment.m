//
//  DinesafeEstablishment.m
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
    
    // self.location = TODO;
}

- (int)minimumInspectionsPerYear {
    if (!_minimumInspectionsPerYear) {
        _minimumInspectionsPerYear = [self.inspections.lastObject minimumInspectionsPerYear];
    }
    return _minimumInspectionsPerYear;
}

@end

//
//  DinesafeEstablishment.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-12.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeEstablishment.h"

@implementation DinesafeEstablishment

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
                            ^(DinesafeInspection *obj, NSUInteger idx, BOOL *stop) {
                                if (obj.inspectionId == [inspection[@"id"] intValue]) {
                                    return YES;
                                } else {
                                    return NO;
                                }
                            }];
        if (index == NSNotFound) {
            [self.inspections addObject:[[DinesafeInspection alloc] initWithDictionary:inspection]];
        } else {
            [self.inspections[index] updateWithDictionary:inspection];
        }
    }
    
    // self.location = TODO;
}

@end

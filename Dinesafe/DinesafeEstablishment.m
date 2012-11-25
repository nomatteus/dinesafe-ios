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
        self.establishmentId = dictionary[@"id"];
        self.latestName = dictionary[@"latest_name"];
        self.latestType = dictionary[@"latest_type"];
        self.address = dictionary[@"address"];
        self.distance = [dictionary[@"distance"] doubleValue];
  
        self.inspections = [NSMutableArray array];
        for (id inspection in dictionary[@"inspections"]) {
            [self.inspections addObject:[[DinesafeInspection alloc] initWithDictionary:inspection]];
        }
        
        // self.location = TODO;
    }
    return self;
}

@end

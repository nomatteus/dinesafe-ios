//
//  DinesafeInspection.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-19.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeInspection.h"

@implementation DinesafeInspection

-(id) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        self.inspectionId = dictionary[@"id"];
        self.status = dictionary[@"status"];
        self.establishment_name = dictionary[@"establishment_name"];
        self.establishment_type = dictionary[@"establishment_type"];
        self.minimumInspectionsPerYear = [dictionary[@"minimum_inspections_per_year"] intValue];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        self.date = [dateFormat dateFromString:dictionary[@"date"]];

        // self.infractions = TODO;
    }
    return self;
}

@end

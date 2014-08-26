//
//  DinesafeInfraction.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-19.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFInfraction.h"

@implementation DSFInfraction

- (id) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        [self updateWithDictionary:dictionary];
    }
    return self;
}

/*
 {
 HAZARDRATING = Low;
 INSPECTIONDATE = 20120522;
 INSPTYPE = "Follow-Up";
 NUMCRITICAL = 0;
 NUMNONCRITICAL = 0;
 OBJECTID = 2721;
 TRACKINGNUMBER = "ACAK-8VQSZM";
 VIOLLUMP = "<null>";
 }
 
 {
 HAZARDRATING = Low;
 INSPECTIONDATE = 20120424;
 INSPTYPE = Routine;
 NUMCRITICAL = 1;
 NUMNONCRITICAL = 2;
 OBJECTID = 6662;
 TRACKINGNUMBER = "GEDS-85ZM4Y";
 VIOLLUMP = "209,Not Critical,Food not protected from contamination [s. 12(a)],Not Repeat|...";
 }
 */
- (void)updateWithDictionary:(NSDictionary *) dictionary {
    self.infractionId = [dictionary[@"id"] intValue];
    self.details = dictionary[@"details"];
    self.severity = dictionary[@"severity"];
    self.action = dictionary[@"action"];
    self.courtOutcome = dictionary[@"court_outcome"];
    self.amountFined = [dictionary[@"amount_fined"] doubleValue];
}

- (CGSize)heightForSize:(CGSize)size andFont:(UIFont *)font {
    return [self.details sizeWithFont:font
                    constrainedToSize:size
                        lineBreakMode:NSLineBreakByWordWrapping];
}

@end

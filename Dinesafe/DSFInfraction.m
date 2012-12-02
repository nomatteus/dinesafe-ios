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

- (void)updateWithDictionary:(NSDictionary *) dictionary {
    self.infractionId = [dictionary[@"id"] intValue];
    self.details = dictionary[@"details"];
    self.severity = dictionary[@"severity"];
    self.action = dictionary[@"action"];
    self.courtOutcome = dictionary[@"court_outcome"];
    self.amountFined = [dictionary[@"amount_fined"] doubleValue];
}

@end

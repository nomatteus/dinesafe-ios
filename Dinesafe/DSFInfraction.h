//
//  DinesafeInfraction.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-19.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSFInfraction : NSObject

@property (nonatomic) NSUInteger infractionId;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) NSString *severity;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *courtOutcome;
@property (nonatomic) double amountFined;



- (id) initWithDictionary:(NSDictionary *) dictionary;
- (void)updateWithDictionary:(NSDictionary *) dictionary;

@end

//
//  DinesafeInfraction.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-19.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DinesafeInfraction : NSObject

//@property (nonatomic, strong) NSString *inspectionId;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) NSString *severity;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *courtOutcome;
@property (nonatomic) float amountFined;

@end

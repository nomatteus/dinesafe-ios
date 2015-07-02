//
//  DinesafeInspection.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-19.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSFInfraction.h"

@interface DSFInspection : NSObject

@property (nonatomic) NSUInteger inspectionId;
@property (nonatomic, strong) NSString *status;
@property (nonatomic) int minimumInspectionsPerYear;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *dateYear;
@property (nonatomic, strong) NSString *formattedDate;
@property (nonatomic, strong) NSString *establishment_name;
@property (nonatomic, strong) NSString *establishment_type;

@property (nonatomic, strong) NSMutableArray *infractions;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)updateWithDictionary:(NSDictionary *)dictionary;

- (NSMutableArray *)colorForStatusAtPositionRGBA:(int)position;
- (UIColor *)colorForStatusAtPositionUIColor:(int)position;
- (float)heightForInfractionsWithSize:(CGSize)size andFont:(UIFont *)font;

@end

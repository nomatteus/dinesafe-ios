//
//  DinesafeInspection.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-19.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFInspection.h"

const double kScoreBoxPassTopColorRGB[] = {40, 195, 38};
const double kScoreBoxPassBottomColorRGB[] = {35, 174, 33};
const double kScoreBoxConditionalPassTopColorRGB[] = {249, 255, 72};
const double kScoreBoxConditionalPassBottomColorRGB[] = {222, 228, 64};
const double kScoreBoxClosedTopColorRGB[] = {222, 45, 77};
const double kScoreBoxClosedBottomColorRGB[] = {196, 39, 68};
const double kScoreBoxOtherTopColorRGB[] = {130, 130, 130};
const double kScoreBoxOtherBottomColorRGB[] = {115, 115, 115};

@implementation DSFInspection

#pragma mark - Create and Update

- (id) initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    if (self) {
        self.infractions = [NSMutableArray array];
        [self updateWithDictionary:dictionary];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *) dictionary {
    
    self.inspectionId       = dictionary[@"TRACKINGNUMBER"];
    self.status             = dictionary[@"HAZARDRATING"];
    // TODO
    self.establishment_name = kNotAvailable;
    self.establishment_type = kNotAvailable;
    self.minimumInspectionsPerYear = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    self.date = [dateFormatter dateFromString:dictionary[@"INSPECTIONDATE"]];

    // Set some formatted date variables
    [dateFormatter setDateFormat:@"yyyy"];
    self.dateYear = [dateFormatter stringFromDate:self.date];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    self.formattedDate = [dateFormatter stringFromDate:self.date];

/*
    NSUInteger index = [self.inspections indexOfObjectPassingTest:
                        ^(DSFInspection *obj, NSUInteger idx, BOOL *stop) {
                            if ([obj.inspectionId isEqualToString:[inspection[@"TRACKINGNUMBER"]]]) {
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
*/

    // Infractions
    id lump = dictionary[@"VIOLLUMP"];
    if (lump == [NSNull null]) {
        NSLog(@"VIOLLUMP null");
        return;
    }
    else {
        NSArray *array = [lump componentsSeparatedByString:@"|"];

        for (NSMutableString *v in array) {
            NSArray *violation = [v componentsSeparatedByString:@","];
            
            // FIX: sometimes the violation detail contains commas that throw off the conversion to keys/values. Skipping for now.
            if ([violation count] != 4) {
                NSLog(@"skipping %@", v);
                continue;
            }
            NSArray *keys = [NSArray arrayWithObjects: @"id", @"severity", @"details", @"action", nil];
            
            NSDictionary *infraction = [NSDictionary dictionaryWithObjects:violation forKeys:keys];
            
            [self.infractions addObject:[[DSFInfraction alloc] initWithDictionary:infraction]];

        }
    }
    
}

#pragma mark -

// Height for all infractions
- (float)heightForInfractionsWithSize:(CGSize)size andFont:(UIFont *)font {
    float height = 0;
    for (id infraction in self.infractions) {
        // Padding is 10, change this in DSFInspectionCell as well
        height += [infraction heightForSize:size andFont:font].height + 10;
    }
    return height;
}

#pragma mark -

// Return a color for an inspection status (RGBA)
// status is "Low", "Moderate", or "High". Position is 0=top, 1=bottom
// TODO: This needs some major refactoring!!
- (NSMutableArray *)colorForStatusAtPositionRGBA:(int)position {
    if ([self.status isEqualToString:@"Low"]) {
        if (position == 0) {
            return [@[
                      [NSNumber numberWithDouble: kScoreBoxPassTopColorRGB[0]/255],
                      [NSNumber numberWithDouble: kScoreBoxPassTopColorRGB[1]/255],
                      [NSNumber numberWithDouble: kScoreBoxPassTopColorRGB[2]/255],
                      [NSNumber numberWithDouble: 1.0]
                      ] mutableCopy];
        } else {
            return [@[
                      [NSNumber numberWithDouble: kScoreBoxPassBottomColorRGB[0]/255],
                      [NSNumber numberWithDouble: kScoreBoxPassBottomColorRGB[1]/255],
                      [NSNumber numberWithDouble: kScoreBoxPassBottomColorRGB[2]/255],
                      [NSNumber numberWithDouble: 1.0]
                      ] mutableCopy];
        }
    } else if ([self.status isEqualToString:@"Moderate"]) {
        if (position == 0) {
            return [@[
                      [NSNumber numberWithDouble: kScoreBoxConditionalPassTopColorRGB[0]/255],
                      [NSNumber numberWithDouble: kScoreBoxConditionalPassTopColorRGB[1]/255],
                      [NSNumber numberWithDouble: kScoreBoxConditionalPassTopColorRGB[2]/255],
                      [NSNumber numberWithDouble: 1.0]
                      ] mutableCopy];
        } else {
            return [@[
                      [NSNumber numberWithDouble: kScoreBoxConditionalPassBottomColorRGB[0]/255],
                      [NSNumber numberWithDouble: kScoreBoxConditionalPassBottomColorRGB[1]/255],
                      [NSNumber numberWithDouble: kScoreBoxConditionalPassBottomColorRGB[2]/255],
                      [NSNumber numberWithDouble: 1.0]
                      ] mutableCopy];
        }
    } else if ([self.status isEqualToString:@"High"]) {
        if (position == 0) {
            return [@[
                      [NSNumber numberWithDouble: kScoreBoxClosedTopColorRGB[0]/255],
                      [NSNumber numberWithDouble: kScoreBoxClosedTopColorRGB[1]/255],
                      [NSNumber numberWithDouble: kScoreBoxClosedTopColorRGB[2]/255],
                      [NSNumber numberWithDouble: 1.0]
                      ] mutableCopy];
        } else {
            return [@[
                      [NSNumber numberWithDouble: kScoreBoxClosedBottomColorRGB[0]/255],
                      [NSNumber numberWithDouble: kScoreBoxClosedBottomColorRGB[1]/255],
                      [NSNumber numberWithDouble: kScoreBoxClosedBottomColorRGB[2]/255],
                      [NSNumber numberWithDouble: 1.0]
                      ] mutableCopy];
        }
    } else {
        // "Out of Business" or anything else: Use gray
        if (position == 0) {
            return [@[
                      [NSNumber numberWithDouble: kScoreBoxOtherTopColorRGB[0]/255],
                      [NSNumber numberWithDouble: kScoreBoxOtherTopColorRGB[1]/255],
                      [NSNumber numberWithDouble: kScoreBoxOtherTopColorRGB[2]/255],
                      [NSNumber numberWithDouble: 1.0]
                      ] mutableCopy];
        } else {
            return [@[
                      [NSNumber numberWithDouble: kScoreBoxOtherBottomColorRGB[0]/255],
                      [NSNumber numberWithDouble: kScoreBoxOtherBottomColorRGB[1]/255],
                      [NSNumber numberWithDouble: kScoreBoxOtherBottomColorRGB[2]/255],
                      [NSNumber numberWithDouble: 1.0]
                      ] mutableCopy];
        }
    }
}

- (UIColor *)colorForStatusAtPositionUIColor:(int)position {
    NSMutableArray *rgba = [self colorForStatusAtPositionRGBA:position];
    return [UIColor
            colorWithRed:[[rgba objectAtIndex:0] floatValue]
            green:[[rgba objectAtIndex:1] floatValue]
            blue:[[rgba objectAtIndex:2] floatValue]
            alpha:[[rgba objectAtIndex:3] floatValue]
            ];
}


@end

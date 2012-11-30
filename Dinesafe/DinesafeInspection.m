//
//  DinesafeInspection.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-19.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeInspection.h"

const double kScoreBoxPassTopColorRGB[] = {19, 148, 24};
const double kScoreBoxPassBottomColorRGB[] = {0, 128, 22};
const double kScoreBoxConditionalPassTopColorRGB[] = {250, 242, 7};
const double kScoreBoxConditionalPassBottomColorRGB[] = {236, 230, 15};
const double kScoreBoxClosedTopColorRGB[] = {242, 10, 0};
const double kScoreBoxClosedBottomColorRGB[] = {218, 9, 0};
const double kScoreBoxOtherTopColorRGB[] = {130, 130, 130};
const double kScoreBoxOtherBottomColorRGB[] = {115, 115, 115};

@implementation DinesafeInspection

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
    
    self.inspectionId = [dictionary[@"id"] intValue];
    self.status = dictionary[@"status"];
    self.establishment_name = dictionary[@"establishment_name"];
    self.establishment_type = dictionary[@"establishment_type"];
    self.minimumInspectionsPerYear = [dictionary[@"minimum_inspections_per_year"] intValue];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    self.date = [dateFormat dateFromString:dictionary[@"date"]];
    
    for (id infraction in dictionary[@"infractions"]) {
        NSUInteger index = [self.infractions indexOfObjectPassingTest:
                            ^(DinesafeInfraction *obj, NSUInteger idx, BOOL *stop) {
                                if (obj.infractionId == [infraction[@"id"] intValue]) {
                                    return YES;
                                } else {
                                    return NO;
                                }
                            }];
        if (index == NSNotFound) {
            [self.infractions addObject:[[DinesafeInfraction alloc] initWithDictionary:infraction]];
        } else {
            [self.infractions[index] updateWithDictionary:infraction];
        }
    }
}

#pragma mark - 


// Return a color for an inspection status (RGBA)
// status is "Pass", "Conditional Pass", or "Close". Position is 0=top, 1=bottom
// TODO: This needs some major refactoring!!
- (CGFloat[4])colorForStatusAtPositionRGBA:(int)position {
    if ([self.status isEqualToString:@"Pass"]) {
        if (position == 0) {
            return (CGFloat[]){
                kScoreBoxPassTopColorRGB[0]/255,
                kScoreBoxPassTopColorRGB[1]/255,
                kScoreBoxPassTopColorRGB[2]/255,
                1.0
            };
        } else {
            return (CGFloat[]){
                kScoreBoxPassBottomColorRGB[0]/255,
                kScoreBoxPassBottomColorRGB[1]/255,
                kScoreBoxPassBottomColorRGB[2]/255,
                1.0
            };
        }
    } else if ([self.status isEqualToString:@"Conditional Pass"]) {
        if (position == 0) {
            return (CGFloat[]){
                kScoreBoxConditionalPassTopColorRGB[0]/255,
                kScoreBoxConditionalPassTopColorRGB[1]/255,
                kScoreBoxConditionalPassTopColorRGB[2]/255,
                1.0
            };
        } else {
            return (CGFloat[]){
                kScoreBoxConditionalPassBottomColorRGB[0]/255,
                kScoreBoxConditionalPassBottomColorRGB[1]/255,
                kScoreBoxConditionalPassBottomColorRGB[2]/255,
                1.0
            };
        }
    } else if ([self.status isEqualToString:@"Closed"]) {
        if (position == 0) {
            return (CGFloat[]){
                kScoreBoxClosedTopColorRGB[0]/255,
                kScoreBoxClosedTopColorRGB[1]/255,
                kScoreBoxClosedTopColorRGB[2]/255,
                1.0
            };
        } else {
            return (CGFloat[]){
                kScoreBoxClosedBottomColorRGB[0]/255,
                kScoreBoxClosedBottomColorRGB[1]/255,
                kScoreBoxClosedBottomColorRGB[2]/255,
                1.0
            };
        }
    } else {
        // "Out of Business" or anything else: Use gray
        if (position == 0) {
            return (CGFloat[]){
                kScoreBoxOtherTopColorRGB[0]/255,
                kScoreBoxOtherTopColorRGB[1]/255,
                kScoreBoxOtherTopColorRGB[2]/255,
                1.0
            };
        } else {
            return (CGFloat[]){
                kScoreBoxOtherBottomColorRGB[0]/255,
                kScoreBoxOtherBottomColorRGB[1]/255,
                kScoreBoxOtherBottomColorRGB[2]/255,
                1.0
            };
        }
    }
}

- (UIColor *)colorForStatusAtPositionUIColor:(int)position {
    CGFloat *rgba = [self colorForStatusAtPositionRGBA:position];
    return [UIColor colorWithRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
}


@end

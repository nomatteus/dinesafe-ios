//
//  DinesafeInspectionCell.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-27.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeInspectionCell.h"

@implementation DinesafeInspectionCell

- (void)awakeFromNib {
    // Initialization code
    // [self setBackgroundColor:[UIColor grayColor]];
}

- (void)updateCellContent
{
    if ([self.inspection.status isEqualToString:@"Conditional Pass"]) {
        self.status.text = @"Conditional";
    } else {
        self.status.text = self.inspection.status;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@""];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    self.date.text = [dateFormatter stringFromDate:self.inspection.date];
    
    // TODO: Define colours in a central place (i.e. in DinesafeInspection class)
    // TODO: Refactor this out to the inspection class, so I can just say something like:
    //   self.statusBox.backgroundColor = [inspection color];
    if ([self.inspection.status isEqualToString:@"Pass"]) {
        self.statusBox.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0.094 alpha:1];
    } else if ([self.inspection.status isEqualToString:@"Conditional Pass"]) {
    self.statusBox.backgroundColor = [UIColor colorWithRed:0.93 green:0.9 blue:0.06 alpha:1];
    } else if ([self.inspection.status isEqualToString:@"Closed"]) {
    self.statusBox.backgroundColor = [UIColor colorWithRed:0.85 green:0.04 blue:0 alpha:1];
    } else {
        // Gray TODO
    }



    // TODO: INSTEAD OF SCOREBAR VIEW, build out
    //       INFRACTION table in code
    // DinesafeScorebarView *scorebarView = [[DinesafeScorebarView alloc] initWithInspections:self.establishment.inspections];    
    // [self addSubview:scorebarView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

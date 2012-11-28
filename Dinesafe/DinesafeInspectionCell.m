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
    self.status.text = self.inspection.status;
    self.date.text = [self.inspection.date description];
    
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

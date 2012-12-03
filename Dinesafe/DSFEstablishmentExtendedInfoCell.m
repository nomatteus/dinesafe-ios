//
//  DSFEstablishmentExtendedCell.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-12-02.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFEstablishmentExtendedInfoCell.h"

@implementation DSFEstablishmentExtendedInfoCell

- (void)awakeFromNib {
    // Initialization code
    // [self setBackgroundColor:[UIColor grayColor]];
}

- (void)updateCellContent
{
    self.inspectionsSummary.text = [NSString
                                    stringWithFormat:@"Total: %d inspections\nMinimum Inspections Per Year: %d",
                                    self.establishment.inspections.count,
                                    self.establishment.minimumInspectionsPerYear];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

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
    if (!self.annotation) {
        self.annotation = [[DSFEstablishmentAnnotation alloc] initWithCoordinates:self.establishment.location
                                                                            title:self.establishment.latestName
                                                                         subtitle:[NSString stringWithFormat:@"%.2f km", self.establishment.distance]];
    }

    // Set region distance to distance from establishment plus some "padding" (this is in metres)
    CLLocationDistance reg_distance = self.establishment.distance * 1000 + 150;
    MKCoordinateRegion reg = MKCoordinateRegionMakeWithDistance(self.establishment.location, reg_distance, reg_distance);
    self.mapView.region = reg;

    [self.mapView addAnnotation:self.annotation];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  DinesafeEstablishmentTableViewCell.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeEstablishmentTableViewCell.h"

@implementation DinesafeEstablishmentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)updateCellContent
{
    UILabel *nameLabel = (UILabel *)[self viewWithTag:10];
    nameLabel.text = self.establishment.latestName;
    UILabel *addressLabel = (UILabel *)[self viewWithTag:20];
    addressLabel.text = self.establishment.address;
    UILabel *typeLabel = (UILabel *)[self viewWithTag:30];
    typeLabel.text = self.establishment.latestType;
    NSLog(@"%@", self.establishment.latestType);
    UILabel *distanceLabel = (UILabel *)[self viewWithTag:40];
    distanceLabel.text = [NSString stringWithFormat:@"%.2f km", self.establishment.distance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

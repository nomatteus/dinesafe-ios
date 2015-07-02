//
//  DinesafeEstablishmentTableViewCell.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFEstablishmentCell.h"

@implementation DSFEstablishmentCell

- (void)awakeFromNib
{
    // Initialization code
    // [self setBackgroundColor:[UIColor grayColor]];
}

- (void)updateCellContent
{
    self.name.text = self.establishment.latestName;
    self.address.text = self.establishment.address;
    self.type.text = self.establishment.latestType;
    if (self.establishment.distance) {
        self.distance.text = [NSString stringWithFormat:@"%.2f km", self.establishment.distance];
    } else {
        self.distance.text = @"";
    }

    // Clear out old scorebarView if exists -- TODO: is there a better way to do this?
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DSFScorebarView class]]) {
            [view removeFromSuperview];
        }
    }

    DSFScorebarView *scorebarView = [[DSFScorebarView alloc] initWithInspections:self.establishment.inspections];
    [self addSubview:scorebarView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

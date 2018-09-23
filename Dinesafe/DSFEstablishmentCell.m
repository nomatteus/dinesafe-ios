//
//  DinesafeEstablishmentTableViewCell.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFEstablishmentCell.h"

@interface DSFEstablishmentCell ()
@property (nonatomic, strong) DSFScorebarView *scorebarView;
@end

@implementation DSFEstablishmentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
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
    self.scorebarView.inspections = self.establishment.inspections;
    [self.scorebarView setNeedsDisplay];
}

- (DSFScorebarView *)scorebarView
{
    if (!_scorebarView) {
        _scorebarView = [[DSFScorebarView alloc] initWithInspections:self.establishment.inspections];
        [self addSubview:_scorebarView];
    }
    return _scorebarView;
}

@end

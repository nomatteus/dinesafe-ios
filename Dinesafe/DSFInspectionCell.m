//
//  DinesafeInspectionCell.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-27.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFInspectionCell.h"

@implementation DSFInspectionCell

- (void)awakeFromNib {
    // Initialization code
    // [self setBackgroundColor:[UIColor grayColor]];
}

- (void)updateCellContent
{
    
    // Clear out old (InspectionView) if exists -- TODO: is there a better way to do this?
    // Do we need to do this? -- TODO: Fix extra inspection rows.
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DSFInspectionCellView class]]) {
            [view removeFromSuperview];
        }
    }

    DSFInspectionCellView *inspectionCellView = [[DSFInspectionCellView alloc] initWithInspection:self.inspection];
    [self addSubview:inspectionCellView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end

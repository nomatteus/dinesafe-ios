//
//  DinesafeInspectionCell.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-27.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFInspectionCell.h"
#import "DSFInspectionView.h"

@interface DSFInspectionCell ()
@property (nonatomic, strong) DSFInspectionView *inspectionView;
@end

@implementation DSFInspectionCell

- (void)updateCellContentWithHeight:(CGFloat)height
{
    // Sync width with frame
    // Use [[UIScreen mainScreen] bounds] instead of self.bounds as self.bounds was giving
    //     inaccurate widths that were greater than the screen size.
    self.inspectionView.frame = [[UIScreen mainScreen] bounds];

    // Update height to match
    CGRect frame = self.inspectionView.frame;
    frame.size.height = height;
    self.inspectionView.frame = frame;

    self.inspectionView.inspection = self.inspection;
    [self.inspectionView setNeedsDisplay];
}

- (DSFInspectionView *)inspectionView
{
    if (!_inspectionView) {
        _inspectionView = [[DSFInspectionView alloc] initWithFrame:self.contentView.frame inspection:self.inspection];
        [self.contentView addSubview:self.inspectionView];
    }
    return _inspectionView;
}

@end

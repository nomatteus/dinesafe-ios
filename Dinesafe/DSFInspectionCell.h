//
//  DinesafeInspectionCell.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-27.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSFInspection;

@interface DSFInspectionCell : UITableViewCell

@property (nonatomic, strong) DSFInspection *inspection;

- (void)updateCellContentWithHeight:(CGFloat)height;

@end

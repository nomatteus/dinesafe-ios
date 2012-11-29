//
//  DinesafeInspectionCell.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-27.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DinesafeInspection.h"

@interface DinesafeInspectionCell : UITableViewCell

@property (nonatomic, strong) DinesafeInspection *inspection;

@property (nonatomic, strong) IBOutlet UILabel *status;
@property (nonatomic, strong) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UIView *statusBox;

- (void)updateCellContent;

@end

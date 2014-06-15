//
//  DinesafeInspectionCell.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-27.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSFInspection.h"
#import "DSFInfraction.h"

@interface DSFInspectionCell : UITableViewCell

@property (nonatomic, strong) DSFInspection *inspection;

@property (nonatomic, strong) IBOutlet UILabel *status;
@property (nonatomic, strong) IBOutlet UILabel *date;
@property (nonatomic, strong) IBOutlet UIView *statusBox;
@property (nonatomic, strong) IBOutlet UIView *infractionsView;

//- (void)updateCellContent;

@end

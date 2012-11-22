//
//  DinesafeEstablishmentTableViewCell.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DinesafeEstablishment.h"

@interface DinesafeEstablishmentTableViewCell : UITableViewCell

@property (nonatomic, strong) DinesafeEstablishment *establishment;

- (void)updateCellContent;

@end

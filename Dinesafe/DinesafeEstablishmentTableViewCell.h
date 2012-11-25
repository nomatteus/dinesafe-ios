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

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *address;
@property (nonatomic, strong) IBOutlet UILabel *type;
@property (nonatomic, strong) IBOutlet UILabel *distance;

- (void)updateCellContent;

@end

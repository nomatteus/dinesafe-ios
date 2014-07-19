//
//  DSFSurreyEstablishmentCellTableViewCell.h
//  Dinesafe
//
//  Created by David Dumaresq on 2014-07-19.
//  Copyright (c) 2014 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSFSurreyEstablishment.h"
#import "DSFScorebarView.h"

@interface DSFSurreyEstablishmentCell : UITableViewCell

@property (nonatomic, strong) DSFSurreyEstablishment *establishment;

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *address;
@property (nonatomic, strong) IBOutlet UILabel *type;
@property (nonatomic, strong) IBOutlet UILabel *distance;

- (void)updateCellContent;

@end

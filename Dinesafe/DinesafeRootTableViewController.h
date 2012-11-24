//
//  DinesafeRootTableViewController.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DinesafeApiClient.h"
#import "DinesafeEstablishment.h"
#import "DinesafeEstablishmentTableViewCell.h"

@interface DinesafeRootTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *establishments;

@end

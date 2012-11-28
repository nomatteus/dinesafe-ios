//
//  DinesafeInspectionDetailTableViewController.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-25.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DinesafeApiClient.h"
#import "DinesafeEstablishment.h"
#import "DinesafeEstablishmentCell.h"
#import "DinesafeInspectionCell.h"

@interface DinesafeInspectionDetailTableViewController : UITableViewController

@property (nonatomic, strong) DinesafeEstablishment *establishment;


@end

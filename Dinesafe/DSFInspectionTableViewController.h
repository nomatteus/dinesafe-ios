//
//  DinesafeInspectionDetailTableViewController.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-25.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DSFApiClient.h"
#import "DSFEstablishment.h"
#import "DSFEstablishmentCell.h"
#import "DSFEstablishmentExtendedInfoCell.h"
#import "DSFInspectionCell.h"

@interface DSFInspectionTableViewController : UITableViewController

@property (nonatomic, strong) DSFEstablishment *establishment;


@end

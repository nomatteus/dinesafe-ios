//
//  DinesafeRootTableViewController.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DinesafeApiClient.h"
#import "DinesafeEstablishment.h"
#import "DinesafeEstablishmentCell.h"
#import "DinesafeLoadingCell.h"
#import "DinesafeInspectionDetailTableViewController.h"

// #define kDistanceInMetersToTriggerRefresh 100

@interface DinesafeRootTableViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

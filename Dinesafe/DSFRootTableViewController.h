//
//  DinesafeRootTableViewController.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DSFApiClient.h"
#import "DSFEstablishment.h"
#import "DSFEstablishmentCell.h"
#import "DSFLoadingCell.h"
#import "DSFInspectionTableViewController.h"

// #define kDistanceInMetersToTriggerRefresh 100

@interface DSFRootTableViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

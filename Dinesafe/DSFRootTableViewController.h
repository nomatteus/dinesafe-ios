//
//  DinesafeRootTableViewController.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SSPullToRefresh.h"
#import "DSFApiClient.h"
#import "DSFEstablishment.h"
#import "DSFEstablishmentCell.h"
#import "DSFLoadingCell.h"
#import "DSFInspectionTableViewController.h"
#import "DSFSurreyEstablishmentCell.h"

// #define kDistanceInMetersToTriggerRefresh 100

// Use Surrey City Hall as center point when location services enabled
#define kDefaultCenterCoord @"-122.80816, 49.11268"

// Vancouver City Hall
// 49.260872, -123.113953

// TODO: Find appropriate out max (10k ~= 1100 establishments, 5k ~= 196, 2.5k ~= 30)
#define kDistanceInMetersOuterRing @"10000"
#define kDistanceInMetersMediumRing @"5000"
#define kDistanceInMetersInnerRing @"2500"

#define kPageSize 20; //TODO find optimum number to request. More?

@interface DSFRootTableViewController : UITableViewController <SSPullToRefreshViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@end

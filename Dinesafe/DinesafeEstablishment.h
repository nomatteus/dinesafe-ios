//
//  DinesafeEstablishment.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-12.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DinesafeEstablishment : NSObject

@property (nonatomic, strong) NSString *eId;
@property (nonatomic, strong) NSString *latest_name;
@property (nonatomic, strong) NSString *latest_type;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, readwrite) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSMutableArray *inspections;

@end

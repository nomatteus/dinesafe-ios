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

@property (nonatomic, strong) NSString *establishmentId;
@property (nonatomic, strong) NSString *latestName;
@property (nonatomic, strong) NSString *latestType;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) double distance;
@property (nonatomic, readwrite) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSMutableArray *inspections;

-(id) initWithDictionary:(NSDictionary *) dictionary;

@end

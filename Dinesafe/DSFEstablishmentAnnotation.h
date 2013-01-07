//
//  EstablishmentAnnotation.h
//  Dinesafe
//
//  Created by Matt Ruten on 2013-01-07.
//  Copyright (c) 2013 Matt Ruten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DSFEstablishmentAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinate
                    title:(NSString *)title
                 subtitle:(NSString *)subtitle;

@end

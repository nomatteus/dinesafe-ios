//
//  EstablishmentAnnotation.m
//  Dinesafe
//
//  Created by Matt Ruten on 2013-01-07.
//  Copyright (c) 2013 Matt Ruten. All rights reserved.
//

#import "DSFEstablishmentAnnotation.h"

@implementation DSFEstablishmentAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinate
                    title:(NSString *)title
                 subtitle:(NSString *)subtitle
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
        _subtitle = subtitle;
    }
    return self;
}

@end

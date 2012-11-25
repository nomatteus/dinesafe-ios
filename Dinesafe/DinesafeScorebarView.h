//
//  DinesafeScorebarView.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-24.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DinesafeInspection.h"

@interface DinesafeScorebarView : UIView

@property (nonatomic, strong) NSArray *inspections;

- (id)initWithInspections:(NSArray *)inspections;

@end

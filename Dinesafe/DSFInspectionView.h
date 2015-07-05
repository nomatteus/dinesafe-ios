//
//  DSFInspectionView.h
//  Dinesafe
//
//  Created by Matt on 2015-07-04.
//  Copyright (c) 2015 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSFInspection.h"

@interface DSFInspectionView : UIView

@property (nonatomic, strong) DSFInspection *inspection;
- (instancetype)initWithFrame:(CGRect)frame inspection:(DSFInspection *)inspection;

@end

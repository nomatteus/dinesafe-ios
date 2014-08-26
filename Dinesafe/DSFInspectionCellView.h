//
//  DSFInspectionCellView.h
//  Dinesafe
//
//  Created by David Dumaresq on 2014-07-20.
//  Copyright (c) 2014 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSFInspection.h"

@interface DSFInspectionCellView : UIView

@property (nonatomic, strong) DSFInspection *inspection;

- (id)initWithInspection:(DSFInspection *)inspection;

@end

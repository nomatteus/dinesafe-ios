//
//  UIView+viewRecursion.h
//  Dinesafe
//
//  Created by David Dumaresq on 2014-08-25.
//  Copyright (c) 2014 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (viewRecursion)

- (NSMutableArray *)allSubviews;
- (void)logViewHierarchy;

@end

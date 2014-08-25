//
//  UIView+viewRecursion.m
//  Dinesafe
//
//  Created by David Dumaresq on 2014-08-25.
//  Copyright (c) 2014 Matt Ruten. All rights reserved.
//
//Thanks to
// http://stackoverflow.com/questions/2746478/how-can-i-loop-through-all-subviews-of-a-uiview-and-their-subviews-and-their-su/2746508#2746508

#import "UIView+viewRecursion.h"

@implementation UIView (viewRecursion)

- (NSMutableArray *)allSubviews {
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    [arr addObject:self];
    for (UIView *subview in self.subviews)
    {
        [arr addObjectsFromArray:(NSArray*)[subview allSubviews]];
    }
    return arr;
}

- (void)logViewHierarchy {
    NSLog(@"%@", self);
    for (UIView *subview in self.subviews) {
        
        [subview logViewHierarchy];
        
    }
}
@end

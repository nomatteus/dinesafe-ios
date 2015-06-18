//
//  DSFNavigationBar.m
//  Dinesafe
//
//  Created by Matt Ruten on 2013-01-16.
//  Copyright (c) 2013 Matt Ruten. All rights reserved.
//

#import "DSFNavigationBar.h"

const double kNavTopRGB[] = {41, 135, 252};
const double kNavBottomRGB[] = {36, 120, 228};

@implementation DSFNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    // Set default button/backbutton tint color
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    // Set title text attributes -- this affects all view controllers, which may not be desirable
    self.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"BariolBold-Italic" size:26.0], UITextAttributeFont,
                                [UIColor whiteColor], UITextAttributeTextColor,
                                nil];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGRect navBarRect = CGRectMake(0, 0, self.bounds.size.width, 44);
//    CGContextAddRect(ctx, navBarRect);
//    [[UIColor darkGrayColor] setFill];
//    UIColor *navBarColor = [UIColor colorWithRed:kNavTopRGB[0]/255.0
//                                        green:kNavTopRGB[1]/255.0
//                                         blue:kNavTopRGB[2]/255.0
//                                        alpha:1.0];
//    [navBarColor setFill];
//    CGContextFillPath(ctx);
//}



@end

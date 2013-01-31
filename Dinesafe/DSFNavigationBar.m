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
    [[UIBarButtonItem appearance] setTintColor:[UIColor grayColor]];
    
    // Set title text attributes -- this affects all view controllers, which may not be desirable
    self.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"BariolBold-Italic" size:25.0], UITextAttributeFont,
//                                [UIColor redColor], UITextAttributeTextColor,
//                                [UIColor blueColor], UITextAttributeTextShadowColor,
//                                [NSValue valueWithUIOffset:UIOffsetMake(1, 1)], UITextAttributeTextShadowOffset,
                                nil];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect topRect = CGRectMake(0, 0, self.bounds.size.width, 22);
    CGRect bottomRect = CGRectMake(0, 22, self.bounds.size.width, 22);
    CGContextAddRect(ctx, topRect);
    [[UIColor darkGrayColor] setFill];
    UIColor *topColor = [UIColor colorWithRed:kNavTopRGB[0]/255.0
                                        green:kNavTopRGB[1]/255.0
                                         blue:kNavTopRGB[2]/255.0
                                        alpha:1.0];
    [topColor setFill];
    CGContextFillPath(ctx);
    UIColor *bottomColor = [UIColor colorWithRed:kNavBottomRGB[0]/255.0
                                        green:kNavBottomRGB[1]/255.0
                                         blue:kNavBottomRGB[2]/255.0
                                        alpha:1.0];
    [bottomColor setFill];
    CGContextAddRect(ctx, bottomRect);
    CGContextFillPath(ctx);
    
    
    // --- "Dinesafe" Title (Done as UINavigationBar title for now.) ---
    //    "Bariol-Regular",
    //    "BariolRegular-Italic"
//    CGRect titleRect = CGRectMake(0, 10.0, self.bounds.size.width, 44);
//    CGRect titleShadowRect = CGRectMake(1, 11.0, self.bounds.size.width, 44);
//    [[UIColor darkGrayColor] setFill];
//    [@"Dinesafe" drawInRect:titleShadowRect withFont:[UIFont fontWithName:@"BariolRegular-Italic" size:22.0] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
//    [[UIColor whiteColor] setFill];
//    [@"Dinesafe" drawInRect:titleRect withFont:[UIFont fontWithName:@"BariolRegular-Italic" size:22.0] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}



@end

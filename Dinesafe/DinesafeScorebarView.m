//
//  DinesafeScorebarView.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-24.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeScorebarView.h"

const float kScoreBoxWidth = 16;
const float kScoreBoxHeight = 12;
const float kScoreBoxGap = 0;  // Gap between boxes
const double kScoreBoxPassTopColorRGB[] = {19, 148, 24};
const double kScoreBoxPassBottomColorRGB[] = {0, 128, 22};
const double kScoreBoxConditionalPassTopColorRGB[] = {250, 242, 7};
const double kScoreBoxConditionalPassBottomColorRGB[] = {236, 230, 15};
const double kScoreBoxClosedTopColorRGB[] = {242, 10, 0};
const double kScoreBoxClosedBottomColorRGB[] = {218, 9, 0};
const double kScoreBoxOtherTopColorRGB[] = {130, 130, 130};
const double kScoreBoxOtherBottomColorRGB[] = {115, 115, 115};

@implementation DinesafeScorebarView


#pragma mark - Init

// Custom init method
- (id)initWithInspections:(NSArray *)inspections {
    CGRect scorebarFrame = CGRectMake(20, 38, 273, 22);
    if ((self = [super initWithFrame:scorebarFrame])) {
        self.inspections = inspections;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark - Helper Methods

// Return a color for an inspection status
// status is "Pass", "Conditional Pass", or "Close". Position is 0=top, 1=bottom
// TODO: This needs some major refactoring!!
- (CGFloat[4])colorForStatus:(NSString *)status atPosition:(int)position {
    if ([status isEqualToString:@"Pass"]) {
        if (position == 0) {
            return (CGFloat[]){
                kScoreBoxPassTopColorRGB[0]/255,
                kScoreBoxPassTopColorRGB[1]/255,
                kScoreBoxPassTopColorRGB[2]/255,
                1.0
            };
        } else {
            return (CGFloat[]){
                kScoreBoxPassBottomColorRGB[0]/255,
                kScoreBoxPassBottomColorRGB[1]/255,
                kScoreBoxPassBottomColorRGB[2]/255,
                1.0
            };
        }
    } else if ([status isEqualToString:@"Conditional Pass"]) {
        if (position == 0) {
            return (CGFloat[]){
                kScoreBoxConditionalPassTopColorRGB[0]/255,
                kScoreBoxConditionalPassTopColorRGB[1]/255,
                kScoreBoxConditionalPassTopColorRGB[2]/255,
                1.0
            };
        } else {
            return (CGFloat[]){
                kScoreBoxConditionalPassBottomColorRGB[0]/255,
                kScoreBoxConditionalPassBottomColorRGB[1]/255,
                kScoreBoxConditionalPassBottomColorRGB[2]/255,
                1.0
            };
        }
    } else if ([status isEqualToString:@"Closed"]) {
        if (position == 0) {
            return (CGFloat[]){
                kScoreBoxClosedTopColorRGB[0]/255,
                kScoreBoxClosedTopColorRGB[1]/255,
                kScoreBoxClosedTopColorRGB[2]/255,
                1.0
            };
        } else {
            return (CGFloat[]){
                kScoreBoxClosedBottomColorRGB[0]/255,
                kScoreBoxClosedBottomColorRGB[1]/255,
                kScoreBoxClosedBottomColorRGB[2]/255,
                1.0
            };
        }
    } else {
        // "Out of Business" or anything else: Use gray
        if (position == 0) {
            return (CGFloat[]){
                kScoreBoxOtherTopColorRGB[0]/255,
                kScoreBoxOtherTopColorRGB[1]/255,
                kScoreBoxOtherTopColorRGB[2]/255,
                1.0
            };
        } else {
            return (CGFloat[]){
                kScoreBoxOtherBottomColorRGB[0]/255,
                kScoreBoxOtherBottomColorRGB[1]/255,
                kScoreBoxOtherBottomColorRGB[2]/255,
                1.0
            };
        }
    }
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGRect bounds = [self bounds]; // Uncomment when needed
    
//    float totalWidth = self.inspections.count * (kScoreBoxWidth + kScoreBoxGap);
//    float totalHeight = kScoreBoxHeight;
    
    float xOffset = 0; // Keep track of position of next box -- start at 1
    float yOffset = 0; // Fixed Y offset. Adjust to match shadows
    
    
    // Shadows and/or layering rects seems to mess things up.
    // Random lines appear between boxes when doing this.. possibly antialiasing issues?
//    CGSize shadowOffset = CGSizeMake(0, 1);
//    CGColorRef shadowColor = [[UIColor lightGrayColor] CGColor];
//    CGContextSetShadowWithColor(ctx, shadowOffset, 4.0, shadowColor);
//    CGFloat *containerColor = (CGFloat[]){1, 1, 1, 0.8};
//    CGContextSetFillColor(ctx, containerColor);
    
//    CGRect container = CGRectMake(xOffset - 1, yOffset - 1, totalWidth + 2, totalHeight + 2);
//    CGContextAddRect(ctx, container);
//    CGContextFillPath(ctx);
    
    // Reset Shadow
//    CGContextSetShadowWithColor(ctx, shadowOffset, 0, NULL);
    
    for (id inspection in self.inspections) {
        
        // Top of box
        CGFloat *topColor = [self colorForStatus:[inspection status] atPosition:0];
        CGContextSetFillColor(ctx, topColor);
        CGRect box_top = CGRectMake(xOffset, yOffset, kScoreBoxWidth, kScoreBoxHeight / 2);
        CGContextAddRect(ctx, box_top);
        CGContextFillPath(ctx);
        
        // Bottom of box
        CGContextSetFillColor(ctx, [self colorForStatus:[inspection status] atPosition:1]);
        CGRect box_bottom = CGRectMake(xOffset, kScoreBoxHeight / 2 + yOffset, kScoreBoxWidth, kScoreBoxHeight / 2);
        CGContextAddRect(ctx, box_bottom);
        CGContextFillPath(ctx);
        
        // Divider line
        CGFloat *lineColor = (CGFloat[]){1, 1, 1, 0.25};
        CGContextSetFillColor(ctx, lineColor);
        
        CGRect divider_line = CGRectMake(xOffset + kScoreBoxWidth - 1, yOffset, 1, kScoreBoxHeight);
        CGContextAddRect(ctx, divider_line);
        CGContextFillPath(ctx);
        
        xOffset += kScoreBoxWidth + kScoreBoxGap;
    }
    
    
}


@end

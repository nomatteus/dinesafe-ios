//
//  DinesafeScorebarView.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-24.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFScorebarView.h"

const float kScoreBoxWidth = 16;
const float kScoreBoxHeight = 12;
const float kScoreBoxGap = 0;  // Gap between boxes

@implementation DSFScorebarView


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
    NSString *previousYear = nil;
    UIFont *yearFont = [UIFont fontWithName:@"PFTempestaFiveCompressed" size:8.0];

    
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
    
    
    // take subset/slice of inspections. only the last 17, so it will fit on screen.
    int inspections_count = [self.inspections count];
    int startIndex = inspections_count > 17 ? inspections_count - 17 - 1 : 0;
    int subarrayLength = inspections_count > 17 ? 17 : inspections_count;
    NSArray *inspectionsSlice = [self.inspections subarrayWithRange:NSMakeRange(startIndex, subarrayLength)];
    
    for (id inspection in inspectionsSlice) {
        
        // Top of box
        CGFloat *topColor = [inspection colorForStatusAtPositionRGBA:0];
        CGContextSetFillColor(ctx, topColor);
        CGRect box_top = CGRectMake(xOffset, yOffset, kScoreBoxWidth, kScoreBoxHeight / 2);
        CGContextAddRect(ctx, box_top);
        CGContextFillPath(ctx);
        
        // Bottom of box
        CGContextSetFillColor(ctx, [inspection colorForStatusAtPositionRGBA:1]);
        CGRect box_bottom = CGRectMake(xOffset, kScoreBoxHeight / 2 + yOffset, kScoreBoxWidth, kScoreBoxHeight / 2);
        CGContextAddRect(ctx, box_bottom);
        CGContextFillPath(ctx);
        
        // Divider line
        CGFloat *lineColor = (CGFloat[]){1, 1, 1, 0.25};
        CGContextSetFillColor(ctx, lineColor);
        
        CGRect divider_line = CGRectMake(xOffset + kScoreBoxWidth - 1, yOffset, 1, kScoreBoxHeight);
        CGContextAddRect(ctx, divider_line);
        CGContextFillPath(ctx);
        
        // Year Text
        NSString *theYear = [inspection dateYear];
        if (![theYear isEqualToString:previousYear]) {
            CGFloat *yearColor = (CGFloat[]){0.5, 0.5, 0.5, 1.0};
            CGContextSetFillColor(ctx, yearColor);
            // +/- 1/2 adjustments are positioning tweaks
            CGRect yearRect = CGRectMake(xOffset+1, yOffset+kScoreBoxHeight-2, kScoreBoxWidth+50, kScoreBoxHeight);
            [theYear drawInRect:yearRect withFont:yearFont];
            previousYear = theYear;
        }
        
        xOffset += kScoreBoxWidth + kScoreBoxGap;
    }
    
    
}


@end

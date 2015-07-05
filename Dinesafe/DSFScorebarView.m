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
const float kScoreBoxGap = 0; // Gap between boxes

@implementation DSFScorebarView

#pragma mark - Init

// Custom init method
- (id)initWithInspections:(NSArray *)inspections
{
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

    // take subset/slice of inspections. only the last 17, so it will fit on screen.
    NSUInteger inspections_count = [self.inspections count];
    NSUInteger startIndex = inspections_count > 17 ? inspections_count - 17 - 1 : 0;
    NSUInteger subarrayLength = inspections_count > 17 ? 17 : inspections_count;
    NSArray *inspectionsSlice = [self.inspections subarrayWithRange:NSMakeRange(startIndex, subarrayLength)];

    for (id inspection in inspectionsSlice) {
        // Top of box
        NSMutableArray *pos0RGBA = [inspection colorForStatusAtPositionRGBA:0];
        CGFloat topColor[] = {
                [[pos0RGBA objectAtIndex:0] floatValue],
                [[pos0RGBA objectAtIndex:1] floatValue],
                [[pos0RGBA objectAtIndex:2] floatValue],
                [[pos0RGBA objectAtIndex:3] floatValue]};
        CGContextSetFillColor(ctx, topColor);
        CGRect box_top = CGRectMake(xOffset, yOffset, kScoreBoxWidth, kScoreBoxHeight / 2);
        CGContextAddRect(ctx, box_top);
        CGContextFillPath(ctx);

        // Bottom of box
        NSMutableArray *pos1RGBA = [inspection colorForStatusAtPositionRGBA:1];
        CGFloat bottomColor[] = {
                [[pos1RGBA objectAtIndex:0] floatValue],
                [[pos1RGBA objectAtIndex:1] floatValue],
                [[pos1RGBA objectAtIndex:2] floatValue],
                [[pos1RGBA objectAtIndex:3] floatValue]};
        CGContextSetFillColor(ctx, bottomColor);
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
            CGRect yearRect = CGRectMake(xOffset + 1, yOffset + kScoreBoxHeight - 2, kScoreBoxWidth + 50, kScoreBoxHeight);
            [theYear drawInRect:yearRect withFont:yearFont];
            previousYear = theYear;
        }

        xOffset += kScoreBoxWidth + kScoreBoxGap;
    }
}

@end

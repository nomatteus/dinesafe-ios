//
//  DSFInspectionView.m
//  Dinesafe
//
//  Created by Matt on 2015-07-04.
//  Copyright (c) 2015 Matt Ruten. All rights reserved.
//

#import "DSFInspectionView.h"

@interface DSFInspectionView ()
@end

@implementation DSFInspectionView

- (instancetype)initWithFrame:(CGRect)frame inspection:(DSFInspection *)inspection
{
    self.inspection = inspection;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // --- Draw colored "pass/conditional/etc" cell. ---
    CGRect statusRect = CGRectMake(0, 0, 100, 40);
    NSMutableArray *pos0RGBA = [self.inspection colorForStatusAtPositionRGBA:0];
    CGFloat pos0RGBAFloats[] = {
            [[pos0RGBA objectAtIndex:0] floatValue],
            [[pos0RGBA objectAtIndex:1] floatValue],
            [[pos0RGBA objectAtIndex:2] floatValue],
            [[pos0RGBA objectAtIndex:3] floatValue]};
    CGContextSetFillColor(ctx, pos0RGBAFloats);
    CGRect statusTopRect = CGRectMake(0, 0, 100, 35);
    CGContextAddRect(ctx, statusTopRect);
    CGContextFillPath(ctx);

    NSMutableArray *pos1RGBA = [self.inspection colorForStatusAtPositionRGBA:1];
    CGFloat pos1RGBAFloats[] = {
            [[pos1RGBA objectAtIndex:0] floatValue],
            [[pos1RGBA objectAtIndex:1] floatValue],
            [[pos1RGBA objectAtIndex:2] floatValue],
            [[pos1RGBA objectAtIndex:3] floatValue]};
    CGContextSetFillColor(ctx, pos1RGBAFloats);

    CGRect statusBottomRect = CGRectMake(0, 35, 100, 5);
    CGContextAddRect(ctx, statusBottomRect);
    CGContextFillPath(ctx);

    // --- Draw pass/conditional text ---
    // Set deafult values
    NSString *statusText = self.inspection.status;
    CGFloat *textColor = (CGFloat[]){
        255.0 / 255,
        255.0 / 255,
        255.0 / 255,
        1.0};

    CGFloat *shadowColor = pos1RGBAFloats;
    CGFloat statusTextFontSize = 14.0;
    // Change values for certain status's
    if ([self.inspection.status isEqualToString:@"Conditional Pass"]) {
        statusText = @"Conditional";
        // Custom shadow color for conditional pass -- darker
        textColor = (CGFloat[]){
            148.0 / 255,
            152.0 / 255,
            43.0 / 255,
            1.0};
        shadowColor = (CGFloat[]){
            252.0 / 255,
            255.0 / 255,
            169.0 / 255,
            1.0};
    } else if ([self.inspection.status isEqualToString:@"Out of Business"]) {
        statusTextFontSize = 11.0;
    }

    CGRect statusTextRect = CGRectMake(0.0, (statusRect.size.height - statusTextFontSize - 2) / 2 - 2, statusRect.size.width, statusRect.size.height);
    CGRect statusTextShadowRect = CGRectMake(0.0 + 1, (statusRect.size.height - statusTextFontSize - 2) / 2 + 1 - 2, statusRect.size.width, statusRect.size.height);
    CGContextSetFillColor(ctx, shadowColor);
    [statusText drawInRect:statusTextShadowRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:statusTextFontSize] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    CGContextSetFillColor(ctx, textColor);
    [statusText drawInRect:statusTextRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:statusTextFontSize] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];

    // --- Draw date ---
    // Rect is width of view bounds minus width of status box
    [[UIColor blackColor] setFill];
    CGRect inspectionDateRect = CGRectMake(statusRect.size.width + 16, 10.0, self.bounds.size.width - statusRect.size.width, statusRect.size.height);
    [self.inspection.formattedDate drawInRect:inspectionDateRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:16] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft];

    // --- draw infractions/severity/details headings ---
    [[UIColor grayColor] setFill];
    CGRect infractionHeadingRect = CGRectMake(16, 52.0, 208, 18);
    [@"Infractions" drawInRect:infractionHeadingRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]];
    [[UIColor blackColor] setFill];
    CGRect severityHeadingRect = CGRectMake(16, 84.0, 208, 18);
    [@"Severity" drawInRect:severityHeadingRect withFont:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:statusTextFontSize]];
    CGRect detailsHeadingRect = CGRectMake(104, 84.0, 208, 18);
    [@"Details" drawInRect:detailsHeadingRect withFont:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:statusTextFontSize]];

    // --- draw infractions list. ---
    float offsetY = 116;
    float infractionHeight = 50;
    float infractionsFontSize = 12.0;
    for (DSFInfraction *infraction in self.inspection.infractions) {
        CGRect severityFrame = CGRectMake(16, offsetY, 87, infractionHeight);
        [infraction.severity drawInRect:severityFrame
                               withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:infractionsFontSize]
                          lineBreakMode:NSLineBreakByCharWrapping
                              alignment:NSTextAlignmentLeft];
        // Consider "height" to be a "max height", as we'll dynamically size it depending on length of text
        CGRect detailsFrame = CGRectMake(104, offsetY, 208, infractionHeight * 5);
        UIFont *detailsFont = [UIFont fontWithName:@"HelveticaNeue" size:infractionsFontSize];
        CGSize detailsSize = [infraction heightForSize:detailsFrame.size andFont:detailsFont];

        float infractionDetailsHeight = detailsSize.height + 10; // Padding is 10, change this in DSFInspection as well
        [infraction.details drawInRect:detailsFrame
                              withFont:detailsFont
                         lineBreakMode:NSLineBreakByWordWrapping
                             alignment:NSTextAlignmentLeft];
        offsetY += infractionDetailsHeight;
    }
}

@end

//
//  DinesafeInspectionCell.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-27.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFInspectionCell.h"

@interface DSFInspectionCell ()
//@property (nonatomic, strong)  ...;
@end

@implementation DSFInspectionCell

- (void)awakeFromNib {
    // Initialization code
    // [self setBackgroundColor:[UIColor grayColor]];
}

- (void)updateCellContent
{

//    if ([self.inspection.status isEqualToString:@"Conditional Pass"]) {
//        self.status.text = @"Conditional";
//    } else {
//        self.status.text = self.inspection.status;
//    }
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
//    self.date.text = [dateFormatter stringFromDate:self.inspection.date];
//    
//    self.statusBox.backgroundColor = [self.inspection colorForStatusAtPositionUIColor:1];
//
//    float offsetY = 76;
//    float infractionHeight = 50;
//    for (DSFInfraction *infraction in self.inspection.infractions) {
//        // TODO: All the work done in this for-in loop is causing scrolling
//        //      to lag, because this is done every time a cell is viewed.
//        //    TODO: move the bulk of this somewhere else... not sure where....
//        CGRect severityFrame = CGRectMake(16, offsetY, 87, infractionHeight);
//        UITextView *severity = [[UITextView alloc] initWithFrame:severityFrame];
//        severity.text = infraction.severity;
//        severity.editable = NO;
//       
//        CGRect detailsFrame = CGRectMake(104, offsetY, 208, infractionHeight);
//        UITextView *details = [[UITextView alloc] initWithFrame:detailsFrame];
//        details.text = infraction.details;
//        details.editable = NO;
//        
//        [self.infractionsView addSubview:severity];
//        [self.infractionsView addSubview:details];
//        offsetY += infractionHeight;
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // --- Draw colored "pass/conditional/etc" cell. ---
    CGRect statusRect = CGRectMake(0, 0, 100, 40); // temp.. used in status text

    CGContextSetFillColor(ctx, [self.inspection colorForStatusAtPositionRGBA:0]);
    ;
    CGRect statusTopRect = CGRectMake(0, 0, 100, 35);
    CGContextAddRect(ctx, statusTopRect);
    CGContextFillPath(ctx);
    CGContextSetFillColor(ctx, [self.inspection colorForStatusAtPositionRGBA:1]);
    ;
    CGRect statusBottomRect = CGRectMake(0, 35, 100, 5);
    CGContextAddRect(ctx, statusBottomRect);
    CGContextFillPath(ctx);
    
    // --- Draw pass/conditional text ---
    NSString *statusText;
    if ([self.inspection.status isEqualToString:@"Conditional Pass"]) {
        statusText = @"Conditional";
    } else {
        statusText = self.inspection.status;
    }

    CGFloat statusTextFontSize = 14.0;
    CGRect statusTextRect = CGRectMake(0.0, (statusRect.size.height-statusTextFontSize-2)/2-2, statusRect.size.width, statusRect.size.height);
    CGRect statusTextShadowRect = CGRectMake(0.0, (statusRect.size.height-statusTextFontSize-2)/2+1-2, statusRect.size.width, statusRect.size.height);
    [[UIColor grayColor] setFill];
    [statusText drawInRect:statusTextShadowRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:statusTextFontSize] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    [[UIColor whiteColor] setFill];
    [statusText drawInRect:statusTextRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:statusTextFontSize] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    // --- Draw date ---
    // Rect is width of view bounds minus width of status box
    [[UIColor blackColor] setFill];
    CGRect inspectionDateRect = CGRectMake(statusRect.size.width+16, 10.0, self.bounds.size.width-statusRect.size.width, statusRect.size.height);
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

        CGRect detailsFrame = CGRectMake(104, offsetY, 208, infractionHeight);
        // Dynamically set smaller font size for long details
        // Example Establishments for testing: "Green Thumb"
        // TODO: ALTERNATIVE IDEA: Instead of using constant height for all infractions, set height dynamically
        //       depending on length of details. i.e. print details at constant font size, then figure out
        //       the height of that text. This would look better and more consistent.
        float infractionDetailsFontSize;
        int detailsLength = [infraction.details length];
        NSLog(@"detailsLength: %i", detailsLength);
        if (detailsLength > 140) {
            infractionDetailsFontSize = infractionsFontSize - 4;
        } else if (detailsLength > 110) {
            infractionDetailsFontSize = infractionsFontSize - 2;
        } else {
            infractionDetailsFontSize = infractionsFontSize;
        }
        [infraction.details drawInRect:detailsFrame
                               withFont:[UIFont fontWithName:@"HelveticaNeue" size:infractionDetailsFontSize]
                          lineBreakMode:NSLineBreakByWordWrapping
                              alignment:NSTextAlignmentLeft];

        offsetY += infractionHeight;
    }
    
}


@end

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

    if ([self.inspection.status isEqualToString:@"Conditional Pass"]) {
        self.status.text = @"Conditional";
    } else {
        self.status.text = self.inspection.status;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    self.date.text = [dateFormatter stringFromDate:self.inspection.date];
    
    self.statusBox.backgroundColor = [self.inspection colorForStatusAtPositionUIColor:1];

    float offsetY = 76;
    float infractionHeight = 50;
    for (DSFInfraction *infraction in self.inspection.infractions) {
        // TODO: All the work done in this for-in loop is causing scrolling
        //      to lag, because this is done every time a cell is viewed.
        //    TODO: move the bulk of this somewhere else... not sure where....
        CGRect severityFrame = CGRectMake(16, offsetY, 87, infractionHeight);
        UITextView *severity = [[UITextView alloc] initWithFrame:severityFrame];
        severity.text = infraction.severity;
        severity.editable = NO;
       
        CGRect detailsFrame = CGRectMake(104, offsetY, 208, infractionHeight);
        UITextView *details = [[UITextView alloc] initWithFrame:detailsFrame];
        details.text = infraction.details;
        details.editable = NO;
        
        [self.infractionsView addSubview:severity];
        [self.infractionsView addSubview:details];
        offsetY += infractionHeight;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Drawing

//- (void)drawRect:(CGRect)rect {
    // ... TODO? ...
//}


@end

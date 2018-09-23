//
//  DinesafeLoadingTableViewCell.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-24.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFLoadingCell.h"

@interface DSFLoadingCell ()
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation DSFLoadingCell

// This is how to execute code on "init", instead of in:
//   - (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
- (void)awakeFromNib
{
    // Initialization code
    self.tag = kLoadingCellTag;
    [super awakeFromNib];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.activityIndicator startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

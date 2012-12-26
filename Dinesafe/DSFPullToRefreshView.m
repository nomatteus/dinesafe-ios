//
//  DSFPullToRefreshView.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-12-11.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFPullToRefreshView.h"

@interface DSFPullToRefreshView ()
@property (nonatomic) CGFloat progress;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic) CGFloat barHeight;
@property (nonatomic, strong) NSString *refreshText;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

//const double kScoreBoxPassTopColorRGB[] = {19, 148, 24};
//const double kScoreBoxPassBottomColorRGB[] = {0, 128, 22};
//const double kScoreBoxOtherTopColorRGB[] = {130, 130, 130};
//const double kScoreBoxOtherBottomColorRGB[] = {115, 115, 115};

@implementation DSFPullToRefreshView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.barColor = [UIColor lightGrayColor];
        self.barHeight = 10.0f;
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.indicator setHidesWhenStopped:YES];
        [self addSubview:self.indicator];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.indicator.center = CGPointMake(floorf(self.bounds.size.width / 2.0f),
                                        floorf((self.bounds.size.height - self.barHeight) / 2.0f));
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextFillRect(context, self.bounds);
    
    // Text ("Pull/Release to Refresh")
    [[UIColor darkGrayColor] set];
    CGFloat textRectWidth = 120.0f;
    CGFloat textRectHeight = 20.0f;
    CGFloat textRectX = (self.bounds.size.width - textRectWidth) / 2;
    CGFloat textRectY = 20.0f;
    CGRect refreshTextRect = CGRectMake(textRectX, textRectY, textRectWidth, textRectHeight);
    [self.refreshText drawInRect:refreshTextRect withFont:[UIFont boldSystemFontOfSize:12.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    
    // Bar
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat barWidth = (width / 2.0) * self.progress;
    
    CGFloat barY = height - self.barHeight;
    
    CGRect leftRect = CGRectMake(0, barY, barWidth, self.barHeight);
    [self.barColor set];
    CGContextFillRect(context, leftRect);
    
    CGFloat rightX = width - barWidth;
    CGRect rightRect = CGRectMake(rightX, barY, barWidth, self.barHeight);
    CGContextFillRect(context, rightRect);
}


/**
 The pull to refresh view's state has changed. The content view must update itself. All content view's must implement
 this method.
 */
- (void)setState:(SSPullToRefreshViewState)state withPullToRefreshView:(SSPullToRefreshView *)view {
    self.refreshText = @"";
    switch (state) {
        case SSPullToRefreshViewStateNormal:
            self.refreshText = @"Pull to Refresh";
            self.barColor = [UIColor colorWithRed:115.0/255.0
                                            green:115.0/255.0
                                             blue:115.0/255.0
                                            alpha:1.0];
            break;
            
        case SSPullToRefreshViewStateLoading:
            [_indicator startAnimating];
            self.barColor = [UIColor colorWithRed:0
                                            green:128.0/255.0
                                             blue:22.0/255.0
                                            alpha:0.2];
            break;
            
        case SSPullToRefreshViewStateReady:
            self.refreshText = @"Release to Refresh";
            self.barColor = [UIColor colorWithRed:0
                                            green:128.0/255.0
                                             blue:22.0/255.0
                                            alpha:1.0];
            break;
            
        case SSPullToRefreshViewStateClosing:
            [_indicator stopAnimating];
            self.barColor = [UIColor whiteColor];
            break;
            
        default:
            break;
    }
}

/**
 The pull to refresh view will set send values from `0.0` to `1.0` as the user pulls down. `1.0` means it is fully expanded and
 will change to the `SSPullToRefreshViewStateReady` state. You can use this value to draw the progress of the pull
 (i.e. Tweetbot style).
 */
- (void)setPullProgress:(CGFloat)pullProgress {
    self.progress = pullProgress;
    [self setNeedsDisplay];
}

@end

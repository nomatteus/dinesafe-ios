//
//  DSFInfoViewController.h
//  Dinesafe
//
//  Created by Matt Ruten on 2013-01-21.
//  Copyright (c) 2013 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DINESAFE_ABOUT_PAGE_URL @"http://dinesafe.to/app/about"
//#define DINESAFE_ABOUT_PAGE_URL @"http://make-lemonade.co/landy/"

@interface DSFInfoViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end

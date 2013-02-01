//
//  DSFInfoViewController.m
//  Dinesafe
//
//  Created by Matt Ruten on 2013-01-21.
//  Copyright (c) 2013 Matt Ruten. All rights reserved.
//

#import "DSFInfoViewController.h"

@interface DSFInfoViewController ()

@end

@implementation DSFInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:DINESAFE_ABOUT_PAGE_URL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self hideGradientBackground:self.webView];
    [self.webView loadRequest:requestObj];
    self.webView.delegate = self;
}

// Thanks to https://github.com/boctor/idev-recipes/tree/master/TransparentUIWebViews
- (void) hideGradientBackground:(UIView*)theView {
    for (UIView* subview in theView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebView Delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

@end

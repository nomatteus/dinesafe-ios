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
    self.navigationItem.title = @"About";
    
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self hideGradientBackground:self.webView];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"About" ofType:@"html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
    // Open mail links
    if ([[[request URL] scheme] isEqual:@"mailto"]) {
        NSLog(@"mail link");
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    // Open Link in twitter if available
    if ([[[request URL] scheme] isEqual:@"twitter"]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
            [[UIApplication sharedApplication] openURL:[request URL]];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Twitter App Not Found"
                                        message:@"Please use the web link, or install Twitter from the app store."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil] show];
        }
        return NO;
    }
    // Open links in Safari
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

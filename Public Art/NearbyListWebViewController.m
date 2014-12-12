//
//  NearbyListWebViewController.m
//  GraffitiFound
//
//  Created by Leonard Bogdonoff on 10/24/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "NearbyListWebViewController.h"
#import "WebViewJavascriptBridge.h"

@interface NearbyListWebViewController ()
@property WebViewJavascriptBridge* bridge;
@end

@protocol NearbyListWebViewController<NSObject>

@end

@implementation NearbyListWebViewController

- (void)UIActivityButtonAction:(NSString *)shareString
               imageForSharing:(NSString *)clickedImageURL
{
    // THIS NEEDS AN EVENT
    NSURL *URL = [NSURL URLWithString:clickedImageURL];
    NSLog(@"%@", shareString);
    NSLog(@"%@", clickedImageURL);
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems: @[shareString, URL]

                                      applicationActivities:nil];
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                         NSLog(@"Test");
                     }];
}

- (void)loadView
{
    UIWebView *webView = [[UIWebView alloc] init];

    if (_bridge) { return; }
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
   
    [_bridge registerHandler:@"shareButtonPressed" handler:^(id data, WVJBResponseCallback responseCallback) {
        // THIS NEEDS AN EVENT
        NSLog(@"Share button was pressed");
        NSString *actualImage = self.imageContent;
        NSString *stringShared = @"Street art from publicart.io";
        
        [self UIActivityButtonAction:stringShared imageForSharing:actualImage];
    }];
   
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    
    webView.scalesPageToFit = YES;
    self.view = webView;
}

- (void)setURL:(NSURL *)URL
{
    _URL = URL;
    if (_URL) {
        NSURLRequest *req = [NSURLRequest requestWithURL:_URL];
        [(UIWebView *)self.view loadRequest:req];
    }
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    // If this bar button item does not have a title, it will not appear at all
    barButtonItem.title = @"Nearby Graffiti";
    
    // Take this bar button item and put it on the left side of the nav item
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Remove the bar button item from the navigation item
    // Double check that it is the correct button, even though we know it is
    if (barButtonItem == self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

@end

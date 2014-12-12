//
//  NearbyListWebViewController.h
//  GraffitiFound
//
//  Created by Leonard Bogdonoff on 10/24/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NearbyListWebViewController : UIViewController<UIWebViewDelegate>
{
//    IBOutlet UIWebView *webView;
}

@property (nonatomic) NSURL *URL;
@property (nonatomic) NSString *imageContent;

@end

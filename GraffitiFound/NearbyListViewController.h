//
//  NearbyListViewController.h
//  GraffitiFound
//
//  Created by Leonard Bogdonoff on 10/24/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class NearbyListWebViewController;

@interface NearbyListViewController : UITableViewController

@property (nonatomic) NearbyListWebViewController *webViewController;

@end

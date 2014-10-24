//
//  NearbyListViewController.m
//  GraffitiFound
//
//  Created by Leonard Bogdonoff on 10/24/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "NearbyListViewController.h"

// 4. Create property to hold NSURLSession
@interface NearbyListViewController ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation NearbyListViewController

#pragma mark NSURL 

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"Nearby Graffiti";
        
        // 5. Override initWithStyle to create the NSURLSession object
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:nil];
    }
    return self;
}

#pragma mark Table Related
// 1. write stubs for required data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)indexPath
{
    return nil;
}

@end

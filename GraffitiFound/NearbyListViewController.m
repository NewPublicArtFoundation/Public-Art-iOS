//
//  NearbyListViewController.m
//  GraffitiFound
//
//  Created by Leonard Bogdonoff on 10/24/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "NearbyListViewController.h"

@interface NearbyListViewController ()

// 4. Create property to hold NSURLSession
@property (nonatomic, strong) NSURLSession *session;

// 8. Create array to hold on to JSON response array
@property (nonatomic, copy) NSArray *nearbyGraffiti;

@end

@implementation NearbyListViewController

#pragma mark NSURL 

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"Nearby Graffiti";
        
        // 5. Override initWithStyle to create the NSURLSession object
        // Want the defaults, so pass nil for second and third options
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:nil];
        [self fetchFeed];
    }
    return self;
}


// 6. Create method for NSURLRequest and use NSURL to create NSURLSessionDataTask to transfers request to server
// NSURLRequest explained
// a. create an NSURL instance
// b. instantiate a request object with it

- (void)fetchFeed
{
    NSString *requestString = @"http://localhost:8000/xcode.json";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         // Use NSJSONSerialization to convert raw JSON data instead of String
                                                         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                    options:0
                                                                                                                      error:nil];
                                                         // {name of local data store} = {json accessor and content reference}
                                                         self.nearbyGraffiti = jsonObject[@"data"];
                                                         NSLog(@"%@", self.nearbyGraffiti);
                                                     }
                                      ];
    [dataTask resume];
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

#pragma mark General
// 10. Overwrite the default action
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

@end

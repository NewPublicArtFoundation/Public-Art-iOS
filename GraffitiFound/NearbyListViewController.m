//
//  NearbyListViewController.m
//  GraffitiFound
//
//  Created by Leonard Bogdonoff on 10/24/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "NearbyListViewController.h"
#import "NearbyListWebViewController.h"
#import "NearbyGraffitiCell.h"

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
    NSString *requestString = @"http://localhost:8000/graffiti.json";
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
                                                         
                                                         // Force NSURLSessionDataTask response to run on the main thread to allow reload the table view
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [self.tableView reloadData];
                                                         });
                                                     }
                                      ];
    [dataTask resume];
}



#pragma mark Table Related

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *nearbyGraffiti = self.nearbyGraffiti[indexPath.row];
    NSURL *URL = [NSURL URLWithString:nearbyGraffiti[@"url"]];
    
    self.webViewController.title = nearbyGraffiti[@"title"];
    self.webViewController.URL = URL;
    
    if (!self.splitViewController) {
        [self.navigationController pushViewController:self.webViewController
                                             animated:YES];
    }
}

// 1. write stubs for required data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nearbyGraffiti count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get a new or recycled cell
    NearbyGraffitiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NearbyGraffitiCell"
                                                               forIndexPath:indexPath];
    
    NSDictionary *nearbyGraffiti = self.nearbyGraffiti[indexPath.row];
    
    // Configure the cell with the NearbyGraffitiCell
    cell.distanceLabel.text = nearbyGraffiti[@"distance"];
    cell.backgroundColor = [UIColor blackColor];
    
    return cell;
}

#pragma mark General
// 10. Overwrite the default action
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"NearbyGraffitiCell" bundle:nil];
    
    // Register this NIB, which contrains the cell
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"NearbyGraffitiCell"];
}

@end

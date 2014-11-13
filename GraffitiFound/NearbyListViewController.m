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
#import "INTULocationManager.h"
#import "Mixpanel.h"
#import "SVPullToRefresh.h"

@interface NearbyListViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeoutLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *desiredAccuracyControl;
@property (weak, nonatomic) IBOutlet UISlider *timeoutSlider;
@property (weak, nonatomic) IBOutlet UIButton *requestCurrentLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *forceCompleteRequestButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

// 4. Create property to hold NSURLSession
@property (nonatomic, strong) NSURLSession *session;

// 8. Create array to hold on to JSON response array
@property (nonatomic, copy) NSArray *nearbyGraffiti;

@property (assign, nonatomic) INTULocationAccuracy desiredAccuracy;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (assign, nonatomic) NSInteger locationRequestID;
@property (assign, nonatomic) NSString *queryGraffiti;

@end

@implementation NearbyListViewController

#pragma mark NSURL 

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self){

        self.title = @"Find";
        self.navigationItem.title = @"Nearby Graffiti";
        UIImage *image = [UIImage imageNamed:@"find.png"];
        self.tabBarItem.image = image;
        
        self.queryGraffiti = @"new+york+city";
        
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

    // Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *queryURL = @"http://www.graffpass.com/find.json/";
    NSString *queryParam = self.queryGraffiti;
    NSString *query = [queryURL stringByAppendingString:[NSString stringWithFormat:@"?search=%@", queryParam]];
    
    NSURL *url = [NSURL URLWithString:query];
    
    NSLog(@"%@", url);
    
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
    NSString *queryURL = @"http://www.graffpass.com/instagram_arts/";

    NSString *graffitiId = nearbyGraffiti[@"properties"][@"id"];
    NSString *graffitiLocation = nearbyGraffiti[@"distance"];
    
    NSString *queryIDParam = [NSString stringWithFormat:@"%@", graffitiId];
    NSString *queryDistanceParam = [NSString stringWithFormat:@"?dist=%@", graffitiLocation];
    
    NSString *queryWithID = [queryURL stringByAppendingString:queryIDParam];
    NSString *queryWithIDWithLocation = [queryWithID stringByAppendingString:queryDistanceParam];
    
    NSURL *URL = [NSURL URLWithString:queryWithIDWithLocation];
    
    NSLog(@"queryIDParam: %@", queryIDParam);
    NSLog(@"queryDistanceParam: %@", queryDistanceParam);
    NSLog(@"queryWithID: %@", queryWithID);
    NSLog(@"queryWithIDWithLocation: %@", queryWithIDWithLocation);
    NSLog(@"URL: %@", URL);
    
    [[Mixpanel sharedInstance] track:@"Request URL"
                          properties:@{@"url": queryWithIDWithLocation}];
    
    self.webViewController.URL = URL;
    self.webViewController.hidesBottomBarWhenPushed = YES;
    
    [[Mixpanel sharedInstance] track:@"Image clicked" properties:@{@"url": queryIDParam}];
    
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
    static NSString *MyIdentifier = @"NearbyGraffitiCell";
   
    // Get a new or recycled cell
    NearbyGraffitiCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    
    NSDictionary *nearbyGraffiti = self.nearbyGraffiti[indexPath.row];
    
    // Configure the cell with the NearbyGraffitiCell
    cell.distanceLabel.text = nearbyGraffiti[@"distance"];
    cell.backgroundColor = [UIColor clearColor];
    
    NSString *imageUrlString = nearbyGraffiti[@"properties"][@"title"];
    NSURL *url = [NSURL URLWithString:imageUrlString];
    
    cell.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.backgroundImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

#pragma mark General

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)insertRowAtTop {
    
    NSLog(@"Inset row at top");
    __weak NearbyListViewController *weakSelf = self;
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableView beginUpdates];
//        [weakSelf.dataSource insertObject:[NSDate date] atIndex:0];
        NSLog(@"Loading");
//        [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self startLocationRequest:nil];
        
        [weakSelf.tableView endUpdates];
        
        [weakSelf.tableView.pullToRefreshView stopAnimating];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak NearbyListViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    UIBarButtonItem *_btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_settings_black"]
                                                                landscapeImagePhone:[UIImage imageNamed:@"ic_settings_black"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(loadSettingsPage:)];
    self.navigationItem.rightBarButtonItem = _btn;
    
    self.desiredAccuracyControl.selectedSegmentIndex = 0;
    self.desiredAccuracy = INTULocationAccuracyCity;
    self.timeoutSlider.value = 10.0;
    self.timeout = 10.0;
    self.locationRequestID = NSNotFound;
    self.statusLabel.text = @"Tap the button below to start a new location request.";
    
    
    
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"NearbyGraffitiCell" bundle:nil];
    
    // Register this NIB, which contrains the cell
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"NearbyGraffitiCell"];
}

# pragma mark Location

/**
 Callback when the "Request Current Location" button is tapped.
 */
- (IBAction)startLocationRequest:(id)sender
{
    __weak __typeof(self) weakSelf = self;
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr requestLocationWithDesiredAccuracy:self.desiredAccuracy
                                                                timeout:self.timeout
                                                   delayUntilAuthorized:YES
                                                                  block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                                      __typeof(weakSelf) strongSelf = weakSelf;
                                                                      
                                                                      if (status == INTULocationStatusSuccess) {
                                                                          // achievedAccuracy is at least the desired accuracy (potentially better)
                                                                          strongSelf.statusLabel.text = [NSString stringWithFormat:@"Location request successful! Current Location:\n%@", currentLocation];
                                                                          
                                                                          NSString *queryGraffiti = [[NSString alloc] initWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
                                                                          
                                                                          [[Mixpanel sharedInstance] track:@"Current location"
                                                                                                properties:@{@"coordinates": queryGraffiti}];
                                                                          
                                                                          self.queryGraffiti = queryGraffiti;
                                                                          NSLog(@"%@", queryGraffiti);
                                                                          

                                                                          
                                                                          [mixpanel track:@"Request current location" properties:@{
                                                                                                                                   @"Request": @"Success"
                                                                                                                                   }];
                                                                          
                                                                          [self fetchFeed];
                                                                          
                                                                      }
                                                                      else if (status == INTULocationStatusTimedOut) {
                                                                          // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
                                                                          
                                                                          [mixpanel track:@"Request current location" properties:@{
                                                                                                                                   @"Request": @"Timed Out"
                                                                                                                                   }];
                                                                          strongSelf.statusLabel.text = [NSString stringWithFormat:@"Location request timed out. Current Location:\n%@", currentLocation];
                                                                      }
                                                                      else {
                                                                          // An error occurred
                                                                          if (status == INTULocationStatusServicesNotDetermined) {
                                                                              strongSelf.statusLabel.text = @"Error: User has not responded to the permissions alert.";
                                                                              [mixpanel track:@"Request current location" properties:@{
                                                                                                                                       @"Request": @"No Permissions"
                                                                                                                                       }];
                                                                          } else if (status == INTULocationStatusServicesDenied) {
                                                                              strongSelf.statusLabel.text = @"Error: User has denied this app permissions to access device location.";
                                                                              [mixpanel track:@"Request current location" properties:@{
                                                                                                                                       @"Request": @"Denied Permissions"
                                                                                                                                       }];
                                                                          } else if (status == INTULocationStatusServicesRestricted) {
                                                                              strongSelf.statusLabel.text = @"Error: User is restricted from using location services by a usage policy.";
                                                                              [mixpanel track:@"Request current location" properties:@{
                                                                                                                                       @"Request": @"Restricted Location Policy"
                                                                                                                                       }];
                                                                          } else if (status == INTULocationStatusServicesDisabled) {
                                                                              strongSelf.statusLabel.text = @"Error: Location services are turned off for all apps on this device.";
                                                                              [mixpanel track:@"Request current location" properties:@{
                                                                                                                                       @"Request": @"Location Services Off"
                                                                                                                                       }];
                                                                          } else {
                                                                              strongSelf.statusLabel.text = @"An unknown error occurred.\n(Are you using iOS Simulator with location set to 'None'?)";
                                                                              [mixpanel track:@"Request current location" properties:@{
                                                                                                                                       @"Request": @"Unknown Error"
                                                                                                                                       }];
                                                                          }
                                                                      }
                                                                      
                                                                      strongSelf.locationRequestID = NSNotFound;
                                                                  }];
    
}

- (IBAction)loadSettingsPage:(id)sender
{
    
//    UITabBarController *tabBarController = [[UITabBarController alloc] init];
//    tabBarController.viewControllers = @[masterNav, lsvc];
//    
//    tabBarController.view.autoresizingMask=(UIViewAutoresizingFlexibleHeight);
//    
//    self.window.rootViewController = tabBarController;
}

/**
 Callback when the "Force Complete Request" button is tapped.
 */
- (IBAction)forceCompleteRequest:(id)sender
{
    [[INTULocationManager sharedInstance] forceCompleteLocationRequest:self.locationRequestID];
}


/**
 Callback when the "Cancel Request" button is tapped.
 */
- (IBAction)cancelRequest:(id)sender
{
    [[INTULocationManager sharedInstance] cancelLocationRequest:self.locationRequestID];
    self.locationRequestID = NSNotFound;
    self.statusLabel.text = @"Location request cancelled.";
}

- (IBAction)desiredAccuracyControlChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.desiredAccuracy = INTULocationAccuracyCity;
            break;
        case 1:
            self.desiredAccuracy = INTULocationAccuracyNeighborhood;
            break;
        case 2:
            self.desiredAccuracy = INTULocationAccuracyBlock;
            break;
        case 3:
            self.desiredAccuracy = INTULocationAccuracyHouse;
            break;
        case 4:
            self.desiredAccuracy = INTULocationAccuracyRoom;
            break;
        default:
            break;
    }
}

- (IBAction)timeoutSliderChanged:(UISlider *)sender
{
    self.timeout = round(sender.value);
    self.timeoutLabel.text = [NSString stringWithFormat:@"Timeout: %ld seconds", (long)self.timeout];
}

/**
 Implement the setter for locationRequestID in order to update the UI as needed.
 */
- (void)setLocationRequestID:(NSInteger)locationRequestID
{
    _locationRequestID = locationRequestID;
    
    BOOL isProcessingLocationRequest = (locationRequestID != NSNotFound);
    
    self.desiredAccuracyControl.enabled = !isProcessingLocationRequest;
    self.timeoutSlider.enabled = !isProcessingLocationRequest;
    self.requestCurrentLocationButton.enabled = !isProcessingLocationRequest;
    self.forceCompleteRequestButton.enabled = isProcessingLocationRequest;
    self.cancelRequestButton.enabled = isProcessingLocationRequest;
    
    if (isProcessingLocationRequest) {
        [self.activityIndicator startAnimating];
        self.statusLabel.text = @"Location request in progress...";
    } else {
        [self.activityIndicator stopAnimating];
    }
}

@end
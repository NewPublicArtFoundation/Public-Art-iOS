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
#import "LocationSettingsViewController.h"
#import "INTULocationManager.h"
#import "Mixpanel.h"
#import "SVPullToRefresh.h"
#import "MCSwipeTableViewCell.h"

@interface NearbyListViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeoutLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *desiredAccuracyControl;
@property (weak, nonatomic) IBOutlet UISlider *timeoutSlider;
@property (weak, nonatomic) IBOutlet UIButton *requestCurrentLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *forceCompleteRequestButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) MCSwipeTableViewCell *cellToDelete;

// 4. Create property to hold NSURLSession
@property (nonatomic, strong) NSURLSession *session;

// 8. Create array to hold on to JSON response array
@property (nonatomic, copy) NSArray *nearbyGraffiti;

@property (assign, nonatomic) INTULocationAccuracy desiredAccuracy;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (assign, nonatomic) NSInteger locationRequestID;
@property (assign, nonatomic) NSString *queryGraffiti;
@property (assign, nonatomic) NSString *queryURL;
@property (assign, nonatomic) NSInteger queryPage;
@property (assign, nonatomic) BOOL ivarNoResults;
@property (nonatomic, assign) NSUInteger nbItems;
@end

@implementation NearbyListViewController

#pragma mark NSURL 

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self){

        self.navigationItem.title = @"Start searching";
        self.queryGraffiti = @"new+york+city";
        // 5. Override initWithStyle to create the NSURLSession object
        // Want the defaults, so pass nil for second and third options
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:nil];
        self.queryPage = 1;
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
    NSString* queryPage = [NSString stringWithFormat:@"%li", (long)self.queryPage];
    [[Mixpanel sharedInstance] track:@"Query page" properties:@{@"Value": queryPage}];
    // Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSLog(@"Querying page %@", queryPage);
    NSString *queryURL = @"http://www.graffpass.com/find.json/";
    NSString *queryParam = self.queryGraffiti;
    NSString *query = [queryURL stringByAppendingString:[NSString stringWithFormat:@"?search=%@&page=%@", queryParam, queryPage]];
    self.queryURL = query;
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
                                                         [self.tableView setSeparatorColor:[UIColor colorWithRed:1.00 green:0.58 blue:0.48 alpha:1.0]];
//                                                         NSLog(@"%@", self.nearbyGraffiti);
                                                         
                                                         // Force NSURLSessionDataTask response to run on the main thread to allow reload the table view
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             _nbItems = [self.nearbyGraffiti count];
                                                             [self.tableView reloadData];
                                                             
                                                         });
                                                     }
                                      ];
    [dataTask resume];
    
}


- (void)crash {
    [NSException raise:NSGenericException format:@"Everything is ok. This is just a test crash."];
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
    
    NSString *imageUrlString = nearbyGraffiti[@"properties"][@"title"];
    
    self.webViewController.URL = URL;
    self.webViewController.hidesBottomBarWhenPushed = YES;
    self.webViewController.imageContent = imageUrlString;
    
    [[Mixpanel sharedInstance] track:@"Image clicked" properties:@{@"url": queryIDParam}];
    
    if (!self.splitViewController) {
        [self.navigationController pushViewController:self.webViewController
                                             animated:YES];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// 1. write stubs for required data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.nearbyGraffiti == 0) {
            self.ivarNoResults = YES;
            return 1;
        } else {
            self.ivarNoResults = NO;
            
        }
    }
    
    return _nbItems;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        // Setting the background color of the cell.
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    UIView *crossView = [self viewWithImageName:@"cross"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    
    UIView *shareView = [self viewWithImageName:@"share"];
    UIColor *yellowColor = [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0];
    
    UIView *listView = [self viewWithImageName:@"list"];
    UIColor *brownColor = [UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0];
    
    // Setting the default inactive state color to the tableView background color.
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    [cell.textLabel setText:@"Switch Mode Cell"];
    [cell.detailTextLabel setText:@"Swipe to switch"];
    

    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Cross\" cell");
        
        _cellToDelete = cell;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                            message:@"Are you sure your want to delete the cell?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        [alertView show];
    }];
    
    [cell.textLabel setText:@"Right swipe only"];
    [cell.detailTextLabel setText:@"Swipe"];
    
    [cell setSwipeGestureWithView:shareView color:yellowColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        
        NSLog(@"Did swipe \"share\" cell");
        NSString *stringShared = cell.textLabel.text;
        NSString *actualImage = @"http://www.google.com";
        [self UIActivityButtonAction:stringShared imageForSharing:actualImage];
    }];
    
    [cell setSwipeGestureWithView:listView color:brownColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"List\" cell");
    }];
    return cell;
}


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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // No
    if (buttonIndex == 0) {
        [_cellToDelete swipeToOriginWithCompletion:^{
            NSLog(@"Swiped back");
        }];
        _cellToDelete = nil;
    }
    
    // Yes
    else {
        _nbItems--;
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cellToDelete]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 115;
}

#pragma mark General

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)insertRowAtTop {
    self.navigationItem.title = [NSString stringWithFormat:@"Searching %@", @"Nearby..."];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Pulling to refresh" properties:@{
                                                             @"Request": @"Success"
                                                             }];

    
    NSLog(@"Inset row at top");
    self.queryPage = 1;
    [self startLocationRequest:nil];
    
    __weak NearbyListViewController *weakSelf = self;
    
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [weakSelf.tableView beginUpdates];
        
    NSLog(@"Loading");
    [weakSelf.tableView endUpdates];
    [weakSelf.tableView.pullToRefreshView stopAnimating];
    });

}

- (void)insertRowAtBottom {
    __weak NearbyListViewController *weakSelf = self;
    
    int64_t delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableView beginUpdates];
      NSLog(@"Infinite Scroll");
        
        [weakSelf.tableView endUpdates];
//        self.queryGraffiti = escapedSearchQuery;
        self.queryPage = self.queryPage + 1;
        
        [self fetchFeed];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        
        NSLog(@"Looking at: %@", self.queryGraffiti);
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
    });
}


- (void)setupSearchBar
{
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    searchBar.barStyle = UIBarStyleBlackOpaque;
    searchBar.placeholder = @"Search city name or address";
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;


    self.tableView.tableHeaderView = searchBar;
    [searchBar setDelegate:self];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBarResult
{

    NSString *searchQuery = searchBarResult.text;
    self.navigationItem.title = [NSString stringWithFormat:@"%@", searchQuery];
    NSLog(@"User searched for %@", searchQuery);
    NSLog(@"Search button pressed");
    
    [[Mixpanel sharedInstance] track:@"Search bar query term"
                          properties:@{@"searchQuery": searchQuery}];
    
    NSString *escapedSearchQuery =[searchQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    self.queryGraffiti = escapedSearchQuery;
    [searchDisplayController setActive:NO];
    [searchBar resignFirstResponder];
    [self fetchFeed];
    [self.tableView reloadData];
    
}

- (void)didWriteToSavedPhotosAlbum
{
    
}



//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}



- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setupSearchBar];

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0]];
    [self.tableView setBackgroundView:backgroundView];
    
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1.0];
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.queryPage = 1;
    self.navigationItem.title = @"Start searching";
    __weak NearbyListViewController *weakSelf = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1.0];
    // setup pull-to-refresh
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    // setup infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    self.edgesForExtendedLayout = UIRectEdgeNone;



    
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
                                                                          
                                                                          self.queryPage = 1;
                                                                          
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
    LocationSettingsViewController *settingsView = [[LocationSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsView animated:YES];
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
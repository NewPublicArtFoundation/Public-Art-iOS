//
//  LocationSettingsViewController.m
//  graffitifound
//
//  Created by Leonard Bogdonoff on 11/8/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "LocationSettingsViewController.h"

@interface LocationSettingsViewController ()

@property (assign, nonatomic) INTULocationAccuracy locationAccuracy;
@property (weak, nonatomic) IBOutlet UILabel *curLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationAccuLabel;
@property (weak, nonatomic) IBOutlet UITextField *curLocationTextInput;
@property (weak, nonatomic) IBOutlet UIImageView *curLocationImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *locationAccuControl;
@property (weak, nonatomic) IBOutlet UIButton *curLocationImageButton;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UITextField *userEmailTextInput;

@end

@implementation LocationSettingsViewController

- (IBAction)locationAccuControlChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.locationAccuracy = INTULocationAccuracyBlock;
            break;
        case 1:
            self.locationAccuracy = INTULocationAccuracyNeighborhood;
            break;
        case 2:
            self.locationAccuracy = INTULocationAccuracyCity;
            break;
        default:
            break;
    }
}

-(void)updateSettings
{
    NSLog(@"Settings updated");
}


-(void)setupCurrentLocation
{
    NSString *imageUrlString = @"http://maps.google.com/maps/api/staticmap?size=300x100&sensor=false&zoom=7&markers=40.7127%2C-74.0059";
    NSURL *url = [NSURL URLWithString:imageUrlString];
    
    self.curLocationImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.curLocationImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCurrentLocation];
    self.locationAccuControl.selectedSegmentIndex = 1;
    self.locationAccuracy = INTULocationAccuracyCity;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if(self){
        self.tabBarItem.title = @"Settings";
    }

    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

@end

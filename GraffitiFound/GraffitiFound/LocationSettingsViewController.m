//
//  LocationSettingsViewController.m
//  graffitifound
//
//  Created by Leonard Bogdonoff on 11/8/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "LocationSettingsViewController.h"

@interface LocationSettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *curLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationAccuLabel;
@property (weak, nonatomic) IBOutlet UITextField *curLocationTextInput;
@property (weak, nonatomic) IBOutlet UIImageView *curLocationImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *locationAccuControl;
@property (weak, nonatomic) IBOutlet UIButton *curLocationImageButton;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UITextField *userEmailTextInput;

@end

@implementation LocationSettingsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
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

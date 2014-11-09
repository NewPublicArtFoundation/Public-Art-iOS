//
//  LocationSettingsViewController.m
//  graffitifound
//
//  Created by Leonard Bogdonoff on 11/8/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//

#import "LocationSettingsViewController.h"

@interface LocationSettingsViewController () <UITextFieldDelegate>

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

-(IBAction)tappedMapImage:(id)sender
{
    NSLog(@"Map image tapped");
}

-(IBAction)updateSettings:(id)sender
{
    NSString *location = self.curLocationTextInput.text;
    NSString *email = self.userEmailTextInput.text;
    NSLog(@"location: %@", location);
    NSLog(@"email: %@", email);
    NSLog(@"Settings updated");
}


-(void)setupCurrentLocation
{
    NSString *imageUrlString = @"http://maps.google.com/maps/api/staticmap?size=300x100&sensor=false&zoom=7&markers=40.7127%2C-74.0059";
    NSURL *url = [NSURL URLWithString:imageUrlString];
    
    self.curLocationImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.curLocationImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

- (void)setupOutlets
{
    self.curLocationTextInput.delegate = self;
    self.curLocationTextInput.tag = 1;
    
    self.userEmailTextInput.delegate = self;
    self.userEmailTextInput.tag = 2;
}

-(void)disableQuickType
{
    self.userEmailTextInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.curLocationTextInput.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    [self jumpToNextTextField:textField withTag:nextTag];
    
    return NO;
}

/*
 Makes the cursor to jump to the next textfield if the "Next" button
 is pressed from the keyboard.
 */
- (void)jumpToNextTextField:(UITextField *)textField withTag:(NSInteger)tag
{
    // Gets the next responder from the view. Here we use self.view because we are searching for controls with
    // a specific tag, which are not subviews of a specific views, because each textfield belongs to the
    // content view of a static table cell.
    //
    // In other cases may be more convenient to use textField.superView, if all textField belong to the same view.
    UIResponder *nextResponder = [self.view viewWithTag:tag];
    
    if ([nextResponder isKindOfClass:[UITextField class]]) {
        // If there is a next responder and it is a textfield, then it becomes first responder.
        [nextResponder becomeFirstResponder];
    }
    else {
        // If there is not then removes the keyboard.
        [textField resignFirstResponder];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCurrentLocation];
    [self setupOutlets];
    [self disableQuickType];
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
#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{

}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

@end

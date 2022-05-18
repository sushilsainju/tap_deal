//
//  BusinessRegistrationViewController.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/3/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UITextField+Custom.h"
#import "SharedStore.h"

@interface BusinessRegistrationViewController : UIViewController<UITextFieldDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

// Properties
@property (nonatomic, strong) CLLocationManager *locationManager;

// IBOutlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *businessNameTextField;

@property (strong, nonatomic) IBOutlet UITextField *businessRegistrationNumberTextField;

@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UIButton *selectCountryButton;


@property (weak, nonatomic) IBOutlet UITextField *addressLine1TextField;
@property (weak, nonatomic) IBOutlet UITextField *addressLine2TextField;
@property (weak, nonatomic) IBOutlet UITextField *suburbTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationYesButton;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationNoButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *pickAnImageButton;

// contact
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *contactPersonTextField;

// buttons
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userYourCurrentLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;



// IBActions
- (IBAction)didPressContinueButton:(id)sender;

- (IBAction)didPressCancelButton:(id)sender;

- (IBAction)didPressPickAnImageButton:(id)sender;

-(IBAction)didPressUseLocationToggle:(id)sender;

- (IBAction)didPressSelectCountryButton:(id)sender;


@end

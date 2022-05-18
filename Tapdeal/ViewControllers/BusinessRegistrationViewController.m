//
//  BusinessRegistrationViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/3/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "BusinessRegistrationViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "AppDelegate.h"
#import "SharedStore.h"

#import "UIImage+Custom.h"
#import "UITextField+Custom.h"
#import "UIButton+Custom.h"
#import "UILabel+Custom.h"

#import <AFNetworking/AFNetworking.h>

#import "CustomAnnotation.h"
#import <ActionSheetStringPicker.h>
#import <ActionSheetDatePicker.h>

@interface BusinessRegistrationViewController()<MKMapViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImage *logoImage;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *captureCancelButton;

@property (strong, nonatomic) IBOutlet UIButton *gpsButton;


@property (nonatomic) BOOL isUsingLocationFromMap;

// picker view
@property (nonatomic, strong) NSArray *pickerData;
@property (assign) NSInteger pickerDataSelectedIndex;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIActionSheet *pickerViewActionSheet;

// PFobjects
@property (nonatomic, strong) PFObject *businessLocation;
@property (nonatomic, strong) PFObject *business;

@property (nonatomic, strong) CustomAnnotation *customAnnotation;


- (IBAction)didPressGPSButton:(id)sender;


@end


@implementation BusinessRegistrationViewController

@synthesize businessNameTextField, businessRegistrationNumberTextField, countryTextField, addressLine1TextField;
@synthesize addressLine2TextField, suburbTextField, stateTextField;
@synthesize currentLocationYesButton, currentLocationNoButton;
@synthesize phoneTextField, emailTextField, contactPersonTextField;
@synthesize cancelButton, continueButton;
@synthesize scrollView, pickAnImageButton, mapView;
@synthesize locationManager, customAnnotation;

@synthesize actionSheet, logoImage, imagePickerController;

@synthesize overlayView, captureButton, captureCancelButton;

@synthesize isUsingLocationFromMap;

@synthesize pickerViewActionSheet, pickerView, pickerData, pickerDataSelectedIndex;

@synthesize navBarTitleLabel, userYourCurrentLocationLabel, locationLabel, contactLabel;


@synthesize business, businessLocation;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    pickerData = [[SharedStore store] getAllCountry];
    
    
    isUsingLocationFromMap = YES;
    pickerDataSelectedIndex = 0; // initially select first item
    
    [self customizeView];
    [self resetScrollView];
    
    // just preparing overlay view for camera
    [self prepareOverlayView];
    
    businessLocation = nil;
    business = nil;
    
    CLLocation *currentLocation = DELEGATE.locationManager.location;
    customAnnotation = [[CustomAnnotation alloc] initWithCoordinate:currentLocation.coordinate title:nil subTitle:nil deal:nil];
    
   [self checkUserAlreadyHasBusinessRegistered];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

#pragma mark - custom methods

-(void) resignFirstResponderFromAllTextFields{
    
    [emailTextField resignFirstResponder];
    [businessNameTextField resignFirstResponder];
    [addressLine1TextField resignFirstResponder];
    [addressLine2TextField resignFirstResponder];
    [suburbTextField resignFirstResponder];
    [stateTextField resignFirstResponder];
    [phoneTextField resignFirstResponder];
    [contactPersonTextField resignFirstResponder];
    
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
}

-(void)customizeView{
    
    [businessNameTextField setTheme];
    [businessRegistrationNumberTextField setTheme];
    [countryTextField setTheme];
    [addressLine1TextField setTheme];
    [addressLine2TextField setTheme];
    [suburbTextField setTheme];
    [stateTextField setTheme];
    [phoneTextField setTheme];
    [emailTextField setTheme];
    [contactPersonTextField setTheme];
    
    [continueButton setCustomFont];
    [navBarTitleLabel setNavBarFont];
    [locationLabel setNormalFont];
    [userYourCurrentLocationLabel setNormalFont];
    [contactLabel setNormalFont];
    [cancelButton setCustomFontWithWhiteColor];
}

-(void)resetScrollView{
    
    scrollView.scrollEnabled = YES;
    [scrollView setContentSize:(CGSizeMake(320, 900))];
    
    CGRect frame = self.scrollView.frame;
    
    frame.size = CGSizeMake(320, ScreenSize.height - 64);
    
    [self.scrollView setFrame:frame];
    NSLog(@"scroll view height: %f", scrollView.frame.size.height);
}


-(void)checkUserAlreadyHasBusinessRegistered{
    
    if ([[DEFAULTS valueForKey:@"ifDealerHasBusiness"] boolValue]) {
        PFUser *currentUser = [PFUser currentUser];
        PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
        [query whereKey:FIELD_BUSINESS_DEALER equalTo:currentUser];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [query findObjectsInBackgroundWithBlock:^(NSArray *businesses, NSError *error) {
            if (!error) {
                NSLog(@"businesses array: %@", businesses);
                if ([businesses count]) {
                    
                    business = [businesses objectAtIndex:0];
                    
                    NSArray *businessLocations =  business[FIELD_BUSINESS_BUSINESSLOCATIONS];
                    if ([businessLocations count]) {
                        
                        PFObject *location = [businessLocations objectAtIndex:0];
                        
                        NSLog(@"business locations array: %@", businessLocations);
                        // query for business location
                        PFQuery *locationQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS_LOCATION];
                        [locationQuery whereKey:@"objectId" equalTo:location.objectId];
                        
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *locations, NSError *errorOnLocations) {
                            if (!error) {
                                NSLog(@"business locations: %@", locations);
                                if([locations count]){
                                    
                                    
                                    businessLocation = [locations objectAtIndex:0];
                                    
                                    
                                    // populate form fields
                                    countryTextField.text = businessLocation[FIELD_BUSINESSLOCATION_COUNTRY];
                                    addressLine1TextField.text = businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE1];
                                    addressLine2TextField.text = businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE2];
                                    suburbTextField.text = businessLocation[FIELD_BUSINESSLOCATION_SUBURB];
                                    stateTextField.text = businessLocation[FIELD_BUSINESSLOCATION_STATE];
                                    phoneTextField.text = businessLocation[FIELD_BUSINESSLOCATION_PHONE];
                                    emailTextField.text = businessLocation[FIELD_BUSINESSLOCATION_EMAIL];
                                    contactPersonTextField.text = businessLocation[FIELD_BUSINESSLOCATION_CONTACT_PERSON];
                                    
                                    businessNameTextField.text = business[FIELD_BUSINESS_NAME];
                                    businessRegistrationNumberTextField.text = business[FIELD_BUSINESS_BUSINESS_NUMBER];
                                    
                                    
                                    // showing saved address lat, lng on map
                                    
                                    PFGeoPoint *businessLocationPoint = businessLocation[FIELD_BUSINESSLOCATION_LOCATION_POINT];
                                    
                                    CLLocation *dealerLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(businessLocationPoint.latitude, businessLocationPoint.longitude) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:0 timestamp:[NSDate date]];
                                    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(dealerLocation.coordinate, 1800, 1800);
                                    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
                                    
                                    //                                    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                                    //                                    point.coordinate =  dealerLocation.coordinate;
                                    //                                    [self.mapView addAnnotation:point];
                                    
                                    customAnnotation.coordinate = dealerLocation.coordinate;
                                    
                                    [self.mapView removeAnnotations:mapView.annotations];
                                    
                                    [self.mapView addAnnotation:customAnnotation];
                                    
                                    
                                    if (businessLocation[FIELD_BUSINESSLOCATION_IS_USING_LOCATION_FROM_MAP]) {
                                        [currentLocationYesButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                                        [currentLocationNoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                                    }else{
                                        [currentLocationYesButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                                        [currentLocationNoButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                                    }
                                    
                                }
                            }else{
                                NSLog(@"error ayo while fetching business location; %@", [errorOnLocations userInfo]);
                            }
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        }];
                        
                    }
                    
                    
                    // setting business logo if found
                    if (business[FIELD_BUSINESS_IMAGE]) {
                        PFFile *businessLogoFile = business[FIELD_BUSINESS_IMAGE];
                        [businessLogoFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                            if (!error) {
                                logoImage = [UIImage imageWithData:imageData];
                                [pickAnImageButton setBackgroundImage:logoImage forState:UIControlStateNormal];
                                [pickAnImageButton setTitle:@"" forState:UIControlStateNormal];
                                [pickAnImageButton setOpaque:NO];
                            }
                        }];
                        
                    }
                }
            }
            else{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
        }];
        
    }
    else{
        CLLocationCoordinate2D coord = DELEGATE.locationManager.location.coordinate;
        
        customAnnotation.coordinate =coord;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 1800, 1800);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
        [self.mapView removeAnnotations:mapView.annotations];
        [self.mapView addAnnotation:customAnnotation];
        
        [self getAddressFromGeoCode:coord];
    }
}

// this view is for camera overlay view.
-(void)prepareOverlayView{
    
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width, ScreenSize.height)];
    //    [overlayView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
    
    // center box
    
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenSize.height/2 - 160, 320, 320)];
    box.layer.borderWidth = 2.0;
    box.layer.borderColor = [UIColor whiteColor].CGColor;
    [overlayView addSubview:box];
    
    
    // cancel button
    
    captureCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [captureCancelButton setFrame:CGRectMake(ScreenSize.width - 35 , 5, 30, 30)];
    [captureCancelButton setTitle:@"X" forState:UIControlStateNormal];
    [captureCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [captureCancelButton setBackgroundColor: [UIColor whiteColor] ];
    [captureCancelButton addTarget:self action:@selector(didPressCameraCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:captureCancelButton];
    
    // capture button
    captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [captureButton setFrame:CGRectMake(125, ScreenSize.height - 75, 70, 70)];
    [captureButton setBackgroundImage:[UIImage imageNamed:@"ImageCaptureButton.png"] forState:UIControlStateNormal];
    [captureButton addTarget:self action:@selector(didPressCaptureButton:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:captureButton];
    
}

-(void)didPressCameraCancelButton: (id)sender{
    // cancel camera view
    NSLog(@"didPressCameraCancelButton");
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)didPressCaptureButton: (id)sender{
    NSLog(@"didPressCaptureButton");
    
    [self.imagePickerController takePicture];
}

-(BOOL)validateForm{
    
    if ([businessNameTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Business name is empty. Please fill it"];
        return NO;
    }
    
    if ([businessRegistrationNumberTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Business Registration Number is empty. Please fill it"];
        return NO;
    }
    
    if (![businessNameTextField checkLimitCharacter:250]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Business name should not exceed 250 characters in length"];
        return NO;
    }
    
    if (!isUsingLocationFromMap) {
        if ([countryTextField isEmpty]) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Country is empty. Please fill it"];
            return NO;
        }
        else if ([addressLine1TextField isEmpty]) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Address Line 1 is empty. Please fill it"];
            return NO;
        }
        else if (![addressLine1TextField checkLimitCharacter:250]) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Address Line 1 should not exceed 250 characters in length"];
            return NO;
        }
        
        else if (![addressLine2TextField checkLimitCharacter:250]) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Address Line 2 should not exceed 250 characters in length"];
            return NO;
        }
        
        else if ([suburbTextField isEmpty]) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Suburb is empty. Please fill it"];
            return NO;
        }
        else if (![suburbTextField checkLimitCharacter:250]) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Suburb should not exceed 250 characters in length"];
            return NO;
        }
        else if ([stateTextField isEmpty]) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"State is empty. Please fill it"];
            return NO;
        }
        else if (![stateTextField checkLimitCharacter:250]) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"State should not exceed 250 characters in length"];
            return NO;
        }
    }
    
    if ([phoneTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Contact phone is empty. Please fill it"];
        return NO;
    }
    else if (![phoneTextField isNumber]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Contact phone should be in number."];
        return NO;
    }
    else if (![phoneTextField checkLimitCharacter:50]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Phone number should not exceed 50 characters in length"];
        return NO;
    }
    else if ([emailTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Email is empty. Please fill it"];
        return NO;
    }
    else if (![emailTextField isValidEmail]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Email is invalid. Please put valid email"];
        return NO;
    }
    else if (![emailTextField checkLimitCharacter:250]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Email address should not exceed 250 characters in length"];
        return NO;
    }
    else if ([contactPersonTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Contact Person field is empty. Please fill it"];
        return NO;
    }
    else if (![contactPersonTextField checkLimitCharacter:250]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Contact Person field should not exceed 250 characters in length"];
        return NO;
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)didPressContinueButton:(id)sender {
    
    if ([self validateForm])
    {
        NSLog(@"form validated, continue from here");
        
        if (!businessLocation)
        {
            businessLocation = [PFObject objectWithClassName:PARSE_CLASS_BUSINESS_LOCATION];
        }
        
        businessLocation[FIELD_BUSINESSLOCATION_COUNTRY] = countryTextField.text;
        businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE1] = addressLine1TextField.text;
        businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE2] = addressLine2TextField.text;
        businessLocation[FIELD_BUSINESSLOCATION_SUBURB] = suburbTextField.text;
        businessLocation[FIELD_BUSINESSLOCATION_STATE] = stateTextField.text;
        businessLocation[FIELD_BUSINESSLOCATION_IS_USING_LOCATION_FROM_MAP] = [NSNumber numberWithBool: isUsingLocationFromMap];
        
        businessLocation[FIELD_BUSINESSLOCATION_PHONE] = phoneTextField.text;
        businessLocation[FIELD_BUSINESSLOCATION_EMAIL] = emailTextField.text;
        businessLocation[FIELD_BUSINESSLOCATION_CONTACT_PERSON] = contactPersonTextField.text;
        businessLocation[FIELD_BUSINESSLOCATION_BUSINESS_NAME_ALIAS] = businessNameTextField.text;
        
        if(!business){
            business = [PFObject objectWithClassName:PARSE_CLASS_BUSINESS];
        }
        
        business[FIELD_BUSINESS_NAME] = businessNameTextField.text;
        business[FIELD_BUSINESS_BUSINESS_NUMBER] = businessRegistrationNumberTextField.text;
        business[FIELD_BUSINESS_DEALER] = [PFUser currentUser];
//        [business setObject:businessLocation forKey:@"location"];
        // adding address to buisness
        business[FIELD_BUSINESS_BUSINESSLOCATIONS] = [NSArray arrayWithObjects:businessLocation, nil];
        
        // saving logo image if there is image
        
        if (logoImage) {
            
            NSData *imageData = UIImagePNGRepresentation(logoImage);
            
            NSLog(@"image data: %@", imageData);
            int rndValue = arc4random() % 1000;
            NSLog(@"random value: %d", rndValue);
            
            NSString *imageName = [NSString stringWithFormat:@"%@_%@_%d.png", businessNameTextField.text, phoneTextField.text, rndValue];
            NSLog(@"image name: %@", imageName);
            PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
            business[FIELD_BUSINESS_IMAGE] = imageFile;
            
        }
        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:customAnnotation.coordinate.latitude longitude:customAnnotation.coordinate.longitude];
        
        businessLocation[FIELD_BUSINESSLOCATION_LOCATION_POINT] = point;
        
        [self saveBusinessInfoAndCloseModal];
    }
    
}

- (IBAction)didPressBackButton:(id)sender {
    NSLog(@"didPressBackButton");
    [self resignFirstResponderFromAllTextFields];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressCancelButton:(id)sender {
    imagePickerController.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)didPressPickAnImageButton:(id)sender {
    
    [self resignFirstResponderFromAllTextFields];
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick an Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Image from Library", @"Capture from Camera", nil];
    [actionSheet showInView:self.view];
    
}

-(IBAction)didPressUseLocationToggle:(id)sender{
    UIButton *aButton = sender;
    if (aButton.tag == 1) {
        // yes tapped
        [currentLocationYesButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [currentLocationNoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        isUsingLocationFromMap = YES;
    }else{
        // no tapped
        [currentLocationNoButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [currentLocationYesButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        isUsingLocationFromMap = NO;
    }
    
}

- (IBAction)didPressSelectCountryButton:(id)sender {
    NSLog(@"downButtonClicked");
    [self resignFirstResponderFromAllTextFields];
    
//    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
//    pickerView.showsSelectionIndicator = YES;
//    pickerView.delegate = self;
//    [pickerView selectRow:pickerDataSelectedIndex inComponent:0 animated:NO];
//    
//    countryTextField.text = [pickerData objectAtIndex:pickerDataSelectedIndex];
//    
//    pickerViewActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Country"
//                                                        delegate:nil
//                                               cancelButtonTitle:nil
//                                          destructiveButtonTitle:nil
//                                               otherButtonTitles:nil];
//    [pickerViewActionSheet setBackgroundColor:[UIColor whiteColor]];
//    
//    [pickerViewActionSheet addSubview:pickerView];
//    
//    UIButton *pickerDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [pickerDoneButton setThemeWithTitleText:@"Done" withFrame:CGRectMake(250, 6 , 62, 30)];
//    
//    
//    [pickerDoneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [pickerViewActionSheet addSubview:pickerDoneButton];
//    
//    [pickerViewActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
//    [pickerViewActionSheet setBounds:CGRectMake(0, 0, 320, 495)];
    [ActionSheetStringPicker showPickerWithTitle:@"Select Catagory"
                                            rows:pickerData
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex1, id selectedValue1) {
                                           NSLog(@"Picker: %@", picker);
                                           NSLog(@"Selected Index: %ld", (long)selectedIndex1);
                                           countryTextField.text = [pickerData objectAtIndex:selectedIndex1];
                                           pickerDataSelectedIndex = selectedIndex1;

//                                           [ setTitle:[pickerData objectAtIndex:selectedIndex1][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
                                           pickerDataSelectedIndex = selectedIndex1;                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];

    
    
}

-(void) doneButtonClicked: (id) sender{
    NSLog(@"action picker done button clicked");
    [pickerViewActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
    stateTextField.text = @"";
    suburbTextField.text = @"";
    addressLine1TextField.text = @"";
    addressLine2TextField.text = @"";
}

#pragma mark - Actionsheet delegate

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"did dismiss with button at index: %ld", (long)buttonIndex);
    if (buttonIndex == 1) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        }
    }
    else if (buttonIndex == 0){
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}


#pragma mark -  Image Picker

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        /*
         The user wants to use the camera interface. Set up our custom overlay view for the camera.
         */
        imagePickerController.showsCameraControls = NO;
        
        /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
        imagePickerController.cameraOverlayView = self.overlayView;
    }
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}



#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *capturedImage= [info valueForKey:UIImagePickerControllerOriginalImage];
    
    // scaling and cropping image
    logoImage = [capturedImage scaleAndCropWithSize:CGSizeMake(400, 400)];
    
    [pickAnImageButton setBackgroundImage:logoImage forState:UIControlStateNormal];
    [pickAnImageButton setTitle:@"" forState:UIControlStateNormal];
    [pickAnImageButton setOpaque:NO];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"user cancelled image picker ...");
    [self dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - UITextFiled delegate

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textfield tag: %d", textField.tag);
    int tag = textField.tag;
    if (tag == 12) {
        suburbTextField.text = @"";
        addressLine1TextField.text = @"";
        addressLine2TextField.text = @"";
    }
    else if (tag == 13) {
        addressLine1TextField.text = @"";
        addressLine2TextField.text = @"";
    }
    else if (tag == 14) {
        addressLine1TextField.text = @"";
        addressLine2TextField.text = @"";
    }
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 256, 0);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    int tag = textField.tag;
    if (tag == 12) {
        suburbTextField.text = @"";
        addressLine1TextField.text = @"";
        addressLine2TextField.text = @"";
    }
    else if (tag == 13) {
        addressLine1TextField.text = @"";
        addressLine2TextField.text = @"";
    }
    else if (tag == 14) {
        addressLine2TextField.text = @"";
    }
    
    if (tag == 12 || tag == 13 || tag == 14 || tag == 15) {
        [self getGeoCodeFromAddress];
    }
    
    return YES;
}



#pragma mark - PickerView data source

//Columns in picker views

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}
//Rows in each Column

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    NSLog(@"count: %lu", (unsigned long)[pickerData count]);
    return [pickerData count];
}


#pragma mark - picker view delegate

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"object at index: %ld is %@", (long)row, [pickerData objectAtIndex:row]);
    return [pickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    //Write the required logic here that should happen after you select a row in Picker View.
    
    NSLog(@"index selected: %ld", (long)row);
    countryTextField.text = [pickerData objectAtIndex:row];
    pickerDataSelectedIndex = row;
}

#pragma mark - Geolocation and reverse geocodes using google places API

-(void)getAddressFromGeoCode: (CLLocationCoordinate2D)location{
    
    NSString *url = @"https://maps.googleapis.com/maps/api/geocode/json";
    NSString *latLng = [NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude];
    
    NSDictionary *parameters = @{@"latlng":latLng, @"key":GOOGLE_BROWSER_API_KEY};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response from google Reverse Geocoding JSON: %@", responseObject);
        NSDictionary *responseDict = responseObject;
        //        NSLog(@"response dict: %@", responseDict);
        
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            NSArray *addressComponents = [[[responseDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"];
            
            NSLog(@" addressComponents : %@", addressComponents);
            
            NSString *country = @"";
            stateTextField.text = @"";
            addressLine1TextField.text = @"";
            addressLine2TextField.text = @"";
            suburbTextField.text = @"";
            
            for (int i =0 ; i<addressComponents.count; i++) {
                NSDictionary *address = [addressComponents objectAtIndex:i];
                if ([[[address objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"country"]) {
                    country = [address objectForKey:@"long_name"];
                }
                
                if ([[[address objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_1"]) {
                    stateTextField.text = [address objectForKey:@"long_name"];
                }
                
                if ([[[address objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_2"]) {
                    addressLine1TextField.text = [address objectForKey:@"long_name"];
                }
                
                if ([[[address objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"locality"]) {
                    suburbTextField.text = [address objectForKey:@"long_name"];
                }
                if ([[[address objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"route"]) {
                    addressLine2TextField.text = [address objectForKey:@"long_name"];
                }
            }
            
            
            NSInteger index = [pickerData indexOfObject:country];
            if (index != NSNotFound) {
                NSLog(@"index: %d", index);
                countryTextField.text = country;
                pickerDataSelectedIndex = index;
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        }else{
            [DELEGATE showAlertViewWithTitle:@"error" withMessage:@"There is an error while obtaining address from geo location"];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error from google Reverse Geocoding --------- : %@", error);
        [DELEGATE showAlertViewWithTitle:@"Error" withMessage:@"Unknown error occurred while trying to get addresses"];
    }];
    
}

-(void)getGeoCodeFromAddress{
    
    NSString *address = [NSString stringWithFormat:@"%@+%@+%@+%@+%@",
                         addressLine1TextField.text,
                         addressLine2TextField.text,
                         suburbTextField.text,
                         stateTextField.text,
                         countryTextField.text];
    
    
    NSString *url = @"https://maps.googleapis.com/maps/api/geocode/json";
    NSDictionary *parameters = @{@"address":address, @"key":GOOGLE_BROWSER_API_KEY};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response from google geocode JSON: %@", responseObject);
        NSDictionary *responseDict = responseObject;
        NSLog(@"response dict: %@", responseDict);
        if ([[responseDict objectForKey:@"status"] isEqualToString:@"OK"]) {
            
            NSDictionary *latLng = [[[[responseDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
            
            NSLog(@" latLng : %@", latLng);
            
            float lat = [[latLng objectForKey:@"lat"] floatValue];
            float lng = [[latLng objectForKey:@"lng"] floatValue];
            
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);
            customAnnotation.coordinate =coord;
            
            [self.mapView removeAnnotations:mapView.annotations];
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 1800, 1800);
            [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
            [self.mapView addAnnotation:customAnnotation];
            
            
        }else{
            [DELEGATE showAlertViewWithTitle:@"error" withMessage:@"There is an error while obtaining geo location from the given address"];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error from google geocode --------- : %@", error);
        [DELEGATE showAlertViewWithTitle:@"Error" withMessage:@"Unknown error occurred while trying to get geo location"];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    
    
    
    
    
    // alternatively following code is used to get address from geo code from apple.
    // apple only allows 1 request per minute for this
    
    /*
     
     NSString *address = [NSString stringWithFormat:@"%@, %@, %@, %@, %@",
     addressLine1TextField.text,
     addressLine2TextField.text,
     suburbTextField.text,
     stateTextField.text,
     countryTextField.text];
     
     CLGeocoder *geocoder = [[CLGeocoder alloc] init];
     [geocoder geocodeAddressString:address
     completionHandler:^(NSArray* placemarks, NSError* error){
     if (!error) {
     for (CLPlacemark* aPlacemark in placemarks)
     {
     // Process the placemark.
     NSLog(@"place marks latitude: %f and longitude: %f", aPlacemark.location.coordinate.latitude, aPlacemark.location.coordinate.longitude);
     CLLocation *locationFromAddress = aPlacemark.location;
     
     PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:locationFromAddress.coordinate.latitude longitude:locationFromAddress.coordinate.longitude];
     
     businessLocation[FIELD_BUSINESSLOCATION_LOCATION_POINT] = point;
     
     break; // taking only first result from geocoder
     }
     [self saveBusinessInfoAndCloseModal];
     }
     else{
     NSLog(@"there is an error while requesting geocoder: %@", error);
     
     [DELEGATE showAlertViewWithTitle:@"Error" withMessage:@"There is an error obtaining geolocation data from the address you have input, plase check your address lines"];
     
     }
     
     }];
     */
}


-(void)saveBusinessInfoAndCloseModal{
    
    continueButton.enabled = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [business saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        continueButton.enabled = YES;
        
        if (!error) {
            NSLog(@"saved... move from here");
            
            // user has not added business information yet
            [DEFAULTS setBool:YES forKey:@"ifDealerHasBusiness"];
            [DEFAULTS synchronize];
            
            [businessLocation saveEventually];
            
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
            // Get the storyboard named secondStoryBoard from the main bundle:
            UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Tabs" bundle:nil];
            
            // Load the initial view controller from the storyboard.
            // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
            UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
            
            [self.navigationController pushViewController:theInitialViewController animated:YES];
            
            
        }else{
            NSLog(@"there are some errors, handle it... Error: %@", [error localizedDescription]);
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:[error localizedDescription]];
        }
    }];
    
}



#pragma mark - annotation

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
    } else {
        pin.annotation = annotation;
    }
    pin.animatesDrop = YES;
    pin.draggable = YES;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        [self getAddressFromGeoCode:droppedAt];
        
    }
}

#pragma mark - GPS button click

- (IBAction)didPressGPSButton:(id)sender {
    
    NSLog(@"all annotations: %@", self.mapView.annotations);
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    CLLocation *currentLocation = DELEGATE.locationManager.location;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1800, 1800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    
    customAnnotation.coordinate = currentLocation.coordinate;
    
    [self.mapView addAnnotation:customAnnotation];
    
    [self getAddressFromGeoCode:currentLocation.coordinate];
    
    
}

@end

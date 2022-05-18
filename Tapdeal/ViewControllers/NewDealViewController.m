//
//  NewDealViewController.m
//  Tapdeal
//
//  Created by Neetin on 7/10/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "NewDealViewController.h"
#import <Parse/Parse.h>
#import "SharedStore.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <ActionSheetStringPicker.h>
#import <ActionSheetDatePicker.h>
#import "UITextField+Custom.h"
#import "UIButton+Custom.h"
#import "UIImage+Custom.h"
#import "UITextView+Custom.h"
#import "UILabel+Custom.h"

#import "AppDelegate.h"

#import "Deal.h"

#import "DealPreviewViewController.h"
#import "ParseOperations.h"

@interface NewDealViewController ()
// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *selectCategoryButton;
@property (weak, nonatomic) IBOutlet UITextField *itemTextField;
@property (weak, nonatomic) IBOutlet UITextField *originalPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *dealPriceTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;
@property (weak, nonatomic) IBOutlet UIButton *validFromDateButton;
@property (weak, nonatomic) IBOutlet UIButton *validUntilDateButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;



// IBActions
- (IBAction)didPressCancelButton:(id)sender;
- (IBAction)didPressSelectCategoryButton:(id)sender;
- (IBAction)didPressValidFrombutton:(id)sender;
- (IBAction)didPressValidUntilButton:(id)sender;
- (IBAction)didPressChooseImageButton:(id)sender;
- (IBAction)didPressPreviewButton:(id)sender;


// properties

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImage *itemImage;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *captureCancelButton;

// picker view for category
@property(nonatomic, strong) NSArray *pickerData;
@property(assign) NSInteger pickerDataSelectedIndex;
@property(nonatomic, strong) UIPickerView *pickerView;
@property(nonatomic, strong) UIActionSheet *pickerViewActionSheet;


// actinsheet for Valid From date picker
@property (nonatomic, strong) UIActionSheet *validFromDatePickerActionSheet;
@property (nonatomic, strong) UIDatePicker *validFromDatePicker;
@property (nonatomic, strong) NSDate *validFromDate;

// actinsheet for Valid To date picker
@property (nonatomic, strong) UIActionSheet *validToDatePickerActionSheet;
@property (nonatomic, strong) UIDatePicker *validToDatePicker;
@property (nonatomic, strong) NSDate *validToDate;

@property (nonatomic, strong) NSMutableArray *allCategories;
@property(nonatomic) BOOL isCategorySelected;


@end

@implementation NewDealViewController

@synthesize cancelButton, selectCategoryButton, itemTextField, originalPriceTextField;

@synthesize dealPriceTextField, descriptionTextView, tagsTextField, validFromDateButton;

@synthesize validUntilDateButton, chooseImageButton, previewButton, scrollView;

@synthesize actionSheet, itemImage, imagePickerController;

@synthesize overlayView, captureButton, captureCancelButton;

@synthesize pickerViewActionSheet, pickerView, pickerData, pickerDataSelectedIndex;

@synthesize allCategories, isCategorySelected;

@synthesize validFromDatePicker, validFromDatePickerActionSheet, validFromDate;

@synthesize validToDatePicker, validToDatePickerActionSheet, validToDate;

@synthesize navBarTitleLabel, deal, previewDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    allCategories = [[NSMutableArray alloc] init];
    pickerDataSelectedIndex = 0;
    isCategorySelected = NO;
    
    ParseOperations *operations = [ParseOperations sharedInstance];
    allCategories = operations.dealCategories;
    NSLog(@"categories on new deal: %@", allCategories);
    
    [self customizeView];
    
//    [scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self resetScrollView];
    [self prepareOverlayView];
    
    if (deal) {
        [navBarTitleLabel setText:@"Editing a deal"];
        [self populateDealData];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* the following method is used to override the sub views autolayout constraints,
 * to make scroll view scrollable, we need to use this method
 */

- (void)viewDidLayoutSubviews {
    [scrollView setContentSize:(CGSizeMake(320, 500))];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"previewButton"]) {
        
        if (deal == nil) {
            deal = [PFObject objectWithClassName:PARSE_CLASS_DEAL];
        }
        
        
        deal[FIELD_DEAL_ITEM_NAME] = itemTextField.text;
        deal[FIELD_DEAL_ITEM_DESCRIPTION] = descriptionTextView.text;
        deal[FIELD_DEAL_ORIGINAL_PRICE] = [NSNumber numberWithFloat:[originalPriceTextField.text floatValue]];
        deal[FIELD_DEAL_DEAL_PRICE] = [NSNumber numberWithFloat:[dealPriceTextField.text floatValue]];
        deal[FIELD_DEAL_ITEM_TAG] = tagsTextField.text;
        deal[FIELD_DEAL_VALID_FROM] = validFromDate;
        deal[FIELD_DEAL_VALID_TO] = validToDate;
        deal[FIELD_DEAL_ITEM_CATEGORY] = [allCategories objectAtIndex:pickerDataSelectedIndex];
              
        NSLog(@"for preview button segue... new deal : %@", deal);
        
        DealPreviewViewController *dpvc = (DealPreviewViewController *)[segue destinationViewController];
        [dpvc setDeal:deal];
        [dpvc setDealImage:itemImage];
        dpvc.delegate = previewDelegate;

    }
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
        
    if ([identifier isEqualToString:@"previewButton"]) {
        // set deal items
        return [self formValidation];
    }
    
    return YES;
}

#pragma mark - custom methods

-(void)populateDealData{
    NSLog(@"deal data: %@", deal);
    //sagar sagar
    [itemTextField setText:deal[FIELD_DEAL_ITEM_NAME]];
    
    NSString *dealOriginalPrice = [NSString stringWithFormat:@"%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    
    [originalPriceTextField setText:dealOriginalPrice];
    
    NSString *dealPrice = [NSString stringWithFormat:@"%@", deal[FIELD_DEAL_DEAL_PRICE]];
    
    [dealPriceTextField setText:dealPrice];
    [descriptionTextView setText:deal[FIELD_DEAL_ITEM_DESCRIPTION]];
    [tagsTextField setText:deal[FIELD_DEAL_ITEM_TAG]];
    
    
    PFFile *imageFile = deal[FIELD_DEAL_IMAGE_FILE];
    itemImage = [UIImage imageWithData:[imageFile getData]];
    
    [chooseImageButton setTitle:@"change Image" forState:UIControlStateNormal];
    
    PFObject *singleCategory = deal[FIELD_DEAL_ITEM_CATEGORY];
    
    for (int i = 0; i < [allCategories count]; i++) {
        PFObject *cat = [allCategories objectAtIndex:i];
        if ([cat.objectId isEqualToString:singleCategory.objectId]) {
            pickerDataSelectedIndex = i;
            [selectCategoryButton setTitle:cat[FIELD_CATEGORY_NAME]  forState:UIControlStateNormal];
            isCategorySelected = YES;
        }
    }
    validFromDate=deal[FIELD_DEAL_VALID_FROM];
    validToDate=deal[FIELD_DEAL_VALID_TO];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];

    [validFromDateButton setTitle:[dateFormatter stringFromDate:deal[FIELD_DEAL_VALID_FROM] ] forState:UIControlStateNormal];
    [validUntilDateButton setTitle:[dateFormatter stringFromDate:deal[FIELD_DEAL_VALID_TO] ] forState:UIControlStateNormal];

}


-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self resignFirstResponderFromAllTextField];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   [self resignFirstResponderFromAllTextField];
    
}

-(void)customizeView{
    // setting theme for textfields
    [itemTextField setTheme];
    [originalPriceTextField setTheme];
    [dealPriceTextField setTheme];
    [descriptionTextView setTheme];
    [tagsTextField setTheme];
    
    [navBarTitleLabel setNavBarFont];
    [selectCategoryButton setCustomFont];
    [validFromDateButton setCustomFont];
    [validUntilDateButton setCustomFont];
    [chooseImageButton setCustomFont];
    [previewButton setCustomFont];
    [cancelButton setCustomFont];

}


-(void)resignFirstResponderFromAllTextField{
    [itemTextField resignFirstResponder];
    [originalPriceTextField resignFirstResponder];
    [dealPriceTextField resignFirstResponder];
    [descriptionTextView resignFirstResponder];
    [tagsTextField resignFirstResponder];
    
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void)resetScrollView{
    scrollView.delegate = self;
    scrollView.scrollEnabled = YES;
    [scrollView setContentSize:(CGSizeMake(320, 500))];
    
    NSLog(@"scroll view content size height: %f", scrollView.contentSize.height);
    CGRect frame = self.scrollView.frame;
    
    frame.size = CGSizeMake(320, ScreenSize.height - 64);
    
    [scrollView setFrame:frame];
    NSLog(@"scroll view height: %f", scrollView.frame.size.height);
}


#pragma mark - Camera Capture methods

// this view is for camera overlay view.
-(void)prepareOverlayView{
    
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width, ScreenSize.height)];
    //    [overlayView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
    
    // center box
    
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenSize.height/2 - 110, 320, 200)];
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


#pragma mark - IBActions

- (IBAction)didPressCancelButton:(id)sender {
    [self resignFirstResponderFromAllTextField];
    imagePickerController.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressSelectCategoryButton:(id)sender {
    [self resignFirstResponderFromAllTextField];
    
//    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
//    pickerView.showsSelectionIndicator = YES;
//    pickerView.delegate = self;
//    [pickerView selectRow:pickerDataSelectedIndex inComponent:0 animated:NO];
//    
//    [selectCategoryButton setTitle:[allCategories objectAtIndex:pickerDataSelectedIndex][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
//    
//    pickerViewActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Category"
//                                                        delegate:nil
//                                               cancelButtonTitle:nil
//                                          destructiveButtonTitle:nil
//                                               otherButtonTitles:nil];
//    [pickerViewActionSheet setBackgroundColor:[UIColor whiteColor]];
//    
//    pickerViewActionSheet.tag = 1;
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
    NSMutableArray *categoryNames=[[NSMutableArray alloc]init];
    for (id category in allCategories) {
       
        NSString *name=[category valueForKey:FIELD_CATEGORY_NAME];
        [categoryNames addObject:name];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select Catagory"
                                            rows:categoryNames 
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex1, id selectedValue1) {
                                           NSLog(@"Picker: %@", picker);
                                           NSLog(@"Selected Index: %ld", (long)selectedIndex1);
                                           isCategorySelected = YES;

                                           [selectCategoryButton setTitle:[allCategories objectAtIndex:selectedIndex1][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
                                           pickerDataSelectedIndex = selectedIndex1;                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

- (IBAction)didPressValidFrombutton:(id)sender {
    [self resignFirstResponderFromAllTextField];
    NSDate *currentDate = [NSDate date];
   ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:currentDate target:self action:@selector(dateWasSelected:element:) origin:sender];
//    [actionSheetPicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
//    [actionSheetPicker addCustomButtonWithTitle:@"Yesterday" value:[[NSDate date] TC_dateByAddingCalendarUnits:NSDayCalendarUnit amount:-1]];
//    actionSheetPicker.hideCancel = YES;
    [actionSheetPicker showActionSheetPicker];

//    validFromDatePicker = [[UIDatePicker alloc] init];
//    validFromDatePicker.frame = CGRectMake(0, 40, ScreenSize.width, 180.0f); // set frame as your need
//    validFromDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
////    [validFromDatePicker addTarget:self action:@selector(validFromDateChanged:) forControlEvents:UIControlEventValueChanged];
//    
//    [validFromDatePicker setMinimumDate:[NSDate date]];
//    
//    if (validFromDate) {
//        [validFromDatePicker setDate:validFromDate];
//    }
//    
//    // adding actionsheet
//    validFromDatePickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick a Deal Starting Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
//    [validFromDatePickerActionSheet setBackgroundColor:[UIColor whiteColor]];
//    [validFromDatePickerActionSheet addSubview:validFromDatePicker];
//    
//    UIButton *validDatePickerDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [validDatePickerDoneButton setThemeWithTitleText:@"Done" withFrame:CGRectMake(250, 6 , 62, 30)];
//    
//    
//    validFromDatePickerActionSheet.tag = 2;
//    [validDatePickerDoneButton addTarget:self action:@selector(validFromDatePickerDoneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [validFromDatePickerActionSheet addSubview:validDatePickerDoneButton];
//    
//    [validFromDatePickerActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
//    [validFromDatePickerActionSheet setBounds:CGRectMake(0, 0, 320, ScreenSize.height)];

}

-(void)dateWasSelected:(NSDate *)selectedTime element:(id)element
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    if (element==(UIButton *)[self.view viewWithTag:99]) {
        validFromDate=selectedTime;
    }
    else
        validToDate=selectedTime;
    [element setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal ];
}

- (IBAction)didPressValidUntilButton:(id)sender {
    [self resignFirstResponderFromAllTextField];
    NSDate *validUntilDate = [NSDate date];
    ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:validUntilDate target:self action:@selector(dateWasSelected:element:) origin:sender];
//    [actionSheetPicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
    //    [actionSheetPicker addCustomButtonWithTitle:@"Yesterday" value:[[NSDate date] TC_dateByAddingCalendarUnits:NSDayCalendarUnit amount:-1]];
//    actionSheetPicker.hideCancel = YES;
    [actionSheetPicker showActionSheetPicker];

    
//    validToDatePicker = [[UIDatePicker alloc] init];
//    validToDatePicker.frame = CGRectMake(0, 40, ScreenSize.width, 180.0f); // set frame as your need
//    validToDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
//    //    [validFromDatePicker addTarget:self action:@selector(validFromDateChanged:) forControlEvents:UIControlEventValueChanged];
//    
//    [validToDatePicker setMinimumDate: [NSDate date]];
//    if (validToDate) {
//        [validToDatePicker setDate:validToDate];
//    }
//    
//    // adding actionsheet
//    validToDatePickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick a Deal Ending Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
//    [validToDatePickerActionSheet setBackgroundColor:[UIColor whiteColor]];
//    [validToDatePickerActionSheet addSubview:validToDatePicker];
//    
//    UIButton *validDatePickerDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [validDatePickerDoneButton setThemeWithTitleText:@"Done" withFrame:CGRectMake(250, 6 , 62, 30)];
//    
//    
//    validToDatePickerActionSheet.tag = 3;
//    [validDatePickerDoneButton addTarget:self action:@selector(validToDatePickerDoneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [validToDatePickerActionSheet addSubview:validDatePickerDoneButton];
//    
//    [validToDatePickerActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
//    [validToDatePickerActionSheet setBounds:CGRectMake(0, 0, 320, ScreenSize.height)];
//    

    
}

- (IBAction)didPressChooseImageButton:(id)sender {
    
    [self resignFirstResponderFromAllTextField];
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick an Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Image from Library", @"Capture from Camera", nil];
    [actionSheet showInView:self.view];
}


-(BOOL)formValidation{
    
    if (!isCategorySelected) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item category is required"];
        return NO;
    }
    
    else if ([itemTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item name is required"];
        return NO;
    }
    else if (![itemTextField checkLimitCharacter:50]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item name should not exceed 50 characters in length"];
        return NO;
    }
    else if ([descriptionTextView isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item description is required"];
        return NO;
    }
    else if (![descriptionTextView checkLimitCharacter:250]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item description should not exceed 250 characters in length"];
        return NO;
    }
    else if ([originalPriceTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item original price is required"];
        return NO;
    }
    else if (![originalPriceTextField isNumber]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item original price should be in number"];
        return NO;
    }
    else if (![originalPriceTextField checkLimitCharacter:12]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item original price should not exceed 12 digits in length"];
        return NO;
    }

    else if ([dealPriceTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item deal price is required"];
        return NO;
    }
    else if (![dealPriceTextField isNumber]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item deal price should be in number"];
        return NO;
    }
    else if (![dealPriceTextField checkLimitCharacter:12]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item deal price should not exceed 12 digits in length"];
        return NO;
    }
    else if ([tagsTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item tags are required"];
        return NO;
    }
    else if (![tagsTextField checkLimitCharacter:250]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item tags should not exceed 250 characters in length"];
        return NO;
    }
    else if (!validFromDate) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item starting date is required"];
        return NO;
    }
    else if (!validToDate) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item ending date is required"];
        return NO;
    }
    
    // compare valid from and valid to date
    else if([validFromDate compare:validToDate] == NSOrderedDescending || [validFromDate compare:validToDate] == NSOrderedSame){
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Deal starting date should be earlier than the deal ending date"];
        return NO;
    }

    else if (!itemImage) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Item image is required"];
        return NO;
    }
    
    
    
    
    return YES;
}

- (IBAction)didPressPreviewButton:(id)sender {
    
    /*
     * validation check and navigation has been done on shouldPerformSegueWithIdentifier method
     */
   
}


-(void) validFromDatePickerDoneButtonClicked: (id) sender{
    NSLog(@"valid from date action picker done button clicked");
    [validFromDatePickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy, hh:mm a"];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *currentTime = [dateFormatter stringFromDate:validFromDatePicker.date];
    NSLog(@"From date picker: %@", currentTime);
    
    validFromDate = validFromDatePicker.date;
    [validFromDateButton setTitle:currentTime forState:UIControlStateNormal];

}

-(void) validToDatePickerDoneButtonClicked: (id) sender{
    NSLog(@"valid To date action picker done button clicked");
    [validToDatePickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy, hh:mm a"];    
    NSString *currentTime = [dateFormatter stringFromDate:validToDatePicker.date];
    NSLog(@"To date picker: %@", currentTime);
    
    validToDate = validToDatePicker.date;
    [validUntilDateButton setTitle:currentTime forState:UIControlStateNormal];
    
}


#pragma mark - PickerView data source

//Columns in picker views

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}
//Rows in each Column

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    NSLog(@"count: %lu", (unsigned long)[allCategories count]);
    return [allCategories count];
}

-(void) doneButtonClicked: (id) sender{
    NSLog(@"action picker done button clicked");
    [pickerViewActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    isCategorySelected = YES;
}


#pragma mark - Actionsheet delegate

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"did dismiss with button at index: %ld", (long)buttonIndex);
    
    if (!(actionSheet.tag == 1 || actionSheet.tag == 2 || actionSheet.tag == 3)) {
        if (buttonIndex == 1) {
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
                [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            }
        }
        else if (buttonIndex == 0){
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
    
}

#pragma mark - picker view delegate

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"object at index: %ld is %@", (long)row, [allCategories objectAtIndex:row][FIELD_CATEGORY_NAME]);
    return [allCategories objectAtIndex:row][FIELD_CATEGORY_NAME];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    //Write the required logic here that should happen after you select a row in Picker View.
    
    NSLog(@"index selected: %ld", (long)row);
    [selectCategoryButton setTitle:[allCategories objectAtIndex:row][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
    pickerDataSelectedIndex = row;
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
//sagar image from libary directly uploaded
// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *capturedImage= [info valueForKey:UIImagePickerControllerOriginalImage];
    
    NSLog(@"image info: %@", info);
    
    // scaling and cropping image
//    itemImage = [capturedImage scaleAndCropWithSize:CGSizeMake(400, 400)];
    itemImage = capturedImage; // not cropping, cropping can be done on preview screen;
    
   NSLog(@"MyImage size in bytes:%i",[UIImagePNGRepresentation(capturedImage) length]);
    [chooseImageButton setTitle:@"image picked" forState:UIControlStateNormal];
    [chooseImageButton setOpaque:NO];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"user cancelled image picker ...");
    [self dismissViewControllerAnimated:YES completion:NULL];
}




#pragma mark - text field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 256, 0);
}

@end

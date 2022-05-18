//
//  ConsumerWelcomeScreenViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/8/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "ConsumerWelcomeScreenViewController.h"
#import <Parse/Parse.h>
#import "SharedStore.h"
#import "UIButton+Custom.h"
#import "UITextField+Custom.h"
#import "UILabel+Custom.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"

@interface ConsumerWelcomeScreenViewController ()

@property (nonatomic, strong) NSMutableArray *allCategories;

// picker view
@property(assign) NSInteger pickerDataSelectedIndex;
@property(nonatomic, strong) UIPickerView *pickerView;
@property(nonatomic, strong) UIActionSheet *pickerViewActionSheet;

@property (nonatomic) BOOL isCategorySelected;

@end

@implementation ConsumerWelcomeScreenViewController

@synthesize allCategories, isCategorySelected;
@synthesize pickerDataSelectedIndex, pickerView, pickerViewActionSheet;

@synthesize selectCategeoryButton, submitButton, viewAllDealsButton, searchTextField;
@synthesize navBarTitleLabel, whereToLabel;


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
    // Do any additional setup after loading the view.
    selectCategeoryButton.enabled = NO; // initially disabled, renabled after fetchig  category list
    
    allCategories = [[NSMutableArray alloc] init];
    pickerDataSelectedIndex = 0;
    isCategorySelected = NO;
    

    [self customizeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}



#pragma  mark - custom methods

-(void)customizeView{
    [searchTextField setTheme];
    
    [selectCategeoryButton setCustomFont];
    [navBarTitleLabel setNavBarFont];
    [viewAllDealsButton setCustomFont];
    [whereToLabel setNormalFont];
    
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
    [selectCategeoryButton setTitle:[allCategories objectAtIndex:row][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
    pickerDataSelectedIndex = row;
    isCategorySelected = YES;
}


#pragma mark - IBActions

- (IBAction)didPressCategoryButton:(id)sender {
    [searchTextField resignFirstResponder];
    
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    [pickerView selectRow:pickerDataSelectedIndex inComponent:0 animated:NO];
    
    [selectCategeoryButton setTitle:[allCategories objectAtIndex:pickerDataSelectedIndex][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
    
    pickerViewActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Category"
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [pickerViewActionSheet setBackgroundColor:[UIColor whiteColor]];
    
    [pickerViewActionSheet addSubview:pickerView];
    
    UIButton *pickerDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pickerDoneButton setThemeWithTitleText:@"Done" withFrame:CGRectMake(250, 6 , 62, 30)];
    
    
    [pickerDoneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [pickerViewActionSheet addSubview:pickerDoneButton];
    
    [pickerViewActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [pickerViewActionSheet setBounds:CGRectMake(0, 0, 320, 495)];

}

- (IBAction)didPressSubmitButton:(id)sender {
    
    
    NSNumber *categoryIndex = [NSNumber numberWithInt:-1];
    
    if (isCategorySelected) {
        categoryIndex =[NSNumber numberWithInteger:pickerDataSelectedIndex];
    }
    NSDictionary *options = @{@"categoryIndex": categoryIndex, @"searchKeyword": searchTextField.text};
    
    
    DELEGATE.searchDictionary = options;
    
    
    // Get the storyboard named secondStoryBoard from the main bundle:
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Tabs" bundle:nil];
    
    // Load the initial view controller from the storyboard.
    // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
    UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
    
    [self.navigationController pushViewController:theInitialViewController animated:YES];
    
    
}

- (IBAction)didPressViewAllDeals:(id)sender {
    
    // Get the storyboard named secondStoryBoard from the main bundle:
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Tabs" bundle:nil];
    
    // Load the initial view controller from the storyboard.
    // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
    UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
    
    [self.navigationController pushViewController:theInitialViewController animated:YES];
    
    //
    // **OR**
    //
    // Load the view controller with the identifier string mySecondTab
    // Change UIViewController to the appropriate class
    /*
     UIViewController *theTabBar = (UIViewController *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"mySecondTab"];
     
     // Then push the new view controller in the usual way:
     [self.navigationController pushViewController:theTabBar animated:YES];
     
     */

}


#pragma mark - UITextField delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end

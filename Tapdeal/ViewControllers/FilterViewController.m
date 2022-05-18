//
//  FilterViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/21/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "FilterViewController.h"

#import "UILabel+Custom.h"
#import "UIButton+Custom.h"
#import "UITextField+Custom.h"

#import "SharedStore.h"
#import "AppDelegate.h"

#import "ParseOperations.h"

@interface FilterViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

// properties
// picker view
@property (assign) NSInteger pickerDataSelectedIndexForCategory;

@property (assign) NSInteger pickerDataSelectedIndexForSortRateOption;
@property (assign) NSInteger pickerDataSelectedIndexForSortPriceOption;


@property (nonatomic, strong) UIActionSheet *pickerViewActionSheet;

@property (nonatomic, strong) NSNumber *searchWithinDistance;
@property (nonatomic, strong) NSMutableArray *dealCategories;
@property (nonatomic, strong) ParseOperations *parseOperations;

@property (nonatomic, assign) BOOL isKmButtonSelected;


// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *chooseCategoryButton;
@property (weak, nonatomic) IBOutlet UILabel *bodyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchWithinLabel;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *sortByRateButton;

@property (weak, nonatomic) IBOutlet UIButton *sortByPriceButton;

@property (weak, nonatomic) IBOutlet UITextField *searchKeywordTextField;

@property (nonatomic, strong) NSArray *sortRateOptions;
@property (nonatomic, strong) NSArray *sortPriceOptions;


@property (weak, nonatomic) IBOutlet UIButton *kmButton;
@property (weak, nonatomic) IBOutlet UIButton *mileButton;


// IBActions
- (IBAction)didPressChooseCategoryButton:(id)sender;
- (IBAction)didChangeSliderValue:(id)sender;
- (IBAction)didPressSearchButton:(id)sender;
- (IBAction)didPressSortByRateButton:(id)sender;
- (IBAction)didPressSortByPriceButton:(id)sender;


- (IBAction)didPressKmMileButton:(id)sender;



@end

@implementation FilterViewController

@synthesize  pickerDataSelectedIndexForCategory, pickerViewActionSheet;

@synthesize chooseCategoryButton, bodyTitleLabel, searchWithinLabel, distanceSlider;
@synthesize searchButton;

@synthesize dealCategories, parseOperations, sortByRateButton, sortRateOptions;
@synthesize sortPriceOptions, sortByPriceButton, searchKeywordTextField;

@synthesize searchWithinDistance;
@synthesize pickerDataSelectedIndexForSortPriceOption, pickerDataSelectedIndexForSortRateOption;

@synthesize delegate, isSliderHidden;

@synthesize isKmButtonSelected, kmButton, mileButton;

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
    
    // parse operation
    parseOperations = [ParseOperations sharedInstance];
    
    dealCategories = [NSMutableArray new];
    
    NSString *anyCategory = [NSString stringWithFormat: @"Any Category"];
    
    [dealCategories addObject:anyCategory];
    
    pickerViewActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [pickerViewActionSheet setBackgroundColor:[UIColor whiteColor]];

    
    sortRateOptions = [[SharedStore store] getSortByRateItems];
    sortPriceOptions = [[SharedStore store] getSortByPriceItems];
    
    // by default search distance is 5
    searchWithinLabel.text = @"Search within 5 km";
    [distanceSlider setValue:0.05f];
    searchWithinDistance = [NSNumber numberWithInt:5];
    
    pickerDataSelectedIndexForCategory = 0;
    pickerDataSelectedIndexForSortRateOption = 0;
    pickerDataSelectedIndexForSortPriceOption = 0;

    [self customizeView];
    [dealCategories addObjectsFromArray: parseOperations.dealCategories];
    
    NSLog(@"all categories: %@", dealCategories);
    
    
    
    // add gesture to resign first responder of search bar
    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] init];
    [tapOnView addTarget:self action:@selector(tappedOnView) ];
    [self.view addGestureRecognizer:tapOnView];

    [self fetchSavedSearchOptions];
    
}

-(void)tappedOnView{
    [searchKeywordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [dealCategories removeAllObjects];
    
//    [delegate doSearch];
}

#pragma mark - custom methods

-(void) customizeView{
    [chooseCategoryButton setCustomFont];
    [searchButton setCustomFont];
    [sortByRateButton setCustomFont];
    [sortByPriceButton setCustomFont];
    
    [bodyTitleLabel setNormalBoldFont];
    [searchWithinLabel setNormalFont];
    [searchKeywordTextField setTheme];
    searchKeywordTextField.delegate = self;
    
    if (isSliderHidden) {
        searchWithinLabel.hidden = YES;
        distanceSlider.hidden = YES;
        
        kmButton.hidden = YES;
        mileButton.hidden = YES;
        
        // move search button to up
        CGRect frame = CGRectMake(16, 210, 260, 34);
        [searchButton setFrame:frame];
        
    }else{
        searchWithinLabel.hidden = NO;
        distanceSlider.hidden = NO;
        
        kmButton.hidden = NO;
        mileButton.hidden = NO;
        
        CGRect frame = CGRectMake(16, 303, 260, 34);
        [searchButton setFrame:frame];
    }
    
}

-(void)fetchSavedSearchOptions{
    //sagar search keyword remove after search
    searchKeywordTextField.text = parseOperations.searchKeyword;
    
    if ([parseOperations.searchCategoryIndex intValue] >= 0) {
        pickerDataSelectedIndexForCategory = [parseOperations.searchCategoryIndex integerValue];
        if ([parseOperations.searchCategoryIndex intValue] == 0) {
            [chooseCategoryButton setTitle:[dealCategories objectAtIndex:pickerDataSelectedIndexForCategory] forState:UIControlStateNormal];
        }else{
            [chooseCategoryButton setTitle:[dealCategories objectAtIndex:pickerDataSelectedIndexForCategory][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
        }
        
        
    }
    
    if ([parseOperations.sortByRateIndex intValue] >= 0) {
        pickerDataSelectedIndexForSortRateOption = [parseOperations.sortByRateIndex integerValue];
        [sortByRateButton setTitle:[sortRateOptions objectAtIndex:pickerDataSelectedIndexForSortRateOption] forState:UIControlStateNormal];
    }
    if ([parseOperations.sortByPriceIndex intValue] >= 0) {
        pickerDataSelectedIndexForSortPriceOption = [parseOperations.sortByPriceIndex integerValue];
        [sortByPriceButton setTitle:[sortPriceOptions objectAtIndex:pickerDataSelectedIndexForSortPriceOption] forState:UIControlStateNormal];
    }

    
    int searchDistanceVal = [parseOperations.searchDistance intValue];
    
    if (searchDistanceVal <= 100) {
        
        searchWithinDistance = parseOperations.searchDistance;
        
        NSString *txt = @"";
        
        float distanceVal = (float) searchDistanceVal/100;
        distanceSlider.value = distanceVal;
    
        if(parseOperations.isMile){
            isKmButtonSelected = NO;
            
            if (searchDistanceVal <=1) {
                txt = [NSString stringWithFormat:@"Search within 1 mile"];
            }else{
                txt = [NSString stringWithFormat:@"Search within %d miles", searchDistanceVal];
            }
            
            // km button unselected
            [kmButton setBackgroundImage:[UIImage imageNamed:@"kmWhite.png"] forState:UIControlStateNormal];
            [kmButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
            
            // select mile button
            [mileButton setBackgroundImage:[UIImage imageNamed:@"mileBlue.png"] forState:UIControlStateNormal];
            [mileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
        }
        else{
            isKmButtonSelected = YES;
            
            if (searchDistanceVal <=1) {
                txt = [NSString stringWithFormat:@"Search within 1 km"];
            }else{
                txt = [NSString stringWithFormat:@"Search within %d km", searchDistanceVal];
            }
            
            // make km button selected
            [kmButton setBackgroundImage:[UIImage imageNamed:@"kmBlue.png"] forState:UIControlStateNormal];
            [kmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            // unselect mile button
            [mileButton setBackgroundImage:[UIImage imageNamed:@"mileWhite.png"] forState:UIControlStateNormal];
            [mileButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
            
        }
        
         searchWithinLabel.text = txt;
    }
}


#pragma  mark - IBActions


- (IBAction)didPressChooseCategoryButton:(id)sender {
    
    if ([dealCategories count] == 0) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Failed to get the categories list."];
        return;
    }
    
    
    for (UIView * view in [pickerViewActionSheet subviews]) {
        [view removeFromSuperview];
    }
    
    UIPickerView *categoryPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
    categoryPickerView.showsSelectionIndicator = YES;
    categoryPickerView.tag = 1;
    categoryPickerView.delegate = self;
    [categoryPickerView selectRow:pickerDataSelectedIndexForCategory inComponent:0 animated:NO];
   
    
    if (pickerDataSelectedIndexForCategory == 0) {
        [chooseCategoryButton setTitle:[[dealCategories objectAtIndex:pickerDataSelectedIndexForCategory] description] forState:UIControlStateNormal];
    }else{
        [chooseCategoryButton setTitle:[dealCategories objectAtIndex:pickerDataSelectedIndexForCategory][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
    }
    
//    [pickerViewActionSheet setTitle:@"Choose Category"];
//    [pickerViewActionSheet addSubview:categoryPickerView];
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
    for (int i=0;i<dealCategories.count;i++)
    {
        NSString *name;
        if (i == 0)
        {
            name= [[dealCategories objectAtIndex:i] description];
        }
        else{
            name= [dealCategories objectAtIndex:i][FIELD_CATEGORY_NAME];
        }
        [categoryNames addObject:name];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select Catagory"
                                            rows:categoryNames
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex1, id selectedValue1) {
                                           NSLog(@"Picker: %@", picker);
                                           NSLog(@"Selected Index: %ld", (long)selectedIndex1);
                                           
                                           if (selectedIndex1 == 0) {
                                               [chooseCategoryButton setTitle:[[dealCategories objectAtIndex:selectedIndex1] description] forState:UIControlStateNormal];
                                           }else{
                                               
                                               [chooseCategoryButton setTitle:[dealCategories objectAtIndex:selectedIndex1][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
                                           }
                                           pickerDataSelectedIndexForCategory = selectedIndex1;                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
    
}

- (IBAction)didChangeSliderValue:(id)sender {
    UISlider *slider = sender;
    int val = slider.value * 100;
    
    NSString *text = nil;
    
    if (isKmButtonSelected){

        if (val <= 1){
            text = [NSString stringWithFormat:@"Search within 1 km"];
            searchWithinDistance = [NSNumber numberWithInt:1];
        }
        else{
            text = [NSString stringWithFormat:@"Search within %d km", val];
            searchWithinDistance = [NSNumber numberWithInt:val];
        }

    }
    else{
        if (val <= 1){
            text = [NSString stringWithFormat:@"Search within 1 mile"];
            searchWithinDistance = [NSNumber numberWithInt:1];
        }
        else{
            text = [NSString stringWithFormat:@"Search within %d miles", val];
            searchWithinDistance = [NSNumber numberWithInt:val];
        }
    }
    
    
    
    searchWithinLabel.text = text;
    
}

- (IBAction)didPressSearchButton:(id)sender {
    
    NSNumber *categorySelectedIndex = [NSNumber numberWithInteger:pickerDataSelectedIndexForCategory];
    
    NSLog(@"did press search button: cat id: %@, sortBy price id: %d, sort by rate: %ld", categorySelectedIndex, pickerDataSelectedIndexForSortPriceOption, (long)pickerDataSelectedIndexForSortRateOption);
    
    // save search options settings
    parseOperations.searchKeyword = searchKeywordTextField.text;
    parseOperations.searchCategoryIndex = categorySelectedIndex;
    parseOperations.searchDistance = searchWithinDistance;
    parseOperations.sortByRateIndex = [NSNumber numberWithInteger:pickerDataSelectedIndexForSortRateOption];
    parseOperations.sortByPriceIndex = [NSNumber numberWithInteger:pickerDataSelectedIndexForSortPriceOption];
    
    
    if (isKmButtonSelected)
         parseOperations.isMile = NO;
    else
         parseOperations.isMile = YES;
    
    [delegate doSearch];
}

- (IBAction)didPressSortByRateButton:(id)sender{
    
    for (UIView * view in [pickerViewActionSheet subviews]) {
        [view removeFromSuperview];
    }
    
//    UIPickerView *sortByPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
//    sortByPickerView.tag = 2;
//    sortByPickerView.showsSelectionIndicator = YES;
//    sortByPickerView.delegate = self;
//    [sortByPickerView selectRow:pickerDataSelectedIndexForSortRateOption inComponent:0 animated:NO];
//    [sortByRateButton setTitle:[sortRateOptions objectAtIndex:pickerDataSelectedIndexForSortRateOption] forState:UIControlStateNormal];
//    
//    [pickerViewActionSheet addSubview:sortByPickerView];
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
                                            rows:sortRateOptions
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex1, id selectedValue1) {
                                           NSLog(@"Picker: %@", picker);
                                           NSLog(@"Selected Index: %ld", (long)selectedIndex1);
                                           
                                           [sortByRateButton setTitle:[sortRateOptions objectAtIndex:selectedIndex1] forState:UIControlStateNormal];
                                           pickerDataSelectedIndexForSortRateOption = selectedIndex1;                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
    

    
}


- (IBAction)didPressSortByPriceButton:(id)sender {
    for (UIView * view in [pickerViewActionSheet subviews]) {
        [view removeFromSuperview];
    }
    
//    UIPickerView *sortByPricePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
//    sortByPricePickerView.tag = 3;
//    sortByPricePickerView.showsSelectionIndicator = YES;
//    sortByPricePickerView.delegate = self;
//    [sortByPricePickerView selectRow:pickerDataSelectedIndexForSortPriceOption inComponent:0 animated:NO];
//    [sortByPriceButton setTitle:[sortRateOptions objectAtIndex:pickerDataSelectedIndexForSortPriceOption] forState:UIControlStateNormal];
//    
//    [pickerViewActionSheet addSubview:sortByPricePickerView];
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
                                            rows:sortPriceOptions
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex1, id selectedValue1) {
                                           NSLog(@"Picker: %@", picker);
                                           NSLog(@"Selected Index: %ld", (long)selectedIndex1);
                                          
                                           [sortByPriceButton setTitle:[sortPriceOptions objectAtIndex:selectedIndex1] forState:UIControlStateNormal];
                                           pickerDataSelectedIndexForSortPriceOption = selectedIndex1;                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
    

    
}

- (IBAction)didPressKmMileButton:(id)sender {
    
    
    NSString *text = nil;
    int val = distanceSlider.value *100;

    UIButton *button = sender;
    
    if (button.tag == 3) {
        
        // km button pressed
        if(!isKmButtonSelected){
            
            // make km button selected
            [kmButton setBackgroundImage:[UIImage imageNamed:@"kmBlue.png"] forState:UIControlStateNormal];
            [kmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            // unselect mile button
            [mileButton setBackgroundImage:[UIImage imageNamed:@"mileWhite.png"] forState:UIControlStateNormal];
            [mileButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
            
            if (val <= 1) {
                text = [NSString stringWithFormat:@"Search within 1 km"];
                searchWithinDistance = [NSNumber numberWithInt:1];
            }
            else {
                text = [NSString stringWithFormat:@"Search within %d km", val];
                searchWithinDistance = [NSNumber numberWithInt:val];
            }
            
            isKmButtonSelected = !isKmButtonSelected;
            searchWithinLabel.text = text;
        }
    }
    
    if (button.tag == 4) {
        
        // mile button pressed
        if(isKmButtonSelected){
            
            // km button unselected
            [kmButton setBackgroundImage:[UIImage imageNamed:@"kmWhite.png"] forState:UIControlStateNormal];
            [kmButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
            
            // select mile button
            [mileButton setBackgroundImage:[UIImage imageNamed:@"mileBlue.png"] forState:UIControlStateNormal];
            [mileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            
            if (val <= 1) {
                text = [NSString stringWithFormat:@"Search within 1 mile"];
                searchWithinDistance = [NSNumber numberWithInt:1];
            }
            else {
                text = [NSString stringWithFormat:@"Search within %d miles", val];
                searchWithinDistance = [NSNumber numberWithInt:val];
            }
            
            isKmButtonSelected = !isKmButtonSelected;
            searchWithinLabel.text = text;
        }
    }
    
    

}

#pragma mark - PickerView data source

//Columns in picker views

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}
//Rows in each Column

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    
    NSInteger count = 0;
    
    NSLog(@"picker view tag: %ld in count", (long)pickerView.tag);
    
    if (pickerView.tag == 1) {
        NSLog(@"count: %lu", (unsigned long)[dealCategories count]);
        count = [dealCategories count];
    }
    
    if (pickerView.tag == 2) {
        NSLog(@"count: %lu", (unsigned long)[sortRateOptions count]);
        count = [sortRateOptions count];
    }
    
    if (pickerView.tag == 3) {
        NSLog(@"count: %lu", (unsigned long)[sortPriceOptions count]);
        count = [sortPriceOptions count];
    }
    
    return count;
}

-(void) doneButtonClicked: (id) sender{
    NSLog(@"action picker done button clicked");
    [pickerViewActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark - picker view delegate

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
   NSLog(@"picker view tag: %ld in titile", (long)pickerView.tag);
    
    if (pickerView.tag == 1) {
        if (row == 0) {
            return [[dealCategories objectAtIndex:0] description];
        }
        else{
            NSLog(@"object at index: %ld is %@", (long)row, [dealCategories objectAtIndex:row][FIELD_CATEGORY_NAME]);
            return [dealCategories objectAtIndex:row][FIELD_CATEGORY_NAME];
        }
    }
     if (pickerView.tag == 2) {
        
        return [sortRateOptions objectAtIndex:row];
    }
    if (pickerView.tag == 3) {
        
        return [sortPriceOptions objectAtIndex:row];
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    //Write the required logic here that should happen after you select a row in Picker View.
    if (pickerView.tag == 1) {

        NSLog(@"index selected in category: %ld", (long)row);
        if (row == 0) {
            [chooseCategoryButton setTitle:[[dealCategories objectAtIndex:row] description] forState:UIControlStateNormal];
        }else{
            [chooseCategoryButton setTitle:[dealCategories objectAtIndex:row][FIELD_CATEGORY_NAME] forState:UIControlStateNormal];
        }
        pickerDataSelectedIndexForCategory = row;
    }
    
    if (pickerView.tag == 2){
         NSLog(@"index selected in sort by rate: %ld", (long)row);
        [sortByRateButton setTitle:[sortRateOptions objectAtIndex:row] forState:UIControlStateNormal];
        pickerDataSelectedIndexForSortRateOption = row;
    }
    if (pickerView.tag == 3){
        NSLog(@"index selected in sort by price: %ld", (long)row);
        [sortByPriceButton setTitle:[sortPriceOptions objectAtIndex:row] forState:UIControlStateNormal];
        pickerDataSelectedIndexForSortPriceOption = row;
    }
}


#pragma mark - Text field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end

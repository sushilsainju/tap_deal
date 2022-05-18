//
//  BusinessWelcomeScreenViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/3/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "BusinessWelcomeScreenViewController.h"
#import <Parse/Parse.h>
#import "SharedStore.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import "UILabel+Custom.h"
#import "UIButton+Custom.h"


@interface BusinessWelcomeScreenViewController()

// Properties


// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *addBusinessButton;
@property (weak, nonatomic) IBOutlet UIButton *viewDealsButton;

@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyTapdealLabel;



//IBActions
- (IBAction)didPressViewDetailsButton:(id)sender;


@end


@implementation BusinessWelcomeScreenViewController

@synthesize addBusinessButton, viewDealsButton, navBarTitleLabel, bodyTapdealLabel;

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
    
    [self customizeView];
}


-(void)customizeView{
    
    // setting button and label fonts
    [addBusinessButton setCustomFont];
    [viewDealsButton setCustomFont];
    [navBarTitleLabel setNavBarFont];
    [bodyTapdealLabel setNormalFont];
    
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[DEFAULTS valueForKey:@"ifDealerHasBusiness"] boolValue]) {
        [addBusinessButton setTitle:@"Edit Business Details" forState:UIControlStateNormal];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark IBActions

- (IBAction)didPressViewDetailsButton:(id)sender {
    
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
@end

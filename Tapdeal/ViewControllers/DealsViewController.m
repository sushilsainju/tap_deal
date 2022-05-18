//
//  DealsViewController.m
//  Tapdeal
//
//  Created by Neetin on 7/10/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "DealsViewController.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SharedStore.h"
#import "AppDelegate.h"
#import "UILabel+Custom.h"
#import "UITextField+Custom.h"
#import <WYPopoverController/WYPopoverController.h>
#import "FilterViewController.h"

#import "DealDetailsViewController.h"
#import "ParseOperations.h"

@interface DealsViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UISearchBarDelegate, FilterViewDelegate>


#define ViewBorder_color [UIColor colorWithRed:233.0f/255.0f green:164.0f/255.0f blue:85.0f/255.0f alpha:1.0] ;
#define ViewBorder_color1 [UIColor colorWithRed:26.0f/255.0f green:99.0f/255.0f blue:167.0f/255.0f alpha:1.0] ;

// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UITableView *dealTableView;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;

@property (weak, nonatomic) IBOutlet UIView *navBarBackgroundView;

@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *allDealsMyDealsBackgroundView;

@property (weak, nonatomic) IBOutlet UIButton *allDealsButton;
@property (weak, nonatomic) IBOutlet UIButton *myDealsButton;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;


// IBActions
- (IBAction)didPressPlusButton:(id)sender;
- (IBAction)didPressFilterButton:(id)sender;

- (IBAction)didPressAllDealsMyDealsButton:(id)sender;


- (IBAction)didPressRefreshButton:(id)sender;


// properties

@property (nonatomic, strong) CLLocation *location;

/*
 *  deals array is used to show all deals / my deals in table view cell, deals array item is stored on singleton instance of ParseOperation class.
 */
@property (nonatomic, strong) NSArray *deals;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UISearchBar *dealSearchBar;

@property (nonatomic, strong) WYPopoverController *popover;

@property (nonatomic) BOOL isBusinessUser;

@property (nonatomic, strong) NSMutableArray *dealCategories;

@property (nonatomic) NSIndexPath *selectedRowOfDeals;


@property (nonatomic, assign) BOOL isAllDealsButtonSelected;

@property (nonatomic, strong) ParseOperations *parseOperations;

@property (nonatomic, assign) BOOL isFetchFromSearch;

@property (nonatomic, strong) NSString *activeUserObjectId;

@end

@implementation DealsViewController

@synthesize plusButton, dealTableView, location, navBarBackgroundView, navBarTitleLabel;

@synthesize deals, refreshControl, dealSearchBar, filterButton, popover, dealCategories;

@synthesize isBusinessUser, selectedRowOfDeals, activeUserObjectId;

@synthesize allDealsButton, myDealsButton, allDealsMyDealsBackgroundView, isAllDealsButtonSelected;

@synthesize refreshButton, parseOperations, isFetchFromSearch;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        deals = [NSArray new];
        
        
        isBusinessUser = NO;
        isAllDealsButtonSelected = YES;
        dealCategories = [NSMutableArray new];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    dealTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    isAllDealsButtonSelected = YES;
    isFetchFromSearch = NO;
    
    parseOperations = [ParseOperations sharedInstance];
  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDealsFetchNotification:)
                                                 name:@"dealFetchNotification"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDealsFetchNotification:)
                                                 name:@"myDealFetchNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDealsSearchNotification:)
                                                 name:@"dealsSearchNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDealsSearchNotification:)
                                                 name:@"myDealsSearchNotification"
                                               object:nil];

    
    
    // fetch deals on start up
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [parseOperations getAllNearByBusinessesWithNewSearch:YES isLimit:NO isForAllDeal:YES];
    
    /* the following methos will be called inside getAllNearByBusinessesWithNewSearch method */
    
//    [[ParseOperations sharedInstance] startUpFetchDealsInTheBackground:@0 withLimit:DEALS_FETCH_LIMIT];
    
    
    // check if the user is business user or not
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        NSLog(@"No current User found, show login screen on lunch");
        
        // Get the storyboard named secondStoryBoard from the main bundle:
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        // Load the initial view controller from the storyboard.
        // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
        UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
        
        [self presentViewController:theInitialViewController animated:YES completion:nil];
        
        
    }else{
        NSLog(@"there is a user %@", [PFUser currentUser]);
        activeUserObjectId = currentUser.objectId;
        
        if ([currentUser[FIELD_USER_USERTYPE] isEqualToString:USER_TYPE_BUSINESS]) {
            NSLog(@"a business user");
            isBusinessUser = YES;
            // fetch deals on start up
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[ParseOperations sharedInstance] getMyBusinessInfo]; // fetchMyDealsInTheBackgroundWithDealIndex will be called in getMyBusinessInfo success block.
        }
        
        [[ParseOperations sharedInstance] fetchMyFavoriteBusinesses];
    }
      // getting current location
    location = DELEGATE.currentLocation;
    
    if (location.coordinate.latitude != 0 && location.coordinate.longitude != 0) {
        NSLog(@"current location exists! ");
    }
    
    
    NSLog(@"count categories : %lu", (unsigned long)[dealCategories count]);
    
    
    if (parseOperations.dealCategories) {
        if(![parseOperations.dealCategories count]){
            [parseOperations getAllDealCategories];
        }
        else
            dealCategories = parseOperations.dealCategories;
    }else{
        [parseOperations getAllDealCategories];
    }

    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reFetchDeals) forControlEvents:UIControlEventValueChanged];
    [dealTableView addSubview:refreshControl];
    
    /*
    dealSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0., 0., 320., 44.)];
    dealSearchBar.delegate = self;
    dealTableView.tableHeaderView = dealSearchBar;
    */
    
//    // add gesture to resign first responder of search bar
//    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] init];
//    [tapOnView addTarget:self action:@selector(tappedOnView) ];
//    [allDealsMyDealsBackgroundView addGestureRecognizer:tapOnView];
    
    
//    UITapGestureRecognizer *tapOnView1 = [[UITapGestureRecognizer alloc] init];
//    [tapOnView1 addTarget:self action:@selector(tappedOnView) ];
//    [navBarBackgroundView addGestureRecognizer:tapOnView1];
    
    
  
}

-(void )viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    dealTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    dealTableView.separatorColor = [UIColor clearColor];

    // this UIViewController is about to re-appear, make sure we remove the current selection in our table view
    [self.dealTableView deselectRowAtIndexPath:selectedRowOfDeals animated:NO];
    filterButton.enabled=YES;
    [parseOperations getAllNearByBusinessesWithNewSearch:YES isLimit:NO isForAllDeal:YES];

    // check if the user is business user or not
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"there is a user %@", [PFUser currentUser]);
        
        [self syncUserInfo]; // sync user info from cloud.
        
        if ([currentUser[FIELD_USER_USERTYPE] isEqualToString:USER_TYPE_BUSINESS]) {
            NSLog(@"a business user");
            isBusinessUser = YES;
        }else{
            isBusinessUser = NO;
        }
    }else{
        isBusinessUser = NO;
    }

    [self customizeView];
    
    if (![currentUser.objectId isEqualToString:activeUserObjectId]) {
        
        activeUserObjectId = currentUser.objectId;
        
        // show all deals when view user switches
        isAllDealsButtonSelected = YES;
        deals = [parseOperations.allDeals copy];
        [dealTableView reloadData];
        if ([dealTableView numberOfSections]>0) {
            [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
        // make deal button selected
        [allDealsButton setBackgroundImage:[UIImage imageNamed:@"selectedLeft.png"] forState:UIControlStateNormal];
        [allDealsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        // unselect business button
        [myDealsButton setBackgroundImage:[UIImage imageNamed:@"unselectedRight.png"] forState:UIControlStateNormal];
        [myDealsButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tappedOnView{
    NSLog(@"view tapped");
    [dealSearchBar resignFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"dealDetail"]) {
        
        if ([sender isKindOfClass:[PFObject class]]) {
            PFObject *deal = (PFObject*)sender;
            DealDetailsViewController *ddvc = [segue destinationViewController];
            ddvc.deal = deal;
        }
        else if ([sender isKindOfClass:[UITableViewCell class]]){
            UITableViewCell *cell = (UITableViewCell*)sender;
            NSIndexPath *indexPath = [dealTableView indexPathForCell:cell];
            NSLog(@"selected index path: %ld", (long)[indexPath row]);
            
            DealDetailsViewController *ddvc = [segue destinationViewController];
            ddvc.deal = [deals objectAtIndex:[indexPath row]];
        }
    }
    
   
    
   
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"newDeal"]) {
        
        PFUser *currentUser = [PFUser currentUser];
        if (!currentUser) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Please login as a business user to post a deal"];
            
            // Get the storyboard named secondStoryBoard from the main bundle:
            UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            // Load the initial view controller from the storyboard.
            // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
            UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
            [self presentViewController:theInitialViewController animated:YES completion:nil];
            
            return NO;
        }
        else{
            [self syncUserInfo];
            
            if (!isBusinessUser) {
                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"You have to become a business user to post a deal. Please go to settings and check off \"become a business user\" "];
                return NO;
            }
            else if ([[DEFAULTS valueForKey:@"ifDealerHasBusiness"] boolValue] == NO) {
                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"You have not added any business yet. Please go to Settings tab and add your business details"];
                return NO;
            }
            
            else if ([DEFAULTS boolForKey:FIELD_BUSINESS_IS_VERIFIED] == NO) {
                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Your business is not verified yet. Please wait for verification."];
                return NO;
            }
            else{
                return YES;
            }            
        }
    }
    if ([identifier isEqualToString:@"dealDetail"]) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [dealTableView indexPathForCell:cell];
        NSLog(@"selected index path: %ld", (long)[indexPath row]);

        if ([indexPath row] == [deals count]) {
            NSLog(@"tap to load more ...");
            return NO;
        }
        
        return YES;
    }
    return NO;
    
}


#pragma mark - custom methods

-(void)reFetchDeals{
    
    parseOperations.searchDistance=[NSNumber numberWithInt:20];
    parseOperations.searchKeyword = @"";
    isFetchFromSearch=NO;
    [refreshControl endRefreshing];
    [parseOperations getAllNearByBusinessesWithNewSearch:isFetchFromSearch isLimit:NO isForAllDeal:YES];

    if (isAllDealsButtonSelected) {
        if (isFetchFromSearch) {
            NSNumber *limit = [NSNumber numberWithInteger:[parseOperations.allDealsSearch count]];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            if ([limit intValue] > [DEALS_FETCH_LIMIT intValue])
                [parseOperations fetchAllDealsSearchInTheBackgroundWithDealIndex:@0 withLimit:limit];
            else
                [parseOperations fetchAllDealsSearchInTheBackgroundWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        }else{
            NSNumber *limit = [NSNumber numberWithInteger:[parseOperations.allDeals count]];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            if ([limit intValue] > [DEALS_FETCH_LIMIT intValue])
                [parseOperations startUpFetchDealsInTheBackground:@0 withLimit:limit];
            else
                [parseOperations startUpFetchDealsInTheBackground:@0 withLimit:DEALS_FETCH_LIMIT];
        }
    }
    else{
        if (isFetchFromSearch) {
            NSNumber *limit = [NSNumber numberWithInteger:[parseOperations.myDealsSearch count]];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            if ([limit intValue] > [DEALS_FETCH_LIMIT intValue])
                [parseOperations fetchMyDealsSearchInTheBackgroundWithDealIndex:@0 withLimit:limit];
            else
                [parseOperations fetchMyDealsSearchInTheBackgroundWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
            
        }else{
            NSNumber *limit = [NSNumber numberWithInteger:[parseOperations.myDeals count]];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];

            if ([limit intValue] > [DEALS_FETCH_LIMIT intValue])
                [parseOperations fetchMyDealsInTheBackgroundWithDealIndex:@0 withLimit:limit];
            else
                [parseOperations fetchMyDealsInTheBackgroundWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        }
    }
}

-(void) didReceiveDealsFetchNotification: (NSNotification *) notification{
    
    if ([[notification name] isEqualToString:@"dealFetchNotification"]){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog (@"Successfully received the dealFetchNotification notification!");
        
        NSLog(@"fetched deals: %@", parseOperations.allDeals);
        
        if (isAllDealsButtonSelected) {
            NSLog(@" isAllDealsButtonSelected on notification ");
            deals = nil;
            deals = [parseOperations.allDeals copy];
            [dealTableView reloadData];
//            [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }
    
    if ([[notification name] isEqualToString:@"myDealFetchNotification"]){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog (@"Successfully received the myDealFetchNotification notification!");
        
        NSLog(@"fetched deals: %@", parseOperations.myDeals);
        
        
        if (!isAllDealsButtonSelected) {
            NSLog(@" isAllDealsButtonSelected not on notification ");
            
            if ([parseOperations.myDeals count]) {
                deals = nil;
                deals = [parseOperations.myDeals copy];
                [dealTableView reloadData];
//                [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}



-(void) didReceiveDealsSearchNotification: (NSNotification *) notification{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([[notification name] isEqualToString:@"dealsSearchNotification"]){
        
        NSLog (@"Successfully received the dealsSearchNotification notification!");
        
        NSLog(@" dealsSearchNotification fetched deals: %@", parseOperations.allDealsSearch);
        
        if (isAllDealsButtonSelected) {
            NSLog(@" isAllDealsButtonSelected on notification ");
            deals = nil;
            deals = [parseOperations.allDealsSearch copy];
            [dealTableView reloadData];
            if ([dealTableView numberOfSections]>0) {
                [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                
            }        }
        
    }
    
    
    if ([[notification name] isEqualToString:@"myDealsSearchNotification"]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog (@"Successfully received the myDealsSearchNotification notification!");
        
        NSLog(@"fetched deals: %@", parseOperations.myDealsSearch);
        
        if (!isAllDealsButtonSelected) {
            NSLog(@" my deals button selected  notification ");
            
            deals = nil;
            deals = [parseOperations.myDealsSearch copy];
            [dealTableView reloadData];
            if ([dealTableView numberOfSections]>0) {
                [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

            }
            
        }
        
    }
    
}

-(void) syncUserInfo
{
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if (!error) {
            NSLog(@"current user refresh information: %@", object);
            
//            BOOL verifiedBusiness = [object[FIELD_USER_VERIFIED_BUSINESS] boolValue];
            
            
            PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
            [query whereKey:FIELD_BUSINESS_DEALER equalTo:[PFUser currentUser]];
            PFObject *myBusiness = [query getFirstObject];
            
            if (myBusiness) {
                BOOL verifiedBusiness = [myBusiness[FIELD_BUSINESS_IS_VERIFIED] boolValue];
                [DEFAULTS setBool:verifiedBusiness forKey:FIELD_BUSINESS_IS_VERIFIED];
                [DEFAULTS synchronize];
            }
            
        }
    }];
}

-(void)customizeView{
    
    [navBarTitleLabel setNavBarFont];
    // readjusting plus button and filter button according to user: dealer or consumer
    
    if (!isBusinessUser) {

        allDealsMyDealsBackgroundView.hidden = YES;
        
        CGRect tableFrame = dealTableView.frame;
        float minusHeight = 49 + 64; // 64 is navigation bar height, 49 tab bar height
        
        if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"6.9")) {
            tableFrame.origin.y = 65 - 20;
        }else{
            tableFrame.origin.y = 65;
        }
        
        // table view height
        
        tableFrame.size.height = ScreenSize.height - minusHeight;
        
        
        NSLog(@"table frame y: %f, height: %f", tableFrame.origin.y, tableFrame.size.height);
        
        dealTableView.frame = tableFrame;
        
    }else{
        // a business user
        allDealsMyDealsBackgroundView.hidden = NO;
        
        float height = 40 + 49 + 64;
        // 40 allDealsMyDealsBackgroundView, 64 navigation bar height, 49 tab bar height, 5 buffer
        
         CGRect tableFrame = dealTableView.frame;
        tableFrame.origin.y = allDealsMyDealsBackgroundView.frame.origin.y + allDealsMyDealsBackgroundView.frame.size.height;
        
        if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"6.9")) {
            height = 40 + 49 + 64 + 48;
            tableFrame.origin.y = allDealsMyDealsBackgroundView.frame.origin.y + allDealsMyDealsBackgroundView.frame.size.height + 20;
        }
        
        NSLog(@"table view y: %f, height: %f", tableFrame.origin.y, tableFrame.size.height);
        tableFrame.size.height = ScreenSize.height - height;
        dealTableView.frame = tableFrame;
        
    }
}


#pragma mark - IBActions

- (IBAction)didPressPlusButton:(id)sender {
    
//    [dealSearchBar resignFirstResponder];
    
}

- (IBAction)didPressFilterButton:(id)sender {
//    [dealSearchBar resignFirstResponder];
   // if (!popover) {
        FilterViewController *fvc = [[FilterViewController alloc] initWithNibName:@"FilterViewController" bundle:nil];
        fvc.delegate = self;
        
        popover = [[WYPopoverController alloc] initWithContentViewController:fvc];
        
        fvc.preferredContentSize = CGSizeMake(300, 350);
        
        [popover presentPopoverFromRect:filterButton.bounds
                                 inView:filterButton
               permittedArrowDirections:WYPopoverArrowDirectionAny
                               animated:YES
                                options:WYPopoverAnimationOptionScale];
        

    //}
    //else
    //{
    //    [popover dismissPopoverAnimated:YES];
    //    popover=nil;
    //}
    //    filterButton.enabled=NO;
    
}

- (IBAction)didPressAllDealsMyDealsButton:(id)sender{
        UIButton *button = sender;
        
        if (button.tag == 3) {
            
            // deals button pressed
            if(!isAllDealsButtonSelected){
                
                // make deal button selected
                [allDealsButton setBackgroundImage:[UIImage imageNamed:@"selectedLeft.png"] forState:UIControlStateNormal];
                [allDealsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                // unselect business button
                [myDealsButton setBackgroundImage:[UIImage imageNamed:@"unselectedRight.png"] forState:UIControlStateNormal];
                [myDealsButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
                
                deals = [parseOperations.allDeals copy];
                [dealTableView reloadData];
                if ([dealTableView numberOfSections]>0)
                {
                    [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

                }

                
                isAllDealsButtonSelected = !isAllDealsButtonSelected;
            }
        }
        
        if (button.tag == 4) {
            
            // my deals button pressed
            if(isAllDealsButtonSelected){
                
                // make deal button unselected
                [allDealsButton setBackgroundImage:[UIImage imageNamed:@"unselectedLeft.png"] forState:UIControlStateNormal];
                [allDealsButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
                
                // select business button
                [myDealsButton setBackgroundImage:[UIImage imageNamed:@"selectedRight.png"] forState:UIControlStateNormal];
                [myDealsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                deals = [parseOperations.myDeals copy];
                [dealTableView reloadData];
//                if ([dealTableView numberOfSections]>0)
//                {
//                    [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//                    
//                }
                
                isAllDealsButtonSelected = !isAllDealsButtonSelected;
            }
        }
    
}

- (IBAction)didPressRefreshButton:(id)sender {
    
    isFetchFromSearch = NO;
    [self reFetchDeals];
    if (isAllDealsButtonSelected) {
        deals = [parseOperations.allDeals copy];
        
        if ([deals count] < [DEALS_FETCH_LIMIT intValue]) {
            [parseOperations startUpFetchDealsInTheBackground:@0 withLimit:DEALS_FETCH_LIMIT];
        }
        
        [dealTableView reloadData];
        if ([dealTableView numberOfSections]>0)
        {
            [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            
        }    }else{
        deals = [parseOperations.myDeals copy];
        
        if ([deals count] < [DEALS_FETCH_LIMIT intValue]) {
            [parseOperations fetchMyDealsInTheBackgroundWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        }
        
        [dealTableView reloadData];
            if ([dealTableView numberOfSections]>0)
            {
                [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                
            }
    }
    
    
}


#pragma mark - Table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"DealsCell";
    DealsCell *cell = (DealsCell *)[tableView
                                      dequeueReusableCellWithIdentifier:cellIdentifier];


    cell.hidden=NO;
//    if (indexPath.row == deals.count-1) {
//        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
//    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



- (void)configureCell:(DealsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *deal = [deals objectAtIndex:[indexPath row]];
    
   /*-Business Name Added--*/
    PFObject *business = [deal objectForKey:FIELD_DEAL_OWNER];
    cell.businessNameLabel.text = [business objectForKey:FIELD_BUSINESS_NAME];
    [cell.businessNameLabel sizeToFit];
    
    cell.TitleLabel.text=[deal[FIELD_DEAL_ITEM_NAME] capitalizedString];
    cell.descriptionLabel.text=deal[FIELD_DEAL_ITEM_DESCRIPTION];
    
    
    
    NSString *dealPrice=[NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    if([dealPrice containsString:@"."]){
        cell.dealPriceLabel.text = [NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_DEAL_PRICE] floatValue]];
    }
    else{
        cell.dealPriceLabel.text = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    }
    
    
    NSString *dealOldPrice=[NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    if([dealOldPrice containsString:@"."]){
        dealOldPrice = [NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_ORIGINAL_PRICE] floatValue]];
    }
    else{
        dealOldPrice = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    }
    
   cell.oldPriceLabel.attributedText=[[SharedStore store]strkiethroughLabel:dealOldPrice];
//    [cell.oldPriceLabel strike?Through];
    [cell.descriptionLabel sizeToFit];
    
  
  

    
  //  cell.businessName.text=[deal objectForKey:FIELD_BUSINESS_NAME];

   /*  CGRect Frames=CGRectMake(15, 10, 80, 80);
     cell.descriptionLabel.frame=Frames;*/
    
    CGRect frame = cell.descriptionLabel.frame;
    [cell.descriptionLabel sizeToFit];
    frame.size.width = 160;
    cell.descriptionLabel.frame = frame;
    cell.dealPriceLabel.adjustsFontSizeToFitWidth  = YES;
    [cell.dealPriceLabel setTextAlignment:NSTextAlignmentRight];
   
    
    
    // lazy loading images
    PFFile *userImageFile = deal[FIELD_DEAL_IMAGE_FILE];
    PFImageView *itemImageView = [[PFImageView alloc] initWithFrame:cell.itemImageView.frame];
    
    
    
    itemImageView.image = [UIImage imageNamed:@"no-image.png"]; // placeholder image
    itemImageView.file = (PFFile *)userImageFile;
    CGRect Frame=CGRectMake(6, 15, 80, 80);
  
    itemImageView.frame=Frame;
    [[SharedStore store]customizeImageView:itemImageView];

    
    [cell.contentView addSubview:itemImageView];
    [itemImageView loadInBackground];
//    // adding start image icon
 
    int rating = [deal[FIELD_DEAL_ITEM_AVERAGE_RATE] intValue];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(95 ,90, 112, 7)];
    cell.ratingImageView.frame=imageView.frame;
    cell.ratingImageView.image = [self imageForRating:rating];
 
  

    // show expired label if my deal has expired
    NSDate *date = [NSDate date];
    NSDate *toDate = deal[FIELD_DEAL_VALID_TO];
    cell.dealExpiredLabel.hidden=YES;

    if ([date compare:toDate] == NSOrderedDescending)
    {
        cell.dealExpiredLabel.hidden=NO;
        cell.dealExpiredLabel.text=@"Expired";
    }


    NSDate *fromDate = deal[FIELD_DEAL_VALID_FROM];
    if ([date compare:fromDate] == NSOrderedAscending) {
        cell.dealExpiredLabel.hidden=NO;
        cell.dealExpiredLabel.text=@"UnPublished";
    }
    
}

- (UIImage *)imageForRating:(int)rating
{
    switch (rating) {
        case 0: return [UIImage imageNamed:@"orange-zero"];
        case 1: return [UIImage imageNamed:@"orange-one"];
        case 2: return [UIImage imageNamed:@"orange-two"];
        case 3: return [UIImage imageNamed:@"orange-three"];
        case 4: return [UIImage imageNamed:@"orange-four"];
        case 5: return [UIImage imageNamed:@"orange-five"];

    }
    return nil;
}

#pragma mark - Table View delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (deals.count>0)
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        UILabel *label=(UILabel *)[self.view viewWithTag:12345];
        label.hidden=YES;
        tableView.backgroundView=  nil;
        
        return 1;
    }
    
    else
    {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No deals availale.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel setSmallFont];

        [messageLabel setFont: App_Default_font_16];
        [messageLabel sizeToFit];
        
            tableView.backgroundView = messageLabel;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [deals count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 112;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"index selected: %ld", (long)[indexPath row]);
    selectedRowOfDeals = indexPath;
    
    
    
    [self.dealTableView deselectRowAtIndexPath:selectedRowOfDeals animated:NO];
    
    // following codes are not is use
    /*
    if ([indexPath row] == [deals count]) {
        if (isAllDealsButtonSelected) {
            
            if (isFetchFromSearch) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[ParseOperations sharedInstance] fetchAllDealsSearchInTheBackgroundWithDealIndex:[NSNumber numberWithInteger:[indexPath row]]  withLimit:DEALS_FETCH_LIMIT];
            }else{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[ParseOperations sharedInstance] startUpFetchDealsInTheBackground:[NSNumber numberWithInteger:[indexPath row]]  withLimit:DEALS_FETCH_LIMIT];
            }

        }else{
            if (isFetchFromSearch) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[ParseOperations sharedInstance] fetchMyDealsSearchInTheBackgroundWithDealIndex:[NSNumber numberWithInteger:[indexPath row]] withLimit:DEALS_FETCH_LIMIT];
            }else{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[ParseOperations sharedInstance] fetchMyDealsInTheBackgroundWithDealIndex:[NSNumber numberWithInteger:[indexPath row]]  withLimit:DEALS_FETCH_LIMIT];
            }
        }
        
    }
     */
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.dealTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.dealTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.dealTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.dealTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma  mark - textfield delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - Search bar delegates
/*
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searh bar button clicked..0");
    [searchBar resignFirstResponder];
    
    // searching text in array
    
//    [self filterContentForSearchText:searchBar.text];
    
}
 */

/*
- (void)filterContentForSearchText:(NSString*)searchText
{
    
    // fetch deals
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    
    // only get non expired items
    [query whereKey:FIELD_DEAL_VALID_FROM lessThan:[NSDate date]];
    [query whereKey:FIELD_DEAL_VALID_TO greaterThanOrEqualTo:[NSDate date]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            if ([objects count] == 0) {
                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No deals found"];
            }else{
                
                deals = allDealsArray = nil;
                deals = allDealsArray = [objects copy];
                
                NSLog(@"all deals objects: %@", objects);
                [dealTableView reloadData];
                [dealTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                
                NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(itemName CONTAINS[c] %@) OR (itemDescription CONTAINS[c] %@)", searchText, searchText];
                
                dealsSearchArray = [[allDealsArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
                
                if ([dealsSearchArray count] == 0) {
                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No matching deals found!"];
                }else{
                    
                    deals = nil;
                    deals = [dealsSearchArray copy];
                    [dealTableView reloadData];
                }
                
                NSLog(@"searchResults: %@", dealsSearchArray);
                
            }
        }
        else{
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Something went wrong while searching deals. Please try later"];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

 */

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"searching text: %@", searchBar.text);
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSLog(@"search end: %@", searchBar.text);
}



- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
//     NSLog(@"offset: %f", offset.y);
//     NSLog(@"content.height: %f", size.height);
//     NSLog(@"bounds.height: %f", bounds.size.height);
//     NSLog(@"inset.top: %f", inset.top);
//     NSLog(@"inset.bottom: %f", inset.bottom);
//     NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = -160;
    
//    float reload_distance2 = -120;
    
    if((y > h + reload_distance) && ([deals count] >= [DEALS_FETCH_LIMIT intValue])) {
        NSLog(@" ---------- ---------- ---------- ---------- ---------- load more rows");
        
        if (isAllDealsButtonSelected) {
            
            if (isFetchFromSearch) {
                [[ParseOperations sharedInstance] fetchAllDealsSearchInTheBackgroundWithDealIndex:[NSNumber numberWithInteger:[deals count]]  withLimit:DEALS_FETCH_LIMIT];
            }else{
                [[ParseOperations sharedInstance] startUpFetchDealsInTheBackground:[NSNumber numberWithInteger:[deals count]]  withLimit:DEALS_FETCH_LIMIT];
            }
            
        }else{
            if (isFetchFromSearch) {
                [[ParseOperations sharedInstance] fetchMyDealsSearchInTheBackgroundWithDealIndex:[NSNumber numberWithInteger:[deals count]] withLimit:DEALS_FETCH_LIMIT];
            }else{
                [[ParseOperations sharedInstance] fetchMyDealsInTheBackgroundWithDealIndex:[NSNumber numberWithInteger:[deals count]]  withLimit:DEALS_FETCH_LIMIT];
            }
        }
        
    }
        
}


#pragma mark - FilterView delegate

-(void)doSearch
{
    isFetchFromSearch = YES;
    [popover dismissPopoverAnimated:YES];
    popover=nil;
    if (isAllDealsButtonSelected) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [parseOperations getAllNearByBusinessesWithNewSearch:YES isLimit:YES isForAllDeal:NO];

    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [parseOperations fetchMyDealsSearchInTheBackgroundWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        [parseOperations searchMyDealsByMyNearByBusinesses];

    }
    filterButton.enabled=YES;
    
}

@end




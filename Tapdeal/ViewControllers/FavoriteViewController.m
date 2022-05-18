//
//  FavoriteViewController.m
//  Tapdeal
//
//  Created by Neetin on 7/10/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "FavoriteViewController.h"

#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SharedStore.h"
#import "AppDelegate.h"
#import "UILabel+Custom.h"
#import "UITextField+Custom.h"
#import <WYPopoverController/WYPopoverController.h>
#import "FilterViewController.h"
#import "ParseOperations.h"
#import "DealDetailsViewController.h"

#import "DealDetailsViewController.h"

#import "ParseOperations.h"

#import "DealersDealViewController.h"

@interface FavoriteViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UISearchBarDelegate, FilterViewDelegate>


// IBoutlets
@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *dealsAndBusinessesBackgroundView;

@property (weak, nonatomic) IBOutlet UIButton *dealsButton;
@property (weak, nonatomic) IBOutlet UIButton *businessesButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;

@property (weak, nonatomic) IBOutlet UITableView *favoriteDealsTableView;

@property (weak, nonatomic) IBOutlet UITableView *favoriteDealerTableView;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;



@property (weak, nonatomic) IBOutlet UIView *navBarBackgroundView;

// IBActions
- (IBAction)didPressFilterButton:(id)sender;
- (IBAction)didPressDealsOrBusinessesButton:(id)sender;
- (IBAction)didPressRefreshButton:(id)sender;


// properties

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) NSArray *deals;

@property (nonatomic, strong) NSArray *dealers;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIRefreshControl *dealerRefreshControl;

@property (nonatomic, strong) UISearchBar *dealSearchBar;
@property (nonatomic, strong) UISearchBar *dealersDealsearchBar;

@property (nonatomic, strong) WYPopoverController *popover;

@property (nonatomic) NSIndexPath *selectedRowOfDeals;
@property (nonatomic) NSIndexPath *selectedRowOfDealer;

@property (nonatomic, assign) BOOL isDealsButtonSelected;

@property (nonatomic, strong) ParseOperations *parseOperations;

@property (nonatomic, assign) BOOL isFetchFromSearch;

@property (nonatomic, assign) BOOL isMessageSeen;

@property (nonatomic, strong) NSString *activeUserObjectId;


@end

@implementation FavoriteViewController


@synthesize navBarTitleLabel, dealsAndBusinessesBackgroundView, dealsButton;
@synthesize businessesButton, filterButton, favoriteDealsTableView, navBarBackgroundView;

@synthesize location, deals, dealers, refreshControl;
@synthesize dealSearchBar, popover, selectedRowOfDeals, isMessageSeen;

@synthesize favoriteDealerTableView, dealerRefreshControl, dealersDealsearchBar, isDealsButtonSelected;

@synthesize parseOperations, isFetchFromSearch, selectedRowOfDealer, activeUserObjectId;

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
    
    isFetchFromSearch = NO;
    isMessageSeen = NO;
    
    parseOperations = [ParseOperations sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFavDealsSearchNotification:)
                                                 name:@"myFavDealsFetchNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFavDealsSearchNotification:)
                                                 name:@"myFavDealsSearchFetchNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFavDealersNotification:)
                                                 name:@"myFavDealersFetchNotification"
                                               object:nil];
    
    
    // show deals table view and hide dealersDeals table view
    isDealsButtonSelected = YES;
    
    favoriteDealsTableView.hidden = NO;
    favoriteDealerTableView.hidden = YES;
    
    deals = [NSMutableArray new];
    dealers = [NSMutableArray new];
    
    // refresh control for deals fav
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reFetchFavDeals) forControlEvents:UIControlEventValueChanged];
    [favoriteDealsTableView addSubview:refreshControl];
    
    
    // refresh control for dealer fav
    
    dealerRefreshControl = [[UIRefreshControl alloc] init];
    [dealerRefreshControl addTarget:self action:@selector(reFetchFavDealers) forControlEvents:UIControlEventValueChanged];
    [favoriteDealerTableView addSubview:dealerRefreshControl];
    
    
    
    
    // adding tags in table views
    favoriteDealsTableView.tag = 1;
    favoriteDealerTableView.tag = 2;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [parseOperations getMyFavDealsWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        [parseOperations getMyFavDealersWithIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        
         activeUserObjectId = currentUser.objectId;
        
    }

    
    [self customizeView];
    
}

-(void)didReceiveFavDealersNotification: (NSNotification *) notification{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([[notification name] isEqualToString:@"myFavDealersFetchNotification"]) {
        NSLog(@"get myFavDealersFetchNotification notifiaction....");
        dealers =nil;
        dealers = parseOperations.myFavoriteDealers;
        [favoriteDealerTableView reloadData];
//        [favoriteDealerTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}


-(void)didReceiveFavDealsSearchNotification: (NSNotification *) notification{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([[notification name] isEqualToString:@"myFavDealsFetchNotification"]){
        
        NSLog (@"Successfully received the myFavDealsFetchNotification notification!");
        
        NSLog(@" myFavDealsFetchNotification fetched deals: %@", parseOperations.myFavoriteDeals);
        deals = nil;
        deals = [parseOperations.myFavoriteDeals copy];
        [favoriteDealsTableView reloadData];
//        [favoriteDealsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([deals count] > [DEALS_FETCH_LIMIT intValue] && !isMessageSeen) {
            
            // notify user that only LIMITED deals fetched currently
            NSInteger count = parseOperations.myFavDealsCount;
            NSString *msg = [NSString stringWithFormat:@"You have %ld items in favorites. Only first %@ favorite items displayed. Please choose a category to remove this restriction", (long)count, DEALS_FETCH_LIMIT];
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:msg];
            isMessageSeen = YES;
        }
    }
    if ([[notification name] isEqualToString:@"myFavDealsSearchFetchNotification"]) {
        NSLog (@"Successfully received the myFavDealsSearchFetchNotification notification!");
        deals = nil;
        deals = [parseOperations.myFavoriteDealsSearch copy];
        [favoriteDealsTableView reloadData];
//        [favoriteDealsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
 
    [super viewWillAppear:animated];
    favoriteDealsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    favoriteDealerTableView .tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    filterButton.enabled=YES;
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        deals = nil;
        dealers = nil;
        
        [favoriteDealerTableView reloadData];
        [favoriteDealsTableView reloadData];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Please login from settings tab to see your favorites"];
        filterButton.enabled = NO;
    }else{
        
        if (![currentUser.objectId isEqualToString:activeUserObjectId]) {
            activeUserObjectId = currentUser.objectId;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [parseOperations getMyFavDealsWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
            [parseOperations getMyFavDealersWithIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        }
        
        filterButton.enabled = YES;
    }
    
    if(!isDealsButtonSelected) {
        filterButton.enabled = NO;
    }
    
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
     
     if ([[segue identifier] isEqualToString:@"favDealersDeal"]) {
         
         UITableViewCell *cell = (UITableViewCell*)sender;
         NSIndexPath *indexPath = [favoriteDealerTableView indexPathForCell:cell];
         NSLog(@"selected index path: %ld", (long)[indexPath row]);
         
         PFObject *dealer = [dealers objectAtIndex:[indexPath row]];
         
         DealersDealViewController *ddvc = [segue destinationViewController];
         ddvc.dealer = dealer;
     }

 }



- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"favDealersDeal"]) {
        
        if ([selectedRowOfDealer row] < [dealers count])
            return YES;
        
    }
    
    return NO;
}


#pragma mark -  IBActions

- (IBAction)didPressFilterButton:(id)sender {
    
    if (popover)
    {
        [popover dismissPopoverAnimated:YES];
        popover=nil;
    }
    else
    {
        FilterViewController *fvc = [[FilterViewController alloc] initWithNibName:@"FilterViewController" bundle:nil];
        fvc.delegate = self;
        fvc.isSliderHidden = YES;
        
        popover = [[WYPopoverController alloc] initWithContentViewController:fvc];
        
        fvc.preferredContentSize = CGSizeMake(300, 260);
        
        [popover presentPopoverFromRect:filterButton.bounds
                                 inView:filterButton
               permittedArrowDirections:WYPopoverArrowDirectionAny
                               animated:YES
                                options:WYPopoverAnimationOptionScale];
    }
    
}

- (IBAction)didPressDealsOrBusinessesButton:(id)sender {
    
    UIButton *button = sender;
    
    if (button.tag == 3) {
        
        // deals button pressed
        if(!isDealsButtonSelected){
            
            // make deal button selected
            [dealsButton setBackgroundImage:[UIImage imageNamed:@"selectedLeft.png"] forState:UIControlStateNormal];
            [dealsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            // unselect business button
            [businessesButton setBackgroundImage:[UIImage imageNamed:@"unselectedRight.png"] forState:UIControlStateNormal];
            [businessesButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
            
            // show deals table view and hide dealersDeals table view
            favoriteDealsTableView.hidden = NO;
            favoriteDealerTableView.hidden = YES;
            
            filterButton.enabled = YES;
            
            isDealsButtonSelected = !isDealsButtonSelected;
        }
    }
    
    if (button.tag == 4) {
        
        // business button pressed
        if(isDealsButtonSelected){
            
            // make deal button unselected
            [dealsButton setBackgroundImage:[UIImage imageNamed:@"unselectedLeft.png"] forState:UIControlStateNormal];
            [dealsButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
            
            // select business button
            [businessesButton setBackgroundImage:[UIImage imageNamed:@"selectedRight.png"] forState:UIControlStateNormal];
            [businessesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            // show dealersDeals table view and hide deals table view
            favoriteDealsTableView.hidden = YES;
            favoriteDealerTableView.hidden = NO;
            
            filterButton.enabled = NO;
            
            isDealsButtonSelected = !isDealsButtonSelected;
        }
    }
    
    if (![PFUser currentUser])
        filterButton.enabled = NO;
    
}

- (IBAction)didPressRefreshButton:(id)sender {
    isFetchFromSearch = NO;
    
    if (isDealsButtonSelected) {
        favoriteDealerTableView.hidden = YES;
        favoriteDealsTableView.hidden = NO;
        
        deals = parseOperations.myFavoriteDeals;
        
        if ([deals count] < [DEALS_FETCH_LIMIT intValue]) {
            [parseOperations getMyFavDealsWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        }else{
            [favoriteDealsTableView reloadData];
            if ([favoriteDealsTableView numberOfSections]>0) {
                [favoriteDealsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                
            }        }
    }
    else{
        favoriteDealerTableView.hidden = NO;
        favoriteDealsTableView.hidden = YES;
        
        dealers = parseOperations.myFavoriteDealers;
        if ([dealers count] < [DEALS_FETCH_LIMIT intValue]) {
             [parseOperations getMyFavDealersWithIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        }else{
            [favoriteDealerTableView reloadData];
            if ([favoriteDealerTableView numberOfSections]>0) {
                [favoriteDealerTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                
            }         }
    }
}



#pragma mark - custom methods

-(void)customizeView{
    [navBarTitleLabel setNavBarFont];
    
    CGRect tableFrame = favoriteDealsTableView.frame;
    float minusHeight = 49 + 40 + 64; // 64 is navigation bar height, 40 dealsAndBusinessesBackgroundView, 49 tab bar height
    
    tableFrame.size.height = ScreenSize.height - minusHeight;
    NSLog(@"fav table frame y: %f, height: %f", tableFrame.origin.y, tableFrame.size.height);
    favoriteDealsTableView.frame = tableFrame;
    
    favoriteDealerTableView.frame = tableFrame;
    
}

-(void)reFetchFavDeals{
    
    [refreshControl endRefreshing];
    
    if (![PFUser currentUser]) return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (isFetchFromSearch) {
        NSNumber *limit = [NSNumber numberWithInteger:[parseOperations.allDealsSearch count]];
        if ([limit intValue] > [DEALS_FETCH_LIMIT intValue])
            [parseOperations getMyFavDealsSearchWithDealIndex:@0 withLimit:limit];
        else
            [parseOperations getMyFavDealsSearchWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
    }else{
        NSNumber *limit = [NSNumber numberWithInteger:[parseOperations.myFavoriteDeals count]];
        
        if ([limit intValue] > [DEALS_FETCH_LIMIT intValue])
            [parseOperations getMyFavDealsWithDealIndex:@0 withLimit:limit];
        else
            [parseOperations getMyFavDealsWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
    }
}

-(void)reFetchFavDealers{
    
    [dealerRefreshControl endRefreshing];

    if (![PFUser currentUser]) return;
    
    NSNumber *limit = [NSNumber numberWithInteger:[parseOperations.myFavoriteDealers count]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([limit intValue] > [DEALS_FETCH_LIMIT intValue])
         [parseOperations getMyFavDealersWithIndex:@0 withLimit:limit];
    else
        [parseOperations getMyFavDealersWithIndex:@0 withLimit:DEALS_FETCH_LIMIT];
        
}



#pragma mark - Table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // tag 1 for favorite deal, 2 for favorite biz
    static  NSString *cellIdentifier = @"";
    if (tableView.tag == 1) {
        cellIdentifier = @"dealTableViewCell";
    }
    else if (tableView.tag == 2){
        cellIdentifier = @"dealerTableViewCell";
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // this is required, otherwise it content will overlap on every reload
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    if (tableView.tag == 1) {
        
        
        if ([indexPath row] == [deals count]) {
            UILabel *tapToLoadMore = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 30)];
            tapToLoadMore.text = @"Load more";
            [tapToLoadMore setNormalBoldFont];
            tapToLoadMore.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:tapToLoadMore];
            
        }else{
            PFObject *deal = [deals objectAtIndex:[indexPath row]];
            [self configureCell:cell atIndexPath:indexPath withDeal:deal];
        }
    }
    else if (tableView.tag == 2){
        
        PFObject *dealer  = [dealers objectAtIndex:indexPath.row];
        
        [self configureCell:cell atIndexPath:indexPath withDealer:dealer];
        
        NSLog(@"index path row: %ld,", (long)indexPath.row);
    }
//    if (indexPath.row == deals.count-1) {
//        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
//    }
    
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withDealer:(PFObject *)dealer {
    
    
    // lazy loading images
    PFFile *bizImageFile = dealer[FIELD_BUSINESS_IMAGE];
    PFImageView *itemImageView = [[PFImageView alloc] initWithFrame:CGRectMake(6, 6, 75, 75)];
    
    itemImageView.image = [UIImage imageNamed:@"no-image.png"]; // placeholder image
    itemImageView.file = (PFFile *)bizImageFile;
    [[SharedStore store]customizeImageView:itemImageView];
    

    //    itemImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [cell.contentView addSubview:itemImageView];
    [itemImageView loadInBackground];
    
    
    
    // dealer name
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(87, 0, 243, 25)];
    name.text = dealer[FIELD_BUSINESS_NAME];
    [name setNormalBoldFont];
    [cell.contentView addSubview:name];
    NSLog(@"address %@",[dealer[@"businessLocations"]objectAtIndex:0]);
    
    NSString *dealerAddress=[NSString  stringWithFormat:@"%@ ,%@",[dealer[@"businessLocations"]objectAtIndex:0][FIELD_BUSINESSLOCATION_ADDRESSLINE1],[dealer[@"businessLocations"]objectAtIndex:0][FIELD_BUSINESSLOCATION_COUNTRY]] ;
    
    UILabel *businessAddress = [[UILabel alloc]initWithFrame:CGRectMake(88, 27, 163, 45)];
    businessAddress.text = dealerAddress ;
    [businessAddress sizeToFit];
    [businessAddress setSmallFont];
    [cell.contentView addSubview:businessAddress];
    CGRect frame=businessAddress.frame;
    // dealer business number
    UILabel *businessNumber = [[UILabel alloc]initWithFrame:CGRectMake(88, frame.origin.y+frame.size.height+2, 163, 21)];
    businessNumber.text = dealer[FIELD_BUSINESS_BUSINESS_NUMBER];
//    [businessNumber sizeToFit];
    [businessNumber setSmallFont];
    [cell.contentView addSubview:businessNumber];
    
    
}


-(NSAttributedString *)strkiethroughLabel:(NSString *)string
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:@2
                            range:NSMakeRange(0, [attributeString length])];
    return attributeString;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withDeal:(PFObject *)deal {
    
    // deal title
    UILabel *dealTitle = [[UILabel alloc]initWithFrame:CGRectMake(88, 4, 163, 21)];
    dealTitle.text = deal[FIELD_DEAL_ITEM_NAME];
    [dealTitle setNormalBoldFont];
    
    // deal description
    UILabel *dealDescription = [[UILabel alloc]initWithFrame:CGRectMake(88, 22, 163, 45)];
    dealDescription.text = deal[FIELD_DEAL_ITEM_DESCRIPTION];
    dealDescription.numberOfLines=3;
    [dealDescription setSmallFont];
    [dealDescription sizeToFit];
    // deal  original price
    UILabel *originalPrice = [[UILabel alloc] initWithFrame:CGRectMake(270 , 27, 47, 21)];
    
    
    NSString *dealOriginalPrice=[NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    if([dealOriginalPrice containsString:@"."]){
        dealOriginalPrice = [NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_ORIGINAL_PRICE] floatValue]];
    }
    else{
        dealOriginalPrice = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    }
    
    
 // NSString *dealOriginalPrice = [NSString stringWithFormat:@"$%.2f",[deal[FIELD_DEAL_ORIGINAL_PRICE] floatValue]];
    originalPrice.attributedText=[self strkiethroughLabel:dealOriginalPrice];
    originalPrice.textAlignment = NSTextAlignmentRight;
    [originalPrice setSmallFont];
//    [originalPrice strikeThrough];
    
    
    // deal price
    UILabel *dealPrice = [[UILabel alloc] initWithFrame:CGRectMake(252, 4, 65, 22)];
    
    
    NSString *dealDealPrice=[NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    if([dealDealPrice containsString:@"."]){
       dealDealPrice=[NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_DEAL_PRICE] floatValue]];
    }
    else{
        dealDealPrice= [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    }
   // NSString *dealDealPrice = [NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_DEAL_PRICE] floatValue]];
    
    dealPrice.textAlignment = NSTextAlignmentRight;
    dealPrice.text = dealDealPrice;
    [dealPrice setNormalBoldFont];
    [dealPrice setFont:App_Default_font_20_bold];
    dealPrice.adjustsFontSizeToFitWidth=YES;
    [cell.contentView addSubview:dealTitle];
    [cell.contentView addSubview:dealDescription];
    [cell.contentView addSubview:originalPrice];
    [cell.contentView addSubview:dealPrice];
    
    
    // lazy loading images
    PFFile *userImageFile = deal[FIELD_DEAL_IMAGE_FILE];
    PFImageView *itemImageView = [[PFImageView alloc] initWithFrame:CGRectMake(5, 4, 80, 80)];
    
    
    
    itemImageView.image = [UIImage imageNamed:@"no-image.png"]; // placeholder image
    itemImageView.file = (PFFile *)userImageFile;
    
    //    itemImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [cell.contentView addSubview:itemImageView];
    [itemImageView loadInBackground];
    [[SharedStore store]customizeImageView:itemImageView];

    // adding start image icon
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(90 , 70, 112, 7)];
    
    NSLog(@"--------- AVG Rating of a deal: %@", deal[FIELD_DEAL_ITEM_AVERAGE_RATE]);
    
//    int rate = [deal[FIELD_DEAL_ITEM_AVERAGE_RATE] intValue];
    int rating = [deal[FIELD_DEAL_ITEM_AVERAGE_RATE] intValue];
    imageView.image = [self imageForRating:rating];
    imageView.contentMode = UIViewContentModeCenter;
    [cell.contentView addSubview:imageView];
    
    
    // show expired label if my deal has expired
    NSDate *date = [NSDate date];
    NSDate *toDate = deal[FIELD_DEAL_VALID_TO];
    if ([date compare:toDate] == NSOrderedDescending) {
        UILabel *expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(259,    53 , 58, 19)];
        [expireLabel setTextAlignment:NSTextAlignmentRight];
        expireLabel.text = @"Expired";
        
        [expireLabel setNormalFont];
        [expireLabel setTextColor:[UIColor redColor]];
        [cell.contentView addSubview:expireLabel];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(tableView.tag == 1 && [deals count]){
        return [deals count];

    }
    
    if (tableView.tag == 2 && [dealers count]){
        return [dealers count];
    }
    
    return 0;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView.tag == 1 )
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
            
            tableView.backgroundView=  [self addLabelNoItems];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        }
    }
   
    else
    {
        if (dealers.count>0)
        {
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            UILabel *label=(UILabel *)[self.view viewWithTag:12345];
            label.hidden=YES;
            tableView.backgroundView=  nil;

            return 1;
        }
        
        else
        {
          tableView.backgroundView=  [self addLabelNoItems];
          tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            
        }
    }
    return 0;
}

-(UILabel *)addLabelNoItems
{
    // Display a message when the table is empty
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    messageLabel.text = @"No favourite items.";
//    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [messageLabel setSmallFont];
    [messageLabel setFont: App_Default_font_16];
    [messageLabel sizeToFit];
    
//    tableView.backgroundView = messageLabel;
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return messageLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1) {
        return 87;
    }
    else if (tableView.tag == 2){
        return 87;
    }
    
    return 87;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"index selected: %ld", (long)[indexPath row]);
    if (tableView.tag == 1) {
        
        // fav deals
        selectedRowOfDeals = indexPath;
        
        [self.favoriteDealsTableView deselectRowAtIndexPath:selectedRowOfDeals animated:NO];
        
        if ([indexPath row] == [deals count]) {
            PFUser *currentUser = [PFUser currentUser];
            if (currentUser) {
                if (isFetchFromSearch) {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [[ParseOperations sharedInstance] getMyFavDealsSearchWithDealIndex:[NSNumber numberWithInteger:[indexPath row]]  withLimit:DEALS_FETCH_LIMIT];
                }else{
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [[ParseOperations sharedInstance] getMyFavDealsWithDealIndex:[NSNumber numberWithInteger:[indexPath row]]  withLimit:DEALS_FETCH_LIMIT];
                }
            }else{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Please login from settings tab to see your favorites"];
            }
            
        }else{
            // Get the storyboard named secondStoryBoard from the main bundle:
            UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Tabs" bundle:nil];
            
            // Load the initial view controller from the storyboard.
            // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
            DealDetailsViewController *detailVC = [secondStoryBoard instantiateViewControllerWithIdentifier:@"DealDetails"];
            detailVC.deal = [deals objectAtIndex:[indexPath row]];
            
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        
    }
    else if (tableView.tag == 2){
        
        // fav dealers
        selectedRowOfDealer = indexPath;
        [self.favoriteDealerTableView deselectRowAtIndexPath:selectedRowOfDealer animated:NO];
        NSLog(@"handled by prepareForSegue ....");
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([favoriteDealsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [favoriteDealsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([favoriteDealsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [favoriteDealsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - FilterView delegate

-(void)doSearch{
    [popover dismissPopoverAnimated:YES];
    isFetchFromSearch = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [parseOperations getMyFavDealsSearchWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
    
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
    
    if(y > h + reload_distance) {
        
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            if (isFetchFromSearch && ([deals count] >= [DEALS_FETCH_LIMIT intValue])) {
                //        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[ParseOperations sharedInstance] getMyFavDealsSearchWithDealIndex:[NSNumber numberWithInteger:[deals count]]  withLimit:DEALS_FETCH_LIMIT];
            }else{
                //        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                if (isDealsButtonSelected && ([deals count] > [DEALS_FETCH_LIMIT intValue] -1)) {
                    [[ParseOperations sharedInstance] getMyFavDealsWithDealIndex:[NSNumber numberWithInteger:[deals count]]  withLimit:DEALS_FETCH_LIMIT];
                }else{
                    NSLog(@"dealers count: %d", [dealers count]);
                    if (([dealers count] > [DEALS_FETCH_LIMIT intValue] -1)) {
                        [[ParseOperations sharedInstance] getMyFavDealersWithIndex:[NSNumber numberWithInteger:[dealers count]]  withLimit:DEALS_FETCH_LIMIT];
                    }
                }
                
            }
        }else{
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Please login from settings tab to see your favorites"];
        }
        
    }
}


@end

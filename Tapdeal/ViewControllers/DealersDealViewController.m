//
//  DealersDealViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 8/28/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "DealersDealViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ParseOperations.h"
#import "SharedStore.h"

#import "UILabel+Custom.h"
#import "UIButton+Custom.h"

#import "AppDelegate.h"
#import "DealDetailsViewController.h"
#import "WYPopoverController.h"

#import "FilterViewController.h"

@interface DealersDealViewController ()<UITableViewDataSource, UITableViewDelegate, FilterViewDelegate>


// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *nabTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *dealsTableView;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;



// IBActions
- (IBAction)didPressBackButton:(id)sender;
- (IBAction)didPressFilterButton:(id)sender;


// properties

@property (nonatomic, strong) NSArray *deals;

@property (nonatomic, strong) ParseOperations *parseOperations;

@property (nonatomic, strong) NSIndexPath *selectedRowOfDeal;

@property (nonatomic, assign) BOOL isFetchFromSearch;

@property (nonatomic, strong) WYPopoverController *popover;

@end

@implementation DealersDealViewController

@synthesize dealer, deals, parseOperations, selectedRowOfDeal, isFetchFromSearch;

@synthesize dealsTableView, nabTitleLabel, filterButton, popover;


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
    deals = [NSMutableArray new];
    dealsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    parseOperations = [ParseOperations sharedInstance];
    isFetchFromSearch = NO;
    
    NSLog(@"dealer: %@", dealer);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDealsFetchNotification:)
                                                 name:@"favDealerDealsFetchNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDealsFetchNotification:)
                                                 name:@"favDealerDealsSearchFetchNotification"
                                               object:nil];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [parseOperations getFavDealerDealsWithDealer:dealer WithIndex:@0 withLimit:DEALS_FETCH_LIMIT];
    
    [self customizeView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
       [self.navigationController popViewControllerAnimated:YES];
    }
    filterButton.enabled=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - custom methods

-(void)customizeView{
    [nabTitleLabel setNavBarFont];
    
//    NSString *titleLabel = [NSString stringWithFormat:@"%@'s Deals", dealer[FIELD_BUSINESS_NAME]];
    [nabTitleLabel setText:dealer[FIELD_BUSINESS_NAME]];
    
    CGRect tableFrame = dealsTableView.frame;
    float minusHeight = 49 + 64; // 64 is navigation bar height, 49 tab bar height
    
    tableFrame.size.height = ScreenSize.height - minusHeight;
    NSLog(@"fav table frame y: %f, height: %f", tableFrame.origin.y, tableFrame.size.height);
    dealsTableView.frame = tableFrame;
    
    dealsTableView.frame = tableFrame;
    
}



-(void) didReceiveDealsFetchNotification: (NSNotification *) notification{
    
    if ([[notification name] isEqualToString:@"favDealerDealsFetchNotification"]){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog (@"Successfully received the favDealerDealsFetchNotification notification on dealer's deal !");
        
        NSLog(@"fetched dealer's deals: %@", parseOperations.favoriteDealerDeals);
        
        deals = nil;
        deals = [parseOperations.favoriteDealerDeals copy];
        [dealsTableView reloadData];
    }
    
    if ([[notification name] isEqualToString:@"favDealerDealsSearchFetchNotification"]){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog (@"Successfully received the favDealerDealsSearchFetchNotification notification on dealer's deal !");
        
        NSLog(@"fetched dealer's deals: %@", parseOperations.favoriteDealerDealsSearch);
        
        deals = nil;
        deals = [parseOperations.favoriteDealerDealsSearch copy];
        [dealsTableView reloadData];
    }
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
#pragma mark - IBActions

- (IBAction)didPressBackButton:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

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
//    filterButton.enabled=NO;

}




#pragma mark - Table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"favdealerDealsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // this is required, otherwise it content will overlap on every reload
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
//    if (indexPath.row == deals.count-1) {
//        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
//    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(NSAttributedString *)strkiethroughLabel:(NSString *)string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttribute:NSStrikethroughStyleAttributeName
                            value:@2
                            range:NSMakeRange(0, [attributedString length])
     
     ];
    [attributedString addAttribute:NSBackgroundColorAttributeName
                             value:[UIColor yellowColor]
                             range:NSMakeRange(0, [attributedString length])];

    [attributedString addAttribute:NSStrikethroughColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, [attributedString length])];
    
    return attributedString;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *deal = [deals objectAtIndex:[indexPath row]];
    
    
  /*  PFObject *business = [deal objectForKey:FIELD_DEAL_OWNER];
    UILabel *businessNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(88, 12, 163, 21)];
    businessNameLabel.text = [business objectForKey:FIELD_BUSINESS_NAME];
   */
   
    UILabel *dealTitle = [[UILabel alloc]initWithFrame:CGRectMake(90, 4, 163, 21)];
    dealTitle.text = deal[FIELD_DEAL_ITEM_NAME];
    [dealTitle setNormalBoldFont];
    
    // deal description
    
    UILabel *dealDescription = [[UILabel alloc]initWithFrame:CGRectMake(90, 21, 163, 45)];
    dealDescription.text = deal[FIELD_DEAL_ITEM_DESCRIPTION];
    [dealDescription setSmallFont];
    dealDescription.numberOfLines=0;
    CGRect frame = dealDescription.frame;
    [dealDescription sizeToFit];
    frame.size.width = 163;
    dealDescription.frame=frame;
    // deal  original price
    UILabel *originalPrice = [[UILabel alloc] initWithFrame:CGRectMake(270 , 21, 47, 21)];
    
    NSString *dealOriginalPrice=[NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    if([dealOriginalPrice containsString:@"."]){
        dealOriginalPrice = [NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_ORIGINAL_PRICE] floatValue]];
    }
    else{
        dealOriginalPrice = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    }
    
    
  // NSString *dealOriginalPrice = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    originalPrice.attributedText = [[SharedStore store]strkiethroughLabel:dealOriginalPrice];    originalPrice.textAlignment = NSTextAlignmentRight;
    [originalPrice setSmallFont];
//    [originalPrice sizeToFit];
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
   
    //NSString *dealDealPrice = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    
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
    CGRect Frame=itemImageView.frame;
    Frame.size.height=80;
    itemImageView.frame=Frame;
    [[SharedStore store]customizeImageView:itemImageView];
    
    
    [cell.contentView addSubview:itemImageView];
    [itemImageView loadInBackground];
    
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
        
        messageLabel.text = @"No deals availale at the moment.";
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
    
    return 87;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"index selected: %ld", (long)[indexPath row]);
    selectedRowOfDeal = indexPath;
    
    
    [self.dealsTableView deselectRowAtIndexPath:selectedRowOfDeal animated:NO];
    if ([indexPath row] == [deals count]) {
        if (isFetchFromSearch) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [parseOperations getFavDealerDealsSearchWithDealer:dealer WithIndex:@0 withLimit:DEALS_FETCH_LIMIT];
            
        }else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [parseOperations getFavDealerDealsWithDealer:dealer WithIndex:[NSNumber numberWithInteger:[indexPath row]]  withLimit:DEALS_FETCH_LIMIT];
        }
        
    }else{
        NSLog(@"show deal details from here");
        
        // Get the storyboard named secondStoryBoard from the main bundle:
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Tabs" bundle:nil];
        
        // Load the initial view controller from the storyboard.
        // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
        DealDetailsViewController *detailVC = [secondStoryBoard instantiateViewControllerWithIdentifier:@"DealDetails"];
        detailVC.deal = [deals objectAtIndex:[indexPath row]];
        
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
}

#pragma mark - FilterView delegate

-(void)doSearch{
    [popover dismissPopoverAnimated:YES];
    isFetchFromSearch = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [parseOperations.favoriteDealerDealsSearch removeAllObjects];
    
    [parseOperations getFavDealerDealsSearchWithDealer:dealer WithIndex:@0 withLimit:DEALS_FETCH_LIMIT];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    NSLog(@"on dealers deal scroll -------------------");
    
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
            if ([deals count] > [DEALS_FETCH_LIMIT intValue] -1) {
                [[ParseOperations sharedInstance] getFavDealerDealsWithDealer:dealer WithIndex:[NSNumber numberWithInteger:[deals count]]  withLimit:DEALS_FETCH_LIMIT];
            }
            
        }else{
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Please login from settings tab to see your favorites"];
             [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}




@end

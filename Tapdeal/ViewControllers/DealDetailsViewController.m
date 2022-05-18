//
//  DealDetailsViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/25/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "DealDetailsViewController.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "SharedStore.h"
#import "UIView+Rounded.h"

#import "UIImage+Custom.h"
#import "UILabel+Custom.h"
#import "UIButton+Custom.h"
#import "UITextView+Custom.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "ParseOperations.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

#import "ShowDirectionOnMapViewController.h"

#import "ParseOperations.h"
#import "NewDealViewController.h"

#import "DealPreviewViewController.h"

@interface DealDetailsViewController ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, DealPreviewDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UIImageView *topRatingImageView;

@property (weak, nonatomic) IBOutlet UITextView *itemDescription;
@property (weak, nonatomic) IBOutlet UITextView *itemBusinessAddress;

@property (weak, nonatomic) IBOutlet UILabel *itemDealPrice;
@property (weak, nonatomic) IBOutlet UILabel *itemOriginalPrice;
@property (weak, nonatomic) IBOutlet UILabel *itemValidUntilDate;

@property (weak, nonatomic) IBOutlet UILabel *itemDistanceKM;

@property (weak, nonatomic) IBOutlet UILabel *favDealLabel;
@property (weak, nonatomic) IBOutlet UIButton *favDealButton;

@property (weak, nonatomic) IBOutlet UILabel *favBizLabel;
@property (weak, nonatomic) IBOutlet UIButton *favBizButton;

@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *getDirectionButton;

@property (weak, nonatomic) IBOutlet UILabel *itemRatingLabel;

@property (weak, nonatomic) IBOutlet UILabel *rateThisDealLabel;

@property (weak, nonatomic) IBOutlet UIButton *oneStarButton;
@property (weak, nonatomic) IBOutlet UIButton *twoStarButton;
@property (weak, nonatomic) IBOutlet UIButton *threeStarButton;
@property (weak, nonatomic) IBOutlet UIButton *fourStarButton;
@property (weak, nonatomic) IBOutlet UIButton *fiveStarButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;




// IBAction

- (IBAction)didPressEditButton:(id)sender;
- (IBAction)didPressBackButton:(id)sender;
- (IBAction)didPressFavDealButton:(id)sender;
- (IBAction)didPressFavBizButton:(id)sender;
- (IBAction)didPressShareButton:(id)sender;

- (IBAction)didPressStarButton:(id)sender;

- (IBAction)didPressGetDirectionButton:(id)sender;

- (IBAction)didPressCloseButton:(id)sender;


// properties

@property (nonatomic, retain) PFObject *businessLocation;
@property (nonatomic, strong) NSNumber *businessPhoneNumber;
@property (nonatomic, retain) PFObject *businessOwner;

@property (nonatomic, retain) PFObject *ratingObject;

@property (nonatomic) BOOL isBizFavorite;
@property (nonatomic) BOOL isDealFavorite;

@property (nonatomic, strong) UIActionSheet *actionSheet;


@property (nonatomic, retain) PFGeoPoint *businessLocationPoint;

@property (nonatomic, retain) ParseOperations *parseOperations;

@property (nonatomic, retain) CLLocation *dealLocation;

@property (nonatomic, retain) NSString *activeUserObjectId;

@end

@implementation DealDetailsViewController

@synthesize deal, businessLocationPoint, parseOperations, isModal, closeButton;

@synthesize scrollView, backButton, itemImageView, shadowView, itemTitle;

@synthesize topRatingImageView, itemDescription, itemDealPrice, itemOriginalPrice;

@synthesize itemValidUntilDate, itemDistanceKM, itemBusinessAddress;

@synthesize favDealButton, favBizButton, shareButton, shareLabel, favBizLabel, favDealLabel;

@synthesize editButton, navBarTitleLabel, getDirectionButton, rateThisDealLabel;

@synthesize businessLocation, businessPhoneNumber, businessOwner, activeUserObjectId;

@synthesize oneStarButton, twoStarButton, threeStarButton, fourStarButton, fiveStarButton;

@synthesize ratingObject, isBizFavorite, isDealFavorite, actionSheet, dealLocation;


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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(showScrollForItemDescription)];
    
    
    [self.view addGestureRecognizer:tap];
    scrollView.delegate = self;
    
    editButton.hidden = YES;
    
    parseOperations = [ParseOperations sharedInstance];
    
    NSLog(@"deal : %@", deal);
    isDealFavorite = NO;
    isBizFavorite = NO;
    
    [self resetScrollView];
    
    itemOriginalPrice.text = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];  // this is required here to set stroke
//    [self customizeView];
    [UIView setRoundedBorder:_itemRatingLabel.layer withWidth:0.4 borderColor:[UIColor grayColor] andRadius:4.0];

    [self setupRatings];
    [self checkAndSetFavBiz];
    [self checkAndSetFavDeal];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser){
        activeUserObjectId = currentUser.objectId;
    }
    
}
-(void)showScrollForItemDescription {
    [itemDescription flashScrollIndicators];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"test scroll");
    [itemDescription flashScrollIndicators];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [itemDescription flashScrollIndicators];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [self enableOrDisableEditButton];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    deal=nil;
    parseOperations=nil;
    dealLocation=nil;
    businessLocation=nil;
    self.navigationController.delegate = nil;

    
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
    
    if ([[segue identifier] isEqualToString:@"showDirection"]) {
        
        
        
        ShowDirectionOnMapViewController *showDirectionVC = [segue destinationViewController];
        
        
        CLLocation *currentLocation = DELEGATE.locationManager.location;
        NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
                         currentLocation.coordinate.latitude, currentLocation.coordinate.longitude,
                         businessLocationPoint.latitude, businessLocationPoint.longitude];
        
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        showDirectionVC.request = request;
    }
    
    if ([[segue identifier] isEqualToString:@"EditDeal"]) {
        
        UINavigationController *navController = [segue destinationViewController];
        
        NewDealViewController *newDeal = [[navController viewControllers] objectAtIndex:0];
        
        newDeal.deal = deal;
        newDeal.previewDelegate = self;
    }
    
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"showDirection"]) {
        if (businessLocationPoint.latitude == 0 || businessLocationPoint.longitude == 0) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Deal Location not found."];
            return NO;
        }
        return YES;
    }
    
    if ([identifier isEqualToString:@"EditDeal"]) {
        
        if ([[DEFAULTS valueForKey:@"ifDealerHasBusiness"] boolValue] == NO) {
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"You have not added any business yet. Please go to Settings tab and add your business details"];
            return NO;
        }
        
        else if ([DEFAULTS boolForKey:FIELD_BUSINESS_IS_VERIFIED] == NO) {
            
            NSString *msg = [NSString stringWithFormat:@"Your business has been disbled by admin, Please contact to %@ support.", APPLICATION_NAME];
            
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:msg];
            return NO;
        }
        return YES;
    }
   return NO;
}

#pragma mark - custom methods

-(void)enableOrDisableEditButton{
    NSDate *date = [NSDate date];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser &&![currentUser.objectId isEqualToString:activeUserObjectId])
        [self.navigationController popViewControllerAnimated:YES];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [deal refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        deal = object;
        [self populateData];
        
        
        NSLog(@"refresh deal in bg...");
        NSDate *toDate = object[FIELD_DEAL_VALID_TO];
        NSDate *fromDate = object[FIELD_DEAL_VALID_FROM];
        if (parseOperations.myBusinesses.count>0)
        {
            PFObject *myBizInfo = [parseOperations.myBusinesses objectAtIndex:0];
            PFObject *owner = object[FIELD_DEAL_OWNER];
            // disable ratings and Fav deal, Fav biz if current user is deal owner
            if (myBizInfo) {
                if ([myBizInfo.objectId isEqualToString:owner.objectId]) {
                    favDealButton.enabled = NO;
                    favBizButton.enabled = NO;
                    oneStarButton.enabled = NO;
                    twoStarButton.enabled = NO;
                    threeStarButton.enabled = NO;
                    fourStarButton.enabled = NO;
                    fiveStarButton.enabled = NO;
                    
//                    if ([date compare:toDate] == NSOrderedDescending || [date compare:fromDate] == NSOrderedAscending) {
//                        NSLog(@"deal has expired or not published yet, show Edit button on navigation bar");
//                        editButton.hidden = NO;
//                        
//                    }
//                    else{
//                        editButton.hidden = YES;
//                    }
                    editButton.hidden=NO;
                }
            }

        }
        
        
        // if current user is not business owner but he/she has favorited this deal and it has expired then disable ratings, fav and share icons
        
        if ([date compare:toDate] == NSOrderedDescending) {
            favDealButton.enabled = NO;
            favBizButton.enabled = NO;
            oneStarButton.enabled = NO;
            twoStarButton.enabled = NO;
            threeStarButton.enabled = NO;
            fourStarButton.enabled = NO;
            fiveStarButton.enabled = NO;
            
        }
        
        
     
        
    }];
    //[MBProgressHUD hideHUDForView:self.view animated:YES];

}

-(void)setupRatings{
    // check if user is there and if user has already rated this deal
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser){
        PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_RATING];
        [query whereKey:FIELD_RATING_DEAL equalTo:deal];
        [query whereKey:FIELD_RATING_USER equalTo:currentUser];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSLog(@"rating objects: %@", objects);
                
                if ([objects count]) {
                    ratingObject = [objects objectAtIndex:0];
                    
                    int rate = [ratingObject[FIELD_RATING_RATE] intValue];
                    if(rate>5)
                        rate=5;
                    [self makeRateTheDealUXWithRating:rate];
                }
            }
            else
            {
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:[[error userInfo] description]];

          }
        }];
    }
    
    [self averageRatingForADeal:deal[FIELD_DEAL_ITEM_AVERAGE_RATE]];
    
}

-(void)checkAndSetFavBiz{
    PFUser *currentUser = [PFUser currentUser];
    NSArray *favBusinesses = currentUser[FIELD_USER_FAVORITE_BUSINESSES];
    NSLog(@"favorite businesses: %@", favBusinesses);
    if ([favBusinesses count]) {
        for (PFObject *business in favBusinesses) {
            PFObject *dealOwner = deal[FIELD_DEAL_OWNER];
            
            if ([dealOwner.objectId isEqualToString:business.objectId]) {
                
                isBizFavorite = YES;
                [self setFavBizIcon];
                break;
            }
        }
    }
}

-(void)checkAndSetFavDeal{
    PFUser *currentUser = [PFUser currentUser];
    NSArray *favDeals = currentUser[FIELD_USER_FAVORITE_DEALS];
    NSLog(@"favorite deals: %@", favDeals);
    if ([favDeals count]) {
        for (PFObject *favDeal in favDeals) {
            
            if ([favDeal.objectId isEqualToString:deal.objectId]) {
                
                isDealFavorite = YES;
                [self setFavDealIcon];
                break;
            }
        }
    }
}

-(void) setFavBizIcon{
    if (isBizFavorite)
    {
        [favBizButton setImage:[UIImage imageNamed:@"selected_fav-biz.png"] forState:UIControlStateNormal];
    }else{
        [favBizButton setImage:[UIImage imageNamed:@"favbiz.png"] forState:UIControlStateNormal];
    }
}

-(void)setFavDealIcon{
    if (isDealFavorite) {
        [favDealButton setImage:[UIImage imageNamed:@"selected_fav-deal.png"] forState:UIControlStateNormal];
    }else{
        [favDealButton setImage:[UIImage imageNamed:@"favdeal.png"] forState:UIControlStateNormal];
    }
}

-(void)resetScrollView{
    
    scrollView.scrollEnabled = YES;
    [scrollView setContentSize:CGSizeMake(320, 580)];
    
    CGRect frame = self.scrollView.frame;
    
    float originY = 64;
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"6.9")) {
        originY = 64 - 20;
    }
    
    frame.origin.y = originY;
    frame.size = CGSizeMake(320, ScreenSize.height - 114);
    
    [self.scrollView setFrame:frame];
    NSLog(@"scroll view height: %f", scrollView.frame.size.height);
}

-(void)customizeView{
    
    
    
    // modify fonts here
    //[itemTitle setNormalBoldFont];
    [itemDescription setNormalGreyFont];
    [itemBusinessAddress setSmallFont];
    [itemDealPrice setNormalBoldFont];
    
    [itemOriginalPrice setTinyFont];
    [itemOriginalPrice strikeThrough];
    
    [itemValidUntilDate setSmallFont];
    
    [itemDistanceKM setNormalFont];
    [favBizLabel setNormalFont];
    [favDealLabel setNormalFont];
    [shareLabel setNormalFont];
    
    [navBarTitleLabel setNavBarFont];
    [editButton setCustomFont];
    [getDirectionButton setCustomFont];
    [rateThisDealLabel setNormalFont];
    
    [favDealButton setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
    [favBizButton setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    [shareButton setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    
    // show hide close or back button
    if (isModal) {
        closeButton.hidden = NO;
        backButton.hidden = YES;
        self.tabBarController.tabBar.hidden = YES;
    }else{
        closeButton.hidden = YES;
        backButton.hidden = NO;
    }
}

-(void)populateData{
    
    // adding item image
    
    __block  UIImage *itemImage = [UIImage imageNamed:@"no-image.png"];
    [itemImageView setImage:itemImage];
    
    PFFile *userImageFile = deal[FIELD_DEAL_IMAGE_FILE];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            itemImage = [UIImage imageWithData:imageData];
            [itemImageView setImage:itemImage];
        }
    }];
  
   
    // navBarTitleLabel.text=[deal[FIELD_DEAL_ITEM_NAME] capitalizedString];
    
    itemTitle.text = [deal[FIELD_DEAL_ITEM_NAME] capitalizedString];
    itemTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    itemDescription.text = deal[FIELD_DEAL_ITEM_DESCRIPTION];
    
       // float DealPrice = [deal[FIELD_DEAL_DEAL_PRICE] floatValue];
    NSString *dealPrice=[NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    if([dealPrice containsString:@"."]){
         itemDealPrice.text = [NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_DEAL_PRICE] floatValue]];
    }
    else{
         itemDealPrice.text = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    }
    
    
    NSString *dealOldPrice=[NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    if([dealOldPrice containsString:@"."]){
       
        dealOldPrice=[NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_ORIGINAL_PRICE] floatValue]];
    }
    else{
        dealOldPrice = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    }

   itemDealPrice.adjustsFontSizeToFitWidth=YES;


    itemOriginalPrice.attributedText=[[SharedStore store]strkiethroughLabel:dealOldPrice];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy, hh:mm a"];
    NSString *validToDate = [dateFormatter stringFromDate:deal[FIELD_DEAL_VALID_TO]];
    itemValidUntilDate.text =[NSString stringWithFormat:@"Valid until %@", validToDate];
    
//    [itemDealPrice sizeToFit];
    businessOwner = deal[FIELD_DEAL_OWNER];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *businessQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
    [businessQuery whereKey:@"objectId" equalTo:businessOwner.objectId];
    [businessQuery findObjectsInBackgroundWithBlock:^(NSArray *businesses, NSError *error) {
        if (!error) {
            NSLog(@"business : %@", businesses);
            if ([businesses count]) {
                PFObject *business = [businesses objectAtIndex:0];
                navBarTitleLabel.text = [business[FIELD_BUSINESS_NAME]capitalizedString];

                
                NSArray *businessLocations = business[FIELD_BUSINESS_BUSINESSLOCATIONS];
                PFObject *singleLocation = [businessLocations objectAtIndex:0];
                
                PFQuery *businessLocationQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS_LOCATION];
                [businessLocationQuery whereKey:@"objectId" equalTo:singleLocation.objectId];
                [businessLocationQuery findObjectsInBackgroundWithBlock:^(NSArray *locations, NSError *error) {
                    if (!error) {
                        if ([locations count]) {
                            businessLocation = [locations objectAtIndex:0];
                            
                            NSLog(@"locations: %@", businessLocation);

                            businessLocationPoint = businessLocation[FIELD_BUSINESSLOCATION_LOCATION_POINT];
                            businessPhoneNumber = businessLocation[FIELD_BUSINESSLOCATION_PHONE];
                            
                            
                            dealLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(businessLocationPoint.latitude, businessLocationPoint.longitude) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:0 timestamp:[NSDate date]];
                            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(dealLocation.coordinate, 1800, 1800);
                            [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
                            
                            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                            point.coordinate =  dealLocation.coordinate;
                            //    point.title = @"Where am I?";
                            //    point.subtitle = @"I'm here!!!";
                            
                            [self.mapView addAnnotation:point];
                            self.mapView.layer.borderWidth=1.0;
                            self.mapView.layer.borderColor=(__bridge CGColorRef)([UIColor darkGrayColor]);
                            
                            if ([businessLocation[FIELD_BUSINESSLOCATION_COUNTRY] isEqualToString:@""]) {
                         
                                // reverse geocoder to get address from location points
                                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                
                                [geocoder reverseGeocodeLocation:dealLocation completionHandler:
                                 ^(NSArray* placemarks, NSError* error){
                                     if ([placemarks count] > 0)
                                     {
                                         NSLog(@"placemarks array object: %@", placemarks);
                                         
                                         CLPlacemark *placemark =  [placemarks objectAtIndex:0];
                                         
                                         NSLog(@"address dictionary: %@", placemark.addressDictionary);
                                         
                                         NSArray *formattedAddressLines = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
                                         
                                         NSString *fullAddress = [formattedAddressLines componentsJoinedByString:@", "];
                                         
                                         itemBusinessAddress.text = [fullAddress capitalizedString];
                                         
                                         
                                    }
                                 }];
                                
                            }else{
                                
                                if([businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE2] isEqualToString:@""]){
                                    NSString *fullAddress = [NSString stringWithFormat:@"%@, %@, %@, %@, %@",
                                                             businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE1],
                                                          //   businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE2],
                                                             businessLocation[FIELD_BUSINESSLOCATION_SUBURB],
                                                             businessLocation[FIELD_BUSINESSLOCATION_STATE],
                                                             businessLocation[FIELD_BUSINESSLOCATION_COUNTRY],
                                                             businessPhoneNumber];
                                    
                                    itemBusinessAddress.text = [fullAddress capitalizedString];
                                    NSLog(@"address line : %@", fullAddress);
                                }
                                else{
                                    NSString *fullAddress = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@",
                                                             businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE1],
                                                             businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE2],
                                                             businessLocation[FIELD_BUSINESSLOCATION_SUBURB],
                                                             businessLocation[FIELD_BUSINESSLOCATION_STATE],
                                                             businessLocation[FIELD_BUSINESSLOCATION_COUNTRY],
                                                             businessPhoneNumber];
                                    
                                    itemBusinessAddress.text = [fullAddress capitalizedString];
                                    NSLog(@"address line : %@", fullAddress);
                                }
                                
                                
                                
                            }
                            
                            
                            CLLocation *currentLocation = DELEGATE.locationManager.location;
                            
                            // calculate distance
                            CLLocationDistance distance = [currentLocation distanceFromLocation:dealLocation];
                            
                            NSLog(@" distance : %f m ", distance);
                            if(distance < 1000){
                                itemDistanceKM.text = [NSString stringWithFormat:@"Only %.2f meters from your current location", distance];
                            }else{
                                distance = distance/1000;
                                
                                itemDistanceKM.text = [NSString stringWithFormat:@"Only %.2f KM from your current location", distance];
                            }
                            
                            

                        }
                    }else{
                        NSLog(@"error ayo... error: %@", [error userInfo]);
                    }
                    
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                }];
            }
        }else{
             NSLog(@"error ayo... error: %@", [error userInfo]);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }];
    
}




#pragma mark - IBActions

- (IBAction)didPressEditButton:(id)sender {
    
// maintained by shouldPerformSegueWithIdentifier method
    
}

- (IBAction)didPressBackButton:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressFavDealButton:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"setting fav deal, current deal: %@", deal);
        
        NSMutableArray *favDeals = [currentUser[FIELD_USER_FAVORITE_DEALS] mutableCopy];
        NSLog(@" list of fav deals array; %@", favDeals);
     
        if ([favDeals count]) {
            
            NSInteger anIndex = NSNotFound;
            for (int i=0; i< [favDeals count]; i++) {
                PFObject *favDeal = [favDeals objectAtIndex:i];
                
                if ([favDeal.objectId isEqualToString:deal.objectId]) {
                    anIndex = (NSInteger) i;
                    break;
                }
            }
            
            if(NSNotFound == anIndex) {
                NSLog(@"index not found, so add favorite deal");
                
                [favDeals addObject:deal];
                currentUser[FIELD_USER_FAVORITE_DEALS] = favDeals;
                [currentUser saveInBackground];
                isDealFavorite = YES;
                [self setFavDealIcon];
                
            }else{
                NSLog(@"array index of fav deal object: %d, remove it",anIndex);
                [favDeals removeObjectAtIndex:anIndex];
                currentUser[FIELD_USER_FAVORITE_DEALS] = favDeals;
                [currentUser saveInBackground];
                isDealFavorite = NO;
                [self setFavDealIcon];
            }
            
        }else{
            // no data found, simply add fav business
            currentUser[FIELD_USER_FAVORITE_DEALS] = [NSArray arrayWithObjects:deal, nil];
            [currentUser saveInBackground];
            isDealFavorite = YES;
            [self setFavDealIcon];
            
        }
        
        [currentUser refresh];
    }else{
         [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Please login to favorite a deal"];
    }
    
}

- (IBAction)didPressFavBizButton:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"setting fav business..");
        
        NSMutableArray *favBusinesses = [currentUser[FIELD_USER_FAVORITE_BUSINESSES] mutableCopy];
        if ([favBusinesses count]) {
            
            PFObject *dealOwner = deal[FIELD_DEAL_OWNER];
            NSInteger anIndex = NSNotFound;
            for (int i=0; i< [favBusinesses count]; i++) {
                PFObject *favBiz = [favBusinesses objectAtIndex:i];
                if ([favBiz.objectId isEqualToString:dealOwner.objectId]) {
                    anIndex = (NSInteger) i;
                    break;
                }
            }

            
            if(NSNotFound == anIndex) {
                NSLog(@"index not found, so add favorite business");
                [favBusinesses addObject:dealOwner];
                currentUser[FIELD_USER_FAVORITE_BUSINESSES] = favBusinesses;
                [currentUser saveInBackground];
                isBizFavorite = YES;
                [self setFavBizIcon];
                
            }else{
                NSLog(@"array index of fav business object: %d, remove it",anIndex);
                [favBusinesses removeObjectAtIndex:anIndex];
                currentUser[FIELD_USER_FAVORITE_BUSINESSES] = favBusinesses;
                [currentUser saveInBackground];
                isBizFavorite = NO;
                [self setFavBizIcon];
            }
            
        }else{
            // no data found, simply add fav business
            currentUser[FIELD_USER_FAVORITE_BUSINESSES] = [NSArray arrayWithObjects:deal[FIELD_DEAL_OWNER], nil];
            [currentUser saveInBackground];
            isBizFavorite = YES;
            [self setFavBizIcon];
            
        }
        [currentUser refresh];
    }
    else{
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Please login to favorite a business"];
    }
}

- (IBAction)didPressShareButton:(id)sender {
    
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Message", @"Email", nil];
    actionSheet.tag=1;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];

    
}

-(void)showRatingActionsheet
{
     actionSheet = [[UIActionSheet alloc]
                              initWithTitle:@"Rate the deal"
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                              otherButtonTitles:@"\ue32f",@"\ue32f \ue32f",@"\ue32f \ue32f \ue32f ",@"\ue32f \ue32f \ue32f \ue32f ",@"\ue32f \ue32f \ue32f \ue32f \ue32f",nil];
    
//    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:0] setImage:[UIImage imageNamed:@"oneStar.png"] forState:UIControlStateNormal];
//    
//    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:1] setImage:[UIImage imageNamed:@"twoStar.png"] forState:UIControlStateNormal];
//    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:2] setImage:[UIImage imageNamed:@"threeStar.png"] forState:UIControlStateNormal];
//    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:3] setImage:[UIImage imageNamed:@"fourStar.png"] forState:UIControlStateNormal];
//    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:4] setImage:[UIImage imageNamed:@"fiveStar.png"] forState:UIControlStateNormal];
//    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:5] setImage:[UIImage imageNamed:@"fiveStar.png"] forState:UIControlStateNormal];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];

}

- (IBAction)didPressStarButton:(id)sender {
    

    
    [self showRatingActionsheet];
    
}

-(void)rateDealwithValue:(int )ratingValue
{
        PFUser *currentUser = [PFUser currentUser];
        if (!currentUser){
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"You need to login to rate this deal. Please go to settings tab and login."];
            return;
        }
    
    
    
    //    [self makeRateTheDealUXWithRating:(int)button.tag];
    
        // save rating to parse
    
        if (!ratingObject) {
            ratingObject = [PFObject objectWithClassName:PARSE_CLASS_RATING];
        }
    
        ratingObject[FIELD_RATING_RATE] = [NSNumber numberWithInteger:ratingValue];
        ratingObject[FIELD_RATING_USER] = currentUser;
        ratingObject[FIELD_RATING_DEAL] = deal;
    
        [ratingObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // calculate the average ratings for this deal
                [parseOperations calculateAndSaveRatingsForADeal:deal];
    
            }
        }];
}

- (IBAction)didPressGetDirectionButton:(id)sender {
    
    NSLog(@"get direction pressed");
    
    if (businessLocationPoint.latitude == 0 || businessLocationPoint.longitude == 0) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Deal Location not found."];
        return;
    }
    
    CLLocation *currentLocation = DELEGATE.locationManager.location;
    
   
    
//    NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude ,businessLocationPoint.latitude, businessLocationPoint.longitude];
   
     // appple map is not finding direction properly, so as an alternative google map is used.
    
    NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude ,businessLocationPoint.latitude, businessLocationPoint.longitude];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    
}

- (IBAction)didPressCloseButton:(id)sender
{
    
   [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)makeRateTheDealUXWithRating:(int)rate{
    [oneStarButton setImage:[UIImage imageNamed:@"selected_rate.png"] forState:UIControlStateNormal];

//    switch (rate) {
//        case 1:
//            [oneStarButton setImage:[UIImage imageNamed:@"selected_rate.png"] forState:UIControlStateNormal];
//            [twoStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            [threeStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            [fourStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            [fiveStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            break;
//            
//        case 2:
//            [oneStarButton setImage:[UIImage imageNamed:@"selected_rate.png"] forState:UIControlStateNormal];
//            [twoStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            [threeStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            [fourStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            [fiveStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            break;
//            
//        case 3:
//            [oneStarButton setImage:[UIImage imageNamed:@"selected_rate.png"] forState:UIControlStateNormal];
//            [twoStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            [threeStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            [fourStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            [fiveStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            break;
//            
//        case 4:
//            [oneStarButton setImage:[UIImage imageNamed:@"selected_rate.png"] forState:UIControlStateNormal];
//            [twoStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            [threeStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            [fourStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            [fiveStarButton setImage:[UIImage imageNamed:@"greyStar.png"] forState:UIControlStateNormal];
//            break;
//            
//        case 5:
//            [oneStarButton setImage:[UIImage imageNamed:@"selected_rate.png"] forState:UIControlStateNormal];
//            [twoStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            [threeStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            [fourStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            [fiveStarButton setImage:[UIImage imageNamed:@"blueStar.png"] forState:UIControlStateNormal];
//            break;
//            
//        default:
//            break;
//    }
    
}



-(void)averageRatingForADeal:(NSNumber *)rating{
    
    int rate = [rating intValue];
    float Rting=[rating floatValue];
    _itemRatingLabel.text=[NSString stringWithFormat:@"%.1f", Rting];
    switch (rate) {
        case 0:
            [topRatingImageView setImage:[UIImage imageNamed:@"zeroStar.png"]];
            break;
        case 1:
            [topRatingImageView setImage:[UIImage imageNamed:@"oneStar.png"]];
            break;
            
        case 2:
            [topRatingImageView setImage:[UIImage imageNamed:@"twoStar.png"]];
            break;
            
        case 3:
            [topRatingImageView setImage:[UIImage imageNamed:@"threeStar.png"]];
            break;
            
        case 4:
            [topRatingImageView setImage:[UIImage imageNamed:@"fourStar.png"]];
            break;
            
        case 5:
            [topRatingImageView setImage:[UIImage imageNamed:@"orange-stars.png"]];
            break;
            
        default:
            break;
    }
    
}

- (BOOL) isTwitterAvailable {
    if( NSClassFromString(@"SLComposeViewController") != nil ) {
        return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    }
    return NO;
}

- (BOOL) isFacebookAvailable {
    if( NSClassFromString(@"SLComposeViewController") != nil ) {
        return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
    }
    return NO;
}

#pragma mark - Actionsheet delegate

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"did dismiss with button at index: %ld", (long)buttonIndex);
    if (actionSheet.tag==1)
    {
        if (buttonIndex != 4)
        {
            
            PFQuery *socialQuery = [PFQuery queryWithClassName:PARSE_CLASS_SOCIAL];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [socialQuery findObjectsInBackgroundWithBlock:^(NSArray *messages, NSError *error) {
                if (!error) {
                    if ([messages count]) {
                        PFObject *message = [messages objectAtIndex:0];
                        
                        //                    NSString *facebookMessage = message[FIELD_SOCIAL_FACEBOOK_MESSAGE];
                        //                    NSString *twitterMessage = message[FIELD_SOCIAL_TWITTER_MESSAGE];
                    
                    // NSString *smsMessage = message[FIELD_SOCIAL_TEXT_MESSAGE];
                        
                        NSString *smsMessage=@"Hey there! I found this deal in TapDeal, Check it out";
                        //                    NSString *emailMessage = message[FIELD_SOCIAL_EMAIL_MESSAGE];
                        NSString *appStoreURL = message[FIELD_SOCIAL_APP_STORE_URL];
                        
                        
                        if (buttonIndex == 0) {
                            [self facebookShare:appStoreURL];
                        }
                        else if (buttonIndex == 1){
                            [self twitterShare:appStoreURL];
                        }
                        else if (buttonIndex == 2){
                            
                            NSString *smsText=[NSString stringWithFormat:@" %@ \n %@",smsMessage,appStoreURL];
                           
                            NSLog(@"%@",smsText);
                            
                            [self textMessage:smsText];
                        }
                        else if (buttonIndex == 3){
                            [self email:appStoreURL];
                        }
                        
                    }else{
                        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Problem sharing the deal. Please try later."];
                    }
                }else{
                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Problem sharing the deal. Please try later."];
                }
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
            }];
            
            
        }
        
    }
    else
    {
        int rating=1;
        if (buttonIndex<=4) {
            rating=buttonIndex+1;
        }
        [self rateDealwithValue:rating];
    }

    
}


#pragma mark - social sharing

-(void)facebookShare:(NSString*) appStoreURL{
    
    if ( [self isFacebookAvailable] == NO ) {
        // Tell the user that his version iOS is too old and does not support Twitter.
        // Or don't show him the Twitter button in the first place.
        NSLog(@"Facebook is not available.");
        [[[UIAlertView alloc] initWithTitle:@"Sign in Settings for Facebook required" message:@"Please go to iOS Settings -> Facebook, and Sign In" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        return;
    }
    
    
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                    UIAlertView *alertfb = [[UIAlertView alloc] initWithTitle:@"TapDeal" message:@"Successfully posted on Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertfb show];
                }
                    break;
            }};
        
        
         //adding image on post
        PFFile  *snapshot= deal[@"imageFile"];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [snapshot getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *snapImage = [UIImage imageWithData:imageData];
                [fbController addImage:snapImage];
                
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
        NSString *Text=[NSString stringWithFormat:@"Great deal on %@ via TapDeal!",deal[FIELD_DEAL_ITEM_NAME]];
        
        [fbController setInitialText:Text];
        
        NSURL *url = [NSURL URLWithString:appStoreURL];
        [fbController addURL:url];
        
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    }
    
}

-(void)twitterShare:(NSString*) appStoreURL{
    
    if ( [self isTwitterAvailable] == NO ) {
        // Tell the user that his version iOS is too old and does not support Twitter.
        // Or don't show him the Twitter button in the first place.
        NSLog(@"Twitter is not available.");
        [[[UIAlertView alloc] initWithTitle:@"Sign in Settings for Twitter required" message:@"Please go to iOS Settings -> Twitter, and Sign In" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        return;
    }
    
    
    SLComposeViewController *cvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    cvc.completionHandler = ^(SLComposeViewControllerResult result) {
        // This can be called on ANY thread, so be save and sync with UI thread if you need to access UI elements
        if( result == SLComposeViewControllerResultDone ) {
            // The tweet was sent
            NSLog(@"success");
            UIAlertView *alertTwitter = [[UIAlertView alloc] initWithTitle:@"TapDeal" message:@"Successfully tweeted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertTwitter show];
        } else {
            // The user canceled the action.
            // This can happen before the View gets closed when there are no accounts
            // and the user does not want to create an account.
            NSLog(@"failure");
        }
    };
    
    //adding image on post
    PFFile  *snapshot= deal[@"imageFile"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [snapshot getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *snapImage = [UIImage imageWithData:imageData];
            [cvc addImage:snapImage];
            
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    
    NSURL *url = [NSURL URLWithString:appStoreURL];
    [cvc addURL:url];
    NSString *Text=[NSString stringWithFormat:@"Great deal on %@ via TapDeal!",deal[FIELD_DEAL_ITEM_NAME]];
    [cvc setInitialText:Text];
    [self presentViewController:cvc animated:YES completion:nil];

}

-(void)textMessage:(NSString*) text{
    
    MFMessageComposeViewController *messageComposerViewController = [MFMessageComposeViewController new];
    if (![MFMessageComposeViewController canSendText]) {
        NSLog(@"device can not send sms");
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"This device can not send sms message"];
    }
    else
    {
        
        messageComposerViewController.body = text;
        messageComposerViewController.messageComposeDelegate = self;
        
        [self presentViewController:messageComposerViewController animated:YES completion:nil];
    }
    
    
}

-(void)email:(NSString*) appStoreURL{
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSString *subject = [NSString new];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        subject = [NSString stringWithFormat:@" %@ shared a deal with you via TapDeal", currentUser[FIELD_USER_FULLNAME]];
    }else{
        subject = [NSString stringWithFormat:@"Sharing a deal with you via TapDeal"];
    }
    
    // get snapshot image URL
//    PFFile  *snapshot= deal[FIELD_DEAL_SNAPSHOT];
//    NSString *snapshotURL = [NSString stringWithFormat:@"<img src=\"%@\" alt=\"%@\" />", snapshot.url, deal[FIELD_DEAL_ITEM_NAME]];
    
    NSString *appURL = [NSString stringWithFormat:@"tapdeal://?dealid=%@", deal.objectId];
    
    NSString *content = @"<p style=\"color:#1a63a7;\" >I think you will be interested!!</p>";
    
    
    NSString *dealContent = [self getDealEmailTemplateInHTML];
    
    content = [NSString stringWithFormat:@"%@ %@<br/>To view this deal on %@, <a href=\"%@\">click me</a> to download the application. If you have %@ installed in your iPhone then <a href=\"%@\">click here</a>", dealContent, content, APPLICATION_NAME, appStoreURL, APPLICATION_NAME, appURL];
    
    [picker setSubject:subject];
    
    // Set up the recipients.
//    NSArray *toRecipients = [NSArray arrayWithObjects:@"first@example.com", nil];
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
//    NSArray *bccRecipients = [NSArray arrayWithObjects:@"four@example.com", nil];
    
//    [picker setToRecipients:toRecipients];
//    [picker setCcRecipients:ccRecipients];
//    [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email.
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"ipodnano"
//                                                     ofType:@"png"];
//    NSData *myData = [NSData dataWithContentsOfFile:path];
//    [picker addAttachmentData:myData mimeType:@"image/png"
//                     fileName:@"ipodnano"];
    
    // Fill out the email body text.
    [picker setMessageBody:content isHTML:YES];
    
    // Present the mail composition interface if email has been set up in Settings
    
    if ([MFMailComposeViewController canSendMail]) {
        [self presentViewController:picker animated:YES completion:nil];
    }
    
    
}


#pragma mark - Mail composer delegate

// The mail compose view controller delegate method



- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    //handle any error
    if(result){
        UIAlertView *alertEmail = [[UIAlertView alloc] initWithTitle:@"TapDeal" message:@"Email Sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertEmail show];
        
    };
    
    if(error){
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:@"TapDeal" message:@"error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertError show];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - SMS Message composer delegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller
                didFinishWithResult:(MessageComposeResult)result{
    if(result){
        UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"TapDeal" message:@"Message Sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertMessage show];
    };
    
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark preview delegate method

-(void)dismissDealDetailView{
    
    NSLog(@"delegate : dismissDealDetailView fired");
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark email template

-(NSString *)getDealEmailTemplateInHTML{
    
    // deal item URL
    PFFile *img = deal[FIELD_DEAL_IMAGE_FILE];
    
    // deal location
    NSString *locationLatLng = [NSString stringWithFormat:@"%f, %f", dealLocation.coordinate.latitude, dealLocation.coordinate.longitude];
    
    // contruct ratings html
    NSString *rate = @"";
    
    int i = 0;
    for (; i < [deal[FIELD_DEAL_ITEM_AVERAGE_RATE] intValue]; i++) {
        rate = [NSString stringWithFormat:@"%@ <img src=\"http://files.parsetfss.com/38a725db-bb8d-4678-8962-ef03b75db677/tfss-ff16854b-aa18-49b4-ba8a-f7224a023593-blueStar.png\"  style=\"float:left; margin-left:10px\" width=15 />", rate];
    }
    
    for (int j = i; j < 5; j++) {
        rate = [NSString stringWithFormat:@"%@ <img src=\"http://files.parsetfss.com/38a725db-bb8d-4678-8962-ef03b75db677/tfss-69235cc5-97ea-41f6-a238-7e964a8fb53a-outlinedStar.png\"  style=\"float:left; margin-left:10px\" width=15 />", rate];
    }
    
    NSString *content = [NSString stringWithFormat:@"                           \
                         <div style=\"width: 320px; border:1px solid #000;\">   \
                         <div style=\"position: relative;\">                    \
                         <img src=\"%@\"  width=\"320\" /> \
                         <div style=\"opacity:0.4; background-color: #fff; width: 320px; height: 57px; z-index:9; position: absolute; top:143px;\"> </div> \
                         <div style=\"top:155px; width: 320px; z-index:99; position: absolute;\"> \
                         <span style=\"color: #1a63a7; margin-left: 10px; font-size: 14px; font-weight:bold\">%@</span> \
                         </div> \
                         <div style=\"top:180px; width: 320px; z-index:99; position: absolute;\"> \
                         \
                         %@   \
                         \
                         </div> \
                         </div> \
                         <div style=\"clear:both;\"></div> \
                         <div style=\"width: 220px; float:left; height: 62px; \"> \
                         <p style=\"color: #323232; font-size: 14px; padding: 5px 0 0 20px; margin-top: 0\">%@</p> \
                         </div> \
                         <div style=\"float: right; width: 70px; height: 40px; padding: 5px 20px 0 0;\"> \
                         <span style=\"color:	#1a63a7; float:right\">%@</span> \
                         <br/> \
                         <span style=\"color: #323232; font-size: 10px; float:right\">%@</span> \
                         </div> \
                         <div style=\"clear:both; padding:5px 20px\"> \
                         <p style=\"color:#1a63a7; font-size: 11px\">%@</p> \
                         <p style=\"color:#1a63a7; font-size: 11px\">16.67 m</p> \
                         <p style=\"color:#1a63a7; font-size: 11px\">%@</p> \
                         </div> \
                         <div> \
                         <img src=\"http://files.parsetfss.com/38a725db-bb8d-4678-8962-ef03b75db677/tfss-7e50fb38-a4ac-449d-afb8-3e6973a907f4-share.png\" /> \
                         <img src=\"http://maps.googleapis.com/maps/api/staticmap?center=%@&size=320x200&zoom=13&maptype=roadmap&markers=color:red%%7Clabel:S%%7C%@  \" /> \
                         <img src=\"http://files.parsetfss.com/38a725db-bb8d-4678-8962-ef03b75db677/tfss-91619c81-093a-4025-a5c6-a84f6af4c5ac-tabBar.png\" /> \
                         </div> \
                         </div> ",
                         img.url,
                         itemTitle.text,
                         rate,
                         itemDescription.text,
                         itemDealPrice.text,
                         itemOriginalPrice.text,
                         itemValidUntilDate.text,
                         itemBusinessAddress.text,
                         locationLatLng,
                         locationLatLng
                         
                         ];
    
    return content;
    
}

@end

//
//  DealPreviewViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/15/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "DealPreviewViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "SharedStore.h"

#import "UIImage+Custom.h"
#import "UILabel+Custom.h"
#import "UIButton+Custom.h"
#import "UITextView+Custom.h"
#import "UIView+Rounded.h"


#import <MBProgressHUD/MBProgressHUD.h>


@interface DealPreviewViewController ()<MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

// properties
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *point;

@property (nonatomic, strong) PFObject *businessLocation;
@property (nonatomic, strong) PFObject *businessOwner;

@property (nonatomic, strong) NSArray *dealSearchKeywords;

// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UIImageView *topRatingImageView;

@property (weak, nonatomic) IBOutlet UITextView *itemDescription;
@property (weak, nonatomic) IBOutlet UITextView *itemBusinessAddress;
@property (weak, nonatomic) IBOutlet UILabel *itemRatingLabel;


@property (weak, nonatomic) IBOutlet UILabel *itemDealPrice;
//@property (weak, nonatomic) IBOutlet UILabel *itemRatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemOriginalPrice;
@property (weak, nonatomic) IBOutlet UILabel *itemValidUntilDate;

@property (weak, nonatomic) IBOutlet UILabel *itemDistanceKM;


@property (weak, nonatomic) IBOutlet UIImageView *bottomRatingImageView;

@property (weak, nonatomic) IBOutlet UILabel *favDealLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favDealIcon;

@property (weak, nonatomic) IBOutlet UILabel *favBizLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favBizIcon;

@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shareIcon;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *getDirectionButton;

@property (weak, nonatomic) IBOutlet UILabel *rateThisDealLabel;




// IBActions
- (IBAction)didPressBackButton:(id)sender;

- (IBAction)didPressPostButton:(id)sender;

@end

@implementation DealPreviewViewController

@synthesize deal, dealSearchKeywords;

@synthesize scrollView, backButton, itemImageView, shadowView, itemTitle;

@synthesize topRatingImageView, itemDescription, itemDealPrice, itemOriginalPrice;

@synthesize itemValidUntilDate, itemDistanceKM, itemBusinessAddress, bottomRatingImageView;

@synthesize favDealIcon, favBizIcon, shareIcon, shareLabel, favBizLabel, favDealLabel, rateThisDealLabel;

@synthesize postButton, navBarTitleLabel, getDirectionButton;
@synthesize businessLocation, businessOwner, dealImage;
@synthesize locationManager, point, mapView;

@synthesize delegate;


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
    [postButton setEnabled:NO]; // button will be enable if user found and user has business and business has some address.
    
    [self resetScrollView];
    
    [self populateData];
    
//    [self customizeView];
    [UIView setRoundedBorder:_itemRatingLabel.layer withWidth:0.4 borderColor:[UIColor grayColor] andRadius:4.0];

    [self prepareDealsKeywords];
    
    // Do any additional setup after loading the view.
    
    NSLog(@"new deal: %@", self.deal);
    
    
    
    // getting business address
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // checking if the user has already created business
        PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
        [query whereKey:FIELD_BUSINESS_DEALER equalTo:currentUser];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"If user has a business: %lu", (unsigned long)objects.count);
                
                if ([objects count] > 0) {
                    

                    for (PFObject *business in objects) {
                        NSLog(@"Business object: %@", business);
                        
                        businessOwner = business;
                        
                        deal[FIELD_DEAL_OWNER] = businessOwner;
                        
                        NSArray *locations = business[FIELD_BUSINESS_BUSINESSLOCATIONS];
                        
                        NSLog(@"business locations: %@", locations);
                        PFObject *location = [locations objectAtIndex:0];
                        
                        PFQuery *businessLocationQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS_LOCATION];
                        [businessLocationQuery whereKey:@"objectId" equalTo:location.objectId];
                        
                        [businessLocationQuery findObjectsInBackgroundWithBlock:^(NSArray *businessLocationObjects, NSError *innerError) {
                            
                            if (!innerError) {
                                if ([businessLocationObjects count] > 0) {
                                    NSLog(@"found business location: %@", businessLocationObjects);
                                    
                                    for (PFObject *businessLocationObject in businessLocationObjects) {
                                        self.businessLocation = businessLocationObject;
                                        [postButton setEnabled:YES];
                                        
                                        
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [self populateAddress];
                                        
                                        // currently it should contain only one business location
                                        break; // breaking the loop
                                    }
                                }else{
                                    // this will never happen theoritically but if the cloud data deleted accidentally, it may happen.
                                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Something went wrong. You can not post a deal"];
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                }
                            }else{
                                NSLog(@"error occurred: %@", [error userInfo]);
                            }
                           
                        }];
                        
                        
                        // currently it should contain only one business
                        break; // breaking the loop
                        
                    }
                    
                }else{
                    
                    // this will never happen theoritically but if the cloud data deleted accidentally, it may happen.
                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Something went wrong. You can not post a deal"];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
                
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.locationManager = DELEGATE.locationManager;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    
    
    CLLocation *currentLocation = self.locationManager.location;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1800, 1800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    point.coordinate = currentLocation.coordinate;
    //    point.title = @"Where am I?";
    //    point.subtitle = @"I'm here!!!";
    
    [self.mapView addAnnotation:point];
    
}

// this is required to make scroll view scrollable
- (void)viewDidLayoutSubviews {
    [scrollView setContentSize:CGSizeMake(320, 720)];
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

#pragma mark - custom methods

-(void)resetScrollView{
    
    scrollView.scrollEnabled = YES;
    [scrollView setContentSize:CGSizeMake(320, 580)];
    
    CGRect frame = self.scrollView.frame;
    
//    frame.size = CGSizeMake(320, ScreenSize.height - 64);
    
    [self.scrollView setFrame:frame];
    NSLog(@"scroll view height: %f", scrollView.frame.size.height);
}


-(void)customizeView{
    
    // modify fonts here
    [itemTitle setNormalFont];
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
    [postButton setCustomFont];
    [getDirectionButton setCustomFont];
    [rateThisDealLabel setNormalFont];
    
}

-(void) populateAddress{
    itemBusinessAddress.text = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@",
                                businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE1],
                                businessLocation[FIELD_BUSINESSLOCATION_ADDRESSLINE2],
                                businessLocation[FIELD_BUSINESSLOCATION_SUBURB],
                                businessLocation[FIELD_BUSINESSLOCATION_STATE],
                                businessLocation[FIELD_BUSINESSLOCATION_COUNTRY],
                                businessLocation[FIELD_BUSINESSLOCATION_PHONE]];
    if(businessLocation)
    {
      PFGeoPoint  *businessLocationPoint = businessLocation[FIELD_BUSINESSLOCATION_LOCATION_POINT];
        CLLocation *dealLocation=[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(businessLocationPoint.latitude, businessLocationPoint.longitude) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:0 timestamp:[NSDate date]];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(dealLocation.coordinate, 1800, 1800);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
        MKPointAnnotation *mapPoint = [[MKPointAnnotation alloc] init];
        mapPoint.coordinate =  dealLocation.coordinate;
        //    point.title = @"Where am I?";
        //    point.subtitle = @"I'm here!!!";
        
        [self.mapView addAnnotation:mapPoint];
        self.mapView.layer.borderWidth=1.0;
        self.mapView.layer.borderColor=(__bridge CGColorRef)([UIColor darkGrayColor]);
        


    }

    // currently snapshot is dropped
    //[self takeSnapshot];  // take snapshot of the deal and save it

}

-(void)takeSnapshot{
    
    UIGraphicsBeginImageContextWithOptions(DELEGATE.window.bounds.size, NO, [UIScreen mainScreen].scale);
    [DELEGATE.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    NSData * data = UIImagePNGRepresentation(image);
    
    NSString *imageName = [NSString stringWithFormat:@"snap_%@.png", deal[FIELD_DEAL_ITEM_NAME]];
    PFFile *snapshotFile = [PFFile fileWithName:imageName data:data];
    deal[FIELD_DEAL_SNAPSHOT] = snapshotFile;

    
}

-(void)populateData{
    
    // scaling and cropping image
    
    UIImage *croppedImage = [dealImage scaleAndCropWithSize:CGSizeMake(640, 400)];
    itemImageView.image = croppedImage;
    
     NSLog(@"MyImage size of cropped image in bytes:%i",[UIImagePNGRepresentation(croppedImage) length]);
    NSData *imageData = UIImagePNGRepresentation(croppedImage);
    int rndValue = arc4random() % 1000;
    NSLog(@"random value: %d", rndValue);
    NSString *imageName = [NSString stringWithFormat:@"_%@_%d.png", deal[FIELD_DEAL_DEAL_PRICE], rndValue];
    NSLog(@"image name: %@", imageName);
    
    PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
    
    deal[FIELD_DEAL_IMAGE_FILE] = imageFile;
    
    itemDealPrice.adjustsFontSizeToFitWidth=YES;
    itemTitle.text = [deal[FIELD_DEAL_ITEM_NAME] capitalizedString];
    
    itemDescription.text = [deal[FIELD_DEAL_ITEM_DESCRIPTION] capitalizedString];
    
    
    
    NSString *dealPrice=[NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    if([dealPrice containsString:@"."]){
        itemDealPrice.text= [NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_DEAL_PRICE] floatValue]];
    }
    else{
        itemDealPrice.text = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    }
    
  //  itemDealPrice.text = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_DEAL_PRICE]];
    
    
    NSString *dealOldPrice=[NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    if([dealOldPrice containsString:@"."]){
        dealOldPrice = [NSString stringWithFormat:@"$%.2f", [deal[FIELD_DEAL_ORIGINAL_PRICE] floatValue]];
    }
    else{
        dealOldPrice = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    }
    
    
  //  NSString *dealOldPrice = [NSString stringWithFormat:@"$%@", deal[FIELD_DEAL_ORIGINAL_PRICE]];
    
    itemOriginalPrice.attributedText=[[SharedStore store]strkiethroughLabel:dealOldPrice];    [itemOriginalPrice strikeThrough];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy, hh:mm a"];
    
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *validToDate = [dateFormatter stringFromDate:deal[FIELD_DEAL_VALID_TO]];
    
    itemValidUntilDate.text =[NSString stringWithFormat:@"Valid until %@", validToDate];
}


-(void)disableButtons
{
    
    
}

#pragma mark - IBActions

- (IBAction)didPressBackButton:(id)sender {
    self.locationManager.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressPostButton:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [deal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"deal posted...");
            self.locationManager.delegate = nil;
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [self.delegate dismissDealDetailView];
            
        }else{
            NSString *errorMessage = [NSString stringWithFormat:@"Error occured while posting deal. %@", [error userInfo]];
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage: errorMessage];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


-(void)prepareDealsKeywords{
    
   NSMutableArray *dealKeywords = [NSMutableArray new];
    
//    NSString *unfilteredString = @"!@#$%^&*()_+|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"] invertedSet];

    
    // deal item name
    NSArray *dealItemNameKeywords = [deal[FIELD_DEAL_ITEM_NAME] componentsSeparatedByString: @" "];
    for (NSString *token in dealItemNameKeywords) {
        NSString *unfilteredString = [token lowercaseString];
        NSString *resultString = [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        
        [dealKeywords addObject:resultString];
    }
    
    
    // deal item description
    NSArray *dealItemDescriptionKeywords = [deal[FIELD_DEAL_ITEM_DESCRIPTION] componentsSeparatedByString: @" "];
    for (NSString *token in dealItemDescriptionKeywords) {
        NSString *unfilteredString = [token lowercaseString];
        NSString *resultString = [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        
        [dealKeywords addObject:resultString];
    }
    
    // deal item tags
    NSArray *dealItemTagsKeywords = [deal[FIELD_DEAL_ITEM_TAG] componentsSeparatedByString: @" "];
    for (NSString *token in dealItemTagsKeywords) {
        NSString *unfilteredString = [token lowercaseString];
        NSString *resultString = [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        
        [dealKeywords addObject:resultString];
    }
    
    
    NSMutableArray *noDuplicateItems = [[[NSSet setWithArray: dealKeywords] allObjects] mutableCopy];
    
    NSLog(@"no duplicate item before removing stop words: %@", noDuplicateItems);
    
    NSArray *stopWords = [NSArray arrayWithObjects:@"and", @"on", @"at", @"in",@"a", @"the", @"of", @"an" , @"is", @"it", nil];
    
    for (int i=0; i< [stopWords count]; i++) {
        NSString *chunk = [stopWords objectAtIndex:i];
        
        NSInteger index = [noDuplicateItems indexOfObject:chunk];
        if (index != NSNotFound) {
            NSLog(@"stop word found: %@", chunk);
            [noDuplicateItems removeObjectAtIndex:index];
            
        }
    }
    
    dealSearchKeywords = [noDuplicateItems copy];
    
    NSLog(@"keywords: %@", dealSearchKeywords);
    
    deal[FIELD_DEAL_KEYWORD] = dealSearchKeywords;
    
    
}

#pragma mark -- Location manager delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    NSString *msg = [[NSString alloc] init];
    
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
                
            case kCLErrorDenied:
                msg = [NSString stringWithFormat:@"Location service is off for this application. Please go to Settings > Privacy > Location Services > switch on for %@", APPLICATION_NAME];
                break;
            case kCLErrorLocationUnknown:
                msg = @"Failed to Get Your Location";
                break;
            default:
                msg = @"Unknown Error for location service";
                break;
        }
        
    } else {
        // We handle all non-CoreLocation errors here
    }
    
    [DELEGATE showAlertViewWithTitle:@"Error" withMessage:msg];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *currentLocation = [locations objectAtIndex:[locations count] -1];
    [self.mapView removeAnnotation:point]; // remove old annotation
    
    //    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 800, 800);
    //    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    point.coordinate = currentLocation.coordinate;
    //    point.title = @"Where am I?";
    //    point.subtitle = @"I'm here!!!";
    
    [self.mapView addAnnotation:point];
    
}




#pragma mark - UITextFiled delegate

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 256, 0);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return YES;
}


@end

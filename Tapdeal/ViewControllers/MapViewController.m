//
//  MapViewController.m
//  Tapdeal
//
//  Created by Neetin on 7/10/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "SharedStore.h"

#import "FilterViewController.h"
#import "ParseOperations.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <WYPopoverController/WYPopoverController.h>
#import "JPSThumbnailAnnotation.h"
#import "CustomAnnotation.h"

#import "DealDetailsViewController.h"

@interface MapViewController ()<MKMapViewDelegate, CLLocationManagerDelegate, FilterViewDelegate, MKAnnotation>


// IBOutlets
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *allDealsButton;
@property (weak, nonatomic) IBOutlet UIButton *myDealsButton;



// IBActions
- (IBAction)didPressFilterButton:(id)sender;
- (IBAction)didPressAllDealsMyDealsButton:(id)sender;


// properties

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *point;
@property (nonatomic, strong) NSMutableArray *annotationsArray;

@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic, strong) ParseOperations *parseOperations;

@property (nonatomic, strong) NSArray *allDeals;

@property (nonatomic, strong) NSArray *myDeals;

@property (nonatomic, assign) BOOL isAllDealsButtonSelected;
@property (nonatomic, strong) NSString *activeUserObjectId;

@end

@implementation MapViewController

@synthesize mapView, navBarTitleLabel, locationManager, annotationsArray, point;

@synthesize filterButton, popover, parseOperations, allDeals, isAllDealsButtonSelected;

@synthesize allDealsButton, myDealsButton, myDeals, activeUserObjectId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        annotationsArray =[[NSMutableArray alloc]init];
    }
    return self;
}


//- (id)initWithRoutes:(PFGeoPoint *)userLocation todestination:(PFGeoPoint *)dealLocatiion
//{
//    
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    allDeals = [NSArray new];
    myDeals = [NSArray new];
    
    isAllDealsButtonSelected = YES;
    
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
    
    parseOperations = [ParseOperations sharedInstance];
    
    // fetch deals on start up
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [[ParseOperations sharedInstance] startUpFetchDealsInTheBackground:@0 withLimit:@1000];
    
    // just show all deals which have already been fetched on Deals tab
    
    allDeals = nil;
    allDeals = [parseOperations.allDeals copy];
    self.mapView.delegate = self;

    [self showDealsAnnotationsOnMapWithDeals:allDeals];


    
    self.locationManager = DELEGATE.locationManager;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        activeUserObjectId = currentUser.objectId;
    }
//    [self showDirection];
    [self showHideAllDealsMyDealsbuttons];
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:204/255. green:45/255. blue:70/255. alpha:1.0];
    polylineView.lineWidth = 10.0;
    
    return polylineView;
}

-(void)showHideAllDealsMyDealsbuttons{
    PFUser *currentUser = [PFUser currentUser];
    
    if (!currentUser) {
        allDealsButton.hidden = YES;
        myDealsButton.hidden = YES;
    }else{
        allDealsButton.hidden = NO;
        myDealsButton.hidden = NO;
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showDirection];
    filterButton.enabled=YES;
    CLLocation *currentLocation = self.locationManager.location;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 10000, 10000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    point.coordinate = currentLocation.coordinate;
    
    
    [self showHideAllDealsMyDealsbuttons];
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        if (![currentUser.objectId isEqualToString:activeUserObjectId]) {
            myDeals = nil;
            myDeals = [parseOperations.myDeals copy];
            
            if (!isAllDealsButtonSelected)
            {
                [self showDealsAnnotationsOnMapWithDeals:myDeals];
            }
            
            activeUserObjectId = currentUser.objectId;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didReceiveDealsFetchNotification: (NSNotification *) notification{
    
    if ([[notification name] isEqualToString:@"dealFetchNotification"]){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog (@"Successfully received the dealFetchNotification notification on map !");
        
        NSLog(@"fetched deals: %@", parseOperations.allDeals);
        
        if (isAllDealsButtonSelected) {
            allDeals = nil;
            allDeals = [parseOperations.allDeals copy];
            [self showDealsAnnotationsOnMapWithDeals:allDeals];
        }
    }
    
    if ([[notification name] isEqualToString:@"myDealFetchNotification"]){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog (@"Successfully received the myDealFetchNotification notification on map!");
        
        NSLog(@"fetched deals: %@", parseOperations.myDeals);
        
        
        if (!isAllDealsButtonSelected) {
            NSLog(@" isAllDealsButtonSelected not on notification ");
            
            if ([parseOperations.myDeals count]) {
                myDeals = nil;
                myDeals = [parseOperations.myDeals copy];
                [self showDealsAnnotationsOnMapWithDeals:myDeals];
            }
        }
    }
}



-(void) didReceiveDealsSearchNotification: (NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"dealsSearchNotification"]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog (@"Successfully received the dealsSearchNotification notification on map!");
        
        NSLog(@" dealsSearchNotification fetched deals: %@", parseOperations.allDealsSearch);
        
        if (isAllDealsButtonSelected) {
            NSLog(@" isAllDealsButtonSelected on notification ");
            allDeals = nil;
            allDeals = [parseOperations.allDealsSearch copy];
            [self showDealsAnnotationsOnMapWithDeals:allDeals];
        }
        
    }
    
    
    if ([[notification name] isEqualToString:@"myDealsSearchNotification"]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog (@"Successfully received the myDealsSearchNotification notification!");
        
        NSLog(@"fetched deals: %@", parseOperations.myDealsSearch);
        
        if (!isAllDealsButtonSelected) {
            NSLog(@" isAllDealsButtonSelected on notification ");
            if ([parseOperations.myDealsSearch count]) {
                
                myDeals = nil;
                myDeals = [parseOperations.myDealsSearch copy];
                [self showDealsAnnotationsOnMapWithDeals:myDeals];
            }
        }
        
    }
    
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    //    CLLocation *currentLocation = [locations objectAtIndex:[locations count] -1];
    
}


#pragma mark - IBActions

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


- (IBAction)didPressAllDealsMyDealsButton:(id)sender{
    UIButton *button = sender;
    
    // disable "All Deals" and "My Deals" button here and enable it on showDealsAnnotationsOnMapWithDeals method
    
    allDealsButton.enabled = NO;
    myDealsButton.enabled = NO;
    
    
    NSLog(@"didPressAllDealsMyDealsButton pressed, button tag; %ld", (long)button.tag);
    if (button.tag == 3) {
        
        // deals button pressed
        if(!isAllDealsButtonSelected){
            
            // make deal button selected
            [allDealsButton setBackgroundImage:[UIImage imageNamed:@"selectedLeft.png"] forState:UIControlStateNormal];
            [allDealsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            // unselect business button
            [myDealsButton setBackgroundImage:[UIImage imageNamed:@"unselectedRight.png"] forState:UIControlStateNormal];
            [myDealsButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
            
            allDeals = [parseOperations.allDeals copy];
            
            [self showDealsAnnotationsOnMapWithDeals:allDeals];
            isAllDealsButtonSelected = !isAllDealsButtonSelected;
        }
    }
    
    if (button.tag == 4) {
        
        // deals button pressed
        if(isAllDealsButtonSelected){
            
            // make deal button unselected
            [allDealsButton setBackgroundImage:[UIImage imageNamed:@"unselectedLeft.png"] forState:UIControlStateNormal];
            [allDealsButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
            
            // select business button
            [myDealsButton setBackgroundImage:[UIImage imageNamed:@"selectedRight.png"] forState:UIControlStateNormal];
            [myDealsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            myDeals = [parseOperations.myDeals copy];
            [self showDealsAnnotationsOnMapWithDeals:myDeals];
            
            isAllDealsButtonSelected = !isAllDealsButtonSelected;
        }
    }
    
}



#pragma mark - Custom methods

-
(void)getDirection
{
//    MKDirectionsRequest *directionrequest=[MKDirectionsRequest new];
//    MKMapItem *source=[MKMapItem mapItemForCurrentLocation];
//    
//    // Make the destination
//    CLLocationCoordinate2D destinationCoords = CLLocationCoordinate2DMake(27.703680700000000000, 85.322991300000010000);
//    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationCoords addressDictionary:nil];
//    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
//    // Set the source and destination on the request
//    [directionrequest setSource:source];
//    [directionrequest setDestination:destination];
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionrequest];
//    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//        // Handle the response here
//        // Now handle the result
//        if (error) {
//            NSLog(@"There was an error getting your directions");
//            return;
//        }
//        
//        // So there wasn't an error - let's plot those routes
//        _currentRoute = [response.routes firstObject];
//        [self plotRouteOnMap:_currentRoute];
//    }];
}


- (void)plotRouteOnMap:(MKRoute *)route
{
//    if(_routeOverlay) {
//        [self.mapView removeOverlay:_routeOverlay];
//    }
//    
//    // Update the ivar
//    _routeOverlay = route.polyline;
//    
//    // Add it to the map
//    [self.mapView addOverlay:_routeOverlay];
}

-(void)showDirection
{
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.location.coordinate, span);
        CLLocation *currentLocation = DELEGATE.locationManager.location;

    [mapView setRegion:region];
    
    [mapView setCenterCoordinate:mapView.userLocation.coordinate animated:YES];
    
    
//    NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude ,businessLocationPoint.latitude, businessLocationPoint.longitude];
    NSString *baseUrl = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude ,27.703680700000000000, 85.322991300000010000];
    
    NSURL *url = [NSURL URLWithString:[baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSError *error = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        NSArray *routes = [result objectForKey:@"routes"];
        
        NSDictionary *firstRoute = [routes objectAtIndex:0];
        
        NSDictionary *leg =  [[firstRoute objectForKey:@"legs"] objectAtIndex:0];
        
        NSDictionary *end_location = [leg objectForKey:@"end_location"];
        
        double latitude = [[end_location objectForKey:@"lat"] doubleValue];
        double longitude = [[end_location objectForKey:@"lng"] doubleValue];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = coordinate;
        point.title =  [leg objectForKey:@"end_address"];
        point.subtitle = @"I'm here!!!";
        
        [self.mapView addAnnotation:point];
        
        NSArray *steps = [leg objectForKey:@"steps"];
        
        int stepIndex = 0;
        
        CLLocationCoordinate2D stepCoordinates[1  + [steps count] + 1];
        
        stepCoordinates[stepIndex] = mapView.userLocation.coordinate;
        
        for (NSDictionary *step in steps) {
            
            NSDictionary *start_location = [step objectForKey:@"start_location"];
            stepCoordinates[++stepIndex] = [self coordinateWithLocation:start_location];
            
            if ([steps count] == stepIndex){
                NSDictionary *end_location = [step objectForKey:@"end_location"];
                stepCoordinates[++stepIndex] = [self coordinateWithLocation:end_location];
            }
        }
        
        MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:stepCoordinates count:1 + stepIndex];
        [mapView addOverlay:polyLine];
        
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((mapView.userLocation.location.coordinate.latitude + coordinate.latitude)/2, (mapView.userLocation.location.coordinate.longitude + coordinate.longitude)/2);
        
    }];
}


- (CLLocationCoordinate2D)coordinateWithLocation:(NSDictionary*)location
{
    double latitude = [[location objectForKey:@"lat"] doubleValue];
    double longitude = [[location objectForKey:@"lng"] doubleValue];
    
    return CLLocationCoordinate2DMake(latitude, longitude);
}

-(void)showDealsAnnotationsOnMapWithDeals:(NSArray *)deals
{
    [mapView removeAnnotations:mapView.annotations];
//    [annotationsArray removeAllObjects];
    annotationsArray =[[NSMutableArray alloc]init];

    if(deals != nil && [deals count])
    {
       
        for (int i=0;i<deals.count;i++)
        {
            PFObject *deal=[deals objectAtIndex:i];
            PFObject *owner = deal[FIELD_DEAL_OWNER];
            PFQuery *query  = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
            [query whereKey:@"objectId" equalTo:owner.objectId];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *businesses, NSError *error) {
                if (!error)
                {
                    NSLog(@" business detail: %@", businesses);
                    
                    if ([businesses count])
                    {
                        // find business location
                        PFObject *business = [businesses objectAtIndex:0];
                        
                        
                        NSArray *businessLocations = business[FIELD_BUSINESS_BUSINESSLOCATIONS];
                        
                        PFObject *businessLocation = [businessLocations objectAtIndex:0];
                        
                        NSLog(@"business location object : %@", businessLocation);
                        
                        PFQuery *locationQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS_LOCATION];
                        [locationQuery whereKey:@"objectId" equalTo:businessLocation.objectId];
                        
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        
                        [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *locations, NSError *error) {
                            if (!error)
                            {
                                NSLog(@"locations: %@",locations);
                                PFObject *location = [locations objectAtIndex:0];
                                
                                PFGeoPoint *dealPoint = location[FIELD_BUSINESSLOCATION_LOCATION_POINT];
                                
                                NSLog(@"geo point: %f, %f", dealPoint.latitude, dealPoint.longitude);
                                
                                
                                
                                CLLocationCoordinate2D coordinate;
                                coordinate.latitude = dealPoint.latitude;
                                coordinate.longitude = dealPoint.longitude;
                                
                                
                                CustomAnnotation *customAnnotation = [[CustomAnnotation alloc] initWithCoordinate:coordinate title:deal[FIELD_DEAL_ITEM_NAME] subTitle:deal[FIELD_DEAL_ITEM_DESCRIPTION] deal:deal];
                                //                                    NSSet *annotationSet = [myMapView annotationsInMapRect:myMapView.annotationVisibleRect];
                                [annotationsArray addObject:customAnnotation];
                                [self mutateCoordinatesOfClashingAnnotations:annotationsArray];
                                customAnnotation=[annotationsArray lastObject];
                                [mapView addAnnotation:(id)customAnnotation];
                            }
                            
                            // enable "All Deals" and "My Deals" button here
                            allDealsButton.enabled = YES;
                            myDealsButton.enabled = YES;
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            
                        }];
                    }
                    else{
                        
                        // enable "All Deals" and "My Deals" button here
                        allDealsButton.enabled = YES;
                        myDealsButton.enabled = YES;
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    }
                    
                    
                }
                else
                {
                    // enable "All Deals" and "My Deals" button here
                    allDealsButton.enabled = YES;
                    myDealsButton.enabled = YES;
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                }
            }];
        }
//        [mapView addAnnotations:mapAnnotations];
    }
    else
    {
        allDealsButton.enabled = YES;
        myDealsButton.enabled = YES;
    }
    }

#pragma mark - Mapview delegate

- (void)mutateCoordinatesOfClashingAnnotations:(NSArray *)annotations {
    
    NSDictionary *coordinateValuesToAnnotations = [self groupAnnotationsByLocationValue:annotations];
    
    for (NSValue *coordinateValue in coordinateValuesToAnnotations.allKeys) {
        NSMutableArray *outletsAtLocation = coordinateValuesToAnnotations[coordinateValue];
        if (outletsAtLocation.count > 1) {
            CLLocationCoordinate2D coordinate;
            [coordinateValue getValue:&coordinate];
            [self repositionAnnotations:outletsAtLocation toAvoidClashAtCoordination:coordinate];
        }
    }
}

- (NSDictionary *)groupAnnotationsByLocationValue:(NSArray *)annotations {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (id<MKAnnotation> pin in annotations) {
        
        CLLocationCoordinate2D coordinate = pin.coordinate;
        NSValue *coordinateValue = [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
        
        NSMutableArray *annotationsAtLocation = result[coordinateValue];
        if (!annotationsAtLocation) {
            annotationsAtLocation = [NSMutableArray array];
            result[coordinateValue] = annotationsAtLocation;
        }
        
        [annotationsAtLocation addObject:pin];
    }
    return result;
}



- (void)repositionAnnotations:(NSMutableArray *)annotations toAvoidClashAtCoordination:(CLLocationCoordinate2D)coordinate {
    
    double distance = 3 * annotations.count / 2.0;
    double radiansBetweenAnnotations = (M_PI * 2) / annotations.count;
    
    for (int i = 0; i < annotations.count; i++) {
        
        double heading = radiansBetweenAnnotations * i;
        CLLocationCoordinate2D newCoordinate = [self calculateCoordinateFrom:coordinate onBearing:heading atDistance:distance];
        
        id <MKAnnotation> annotation = annotations[i];
        annotation.coordinate = newCoordinate;
    }
}

- (CLLocationCoordinate2D)calculateCoordinateFrom:(CLLocationCoordinate2D)coordinate onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres {
    
    double coordinateLatitudeInRadians = coordinate.latitude * M_PI / 180;
    double coordinateLongitudeInRadians = coordinate.longitude * M_PI / 180;
    
    double distanceComparedToEarth = distanceInMetres / 6378100;
    
    double resultLatitudeInRadians = asin(sin(coordinateLatitudeInRadians) * cos(distanceComparedToEarth) + cos(coordinateLatitudeInRadians) * sin(distanceComparedToEarth) * cos(bearingInRadians));
    double resultLongitudeInRadians = coordinateLongitudeInRadians + atan2(sin(bearingInRadians) * sin(distanceComparedToEarth) * cos(coordinateLatitudeInRadians), cos(distanceComparedToEarth) - sin(coordinateLatitudeInRadians) * sin(resultLatitudeInRadians));
    
    CLLocationCoordinate2D result;
    result.latitude = resultLatitudeInRadians * 180 / M_PI;
    result.longitude = resultLongitudeInRadians * 180 / M_PI;
    return result;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
    
    MKAnnotationView *returnedAnnotationView = nil;

    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
//    static NSString *identifier = @"myAnnotation";
//    MKPinAnnotationView * annotationView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//    if (!annotationView)
//    {
//        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//        annotationView.animatesDrop = YES;
//        annotationView.canShowCallout = YES;
//        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    }else {
//        annotationView.annotation = annotation;
//    }
    
//    return annotationView;

    if ([annotation isKindOfClass:[CustomAnnotation class]])   
    {
        returnedAnnotationView = [CustomAnnotation createViewAnnotationForMapView:self.mapView annotation:annotation forDeal:[annotation deal]];
        
       returnedAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        // provide the left image icon for the annotation
//        UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon58.png"]];
//        returnedAnnotationView.leftCalloutAccessoryView = sfIconView;
    }
    
    return returnedAnnotationView;

}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:self.mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:self.mapView];
    }
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //    [self performSegueWithIdentifier:@"DetailsIphone" sender:view];
    NSLog(@"accessory button tapped for annotation %@", view.annotation);
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Tabs" bundle:nil];
    
    DealDetailsViewController *ddvc = [storyBoard instantiateViewControllerWithIdentifier:@"DealDetails"];
    
    CustomAnnotation *ca = view.annotation;
    ddvc.deal = ca.deal;
    
    [self.navigationController pushViewController:ddvc animated:YES];
}

#pragma mark - MapReposition delegate


#pragma mark - FilterView delegate

-(void)doSearch{
    
    [popover dismissPopoverAnimated:YES];
    
    if (isAllDealsButtonSelected) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [parseOperations getAllNearByBusinessesWithNewSearch:YES isLimit:NO isForAllDeal:NO];
        
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [parseOperations fetchMyDealsSearchInTheBackgroundWithDealIndex:@0 withLimit:@1000];
        
    }
    
}

@end

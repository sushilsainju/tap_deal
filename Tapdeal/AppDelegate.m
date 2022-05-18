//
//  AppDelegate.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 6/30/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "SharedStore.h"

#import "BusinessWelcomeScreenViewController.h"

#import "ParseOperations.h"

#import <TSMessages/TSMessage.h>

#import "DealDetailsViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) DealDetailsViewController *ddvc;

@end

@implementation AppDelegate
            
@synthesize locationManager, currentLocation;

@synthesize searchDictionary, ddvc;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:ParseAppID
                  clientKey:ParseClientKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // INITIALIZE FACEBOOK IN PARSE
    [PFFacebookUtils initializeFacebook];
    
    
    // location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 100;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    // getting deal category list
    [[ParseOperations sharedInstance] getAllDealCategories];
    
    // change the tab bar tint color
    [[UITabBar appearance] setTintColor:THEME_COLOR];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"applicationDidBecomeActive");
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
    
}

#pragma mark - custom methods

-(void) showAlertViewWithTitle: (NSString *)title withMessage:(NSString*)message{
    
//    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    UIViewController *vc = [self visibleViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    [TSMessage showNotificationInViewController:vc title:title subtitle:message type:TSMessageNotificationTypeWarning];
    
}

- (UIViewController *)visibleViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        
        return [self visibleViewController:lastViewController];
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;
        
        return [self visibleViewController:selectedViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    
    return [self visibleViewController:presentedViewController];
}


#pragma mark -
#pragma mark ---------- URL Handler METHODS ----------

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"source application: %@", sourceApplication);
    

    
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    if ([[url scheme] isEqualToString:@"tapdeal"]) {
        NSDictionary *dict = [self parseQueryString:[url query]];
        NSLog(@"query dict: %@", dict);
        
        if ([dict valueForKey:@"dealid"]){           
            
            PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
            [query whereKey:@"objectId" equalTo:[dict valueForKey:@"dealid"]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSLog(@"found one deal from URL: %@", objects);
                    if ([objects count]) {
                        PFObject *oneDeal = [objects objectAtIndex:0];
             
                        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Tabs" bundle:nil];
                        ddvc = [secondStoryBoard instantiateViewControllerWithIdentifier:@"DealDetails"];
                        ddvc.deal = oneDeal;
                        ddvc.isModal = YES;
                        
                        [self.window.rootViewController presentViewController:ddvc animated:YES completion:nil];

                        
                    }
                }
                
            }];
            
        }
        
        return YES;
    }
    
    
    NSLog(@"open URL: %@", [url description]);
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
    
}


- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    NSString *msg = nil;
    
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code])
        {
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
        NSLog(@"error location %@",msg);
    } else {
        // We handle all non-CoreLocation errors here
    }
//    [DELEGATE showAlertViewWithTitle:@"Error" withMessage:msg];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    
    
    NSLog(@"didUpdateToLocation: %@", [locations objectAtIndex:[locations count] -1]);
    currentLocation = [locations objectAtIndex:[locations count] -1];
    
    if (currentLocation != nil) {
        //        longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        //        latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        NSLog(@"lat : %f, lng: %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    }
    
}



@end

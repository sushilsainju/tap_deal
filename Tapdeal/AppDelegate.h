//
//  AppDelegate.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 6/30/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define DEFAULTS [NSUserDefaults standardUserDefaults]

#define ParseAppID @"BqnkDwWytids167wYUXvKrMkizx0O5FScZYq7z5L"
#define ParseClientKey @"xk0w0xmOx7nGFX8OFKyG0xA7QWWEeM8wNpp6q1AK"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) CLLocation *currentLocation;

// this is just to hold the searh parameters when user enters on welcome view controller and will be used on deals tab.
@property (nonatomic, strong) NSDictionary *searchDictionary;

-(void) showAlertViewWithTitle: (NSString *)title withMessage:(NSString*)message;

@end


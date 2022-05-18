//
//  InternetStatus.m
//  BizCardArmy
//
//  Created by IphoneMac on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InternetStatus.h"
#import "SharedStore.h"
#import <Reachability/Reachability.h>


@implementation InternetStatus

@synthesize delegate;

#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)checkInternetConnection{
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostname: @"www.google.com"];
    [hostReachable startNotifier];
    
}

- (void) checkNetworkStatus:(NSNotification *)notice{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];//:incompatible types in initialization
    NSLog(@"checkNetworkStatus =====");
    
    switch(internetStatus)//:switch quantity not an integer**
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            [SharedStore store].hostActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            [SharedStore store].hostActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            [SharedStore store].hostActive = YES;
            break;
        }
        default:
        {
            NSLog(@"The internet by defualt is Not working.");
            [SharedStore store].hostActive = NO;
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    [SharedStore store].checkedConnection = YES;
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"NotReachable");
            [SharedStore store].hostActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"ReachableViaWiFi");
            [SharedStore store].hostActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"ReachableViaWWAN");
            [SharedStore store].hostActive = YES;
            break;
        }
        default:
        {
            NSLog(@"default");
            [SharedStore store].hostActive = NO;
            break;
        }
    }
    
    [delegate updateInternetStatus];		
}

@end

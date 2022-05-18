//
//  MapViewController.h
//  Tapdeal
//
//  Created by Neetin on 7/10/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseOperations.h"
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController

- (id)initWithRoutes:(PFGeoPoint *)userLocation todestination:(PFGeoPoint *)dealLocatiion;


@end

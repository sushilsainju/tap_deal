//
//  CustomAnnotation.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 8/5/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "SharedStore.h"

#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject<MKAnnotation>


@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

// Title and subtitle for use by selection UI.
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) PFObject *deal;


-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)dealTitle subTitle:(NSString*)dealSubTitle deal:(PFObject *)dealObject;

+(MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation forDeal:(PFObject *)deal;

@end

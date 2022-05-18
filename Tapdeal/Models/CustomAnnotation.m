//
//  CustomAnnotation.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 8/5/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

@synthesize title, subtitle, deal;



-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)dealTitle subTitle:(NSString*)dealSubTitle deal:(PFObject *)dealObject {
    if ((self = [super init])) {
        self.coordinate = coordinate;
        self.title = dealTitle;
        self.subtitle = dealSubTitle;
        self.deal = dealObject;
    }
    return self;
}

+ (MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation forDeal:(PFObject *)deal
{
    MKAnnotationView *returnedAnnotationView =
    [mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([CustomAnnotation class])];
    if (returnedAnnotationView == nil)
    {
        returnedAnnotationView =
        [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                        reuseIdentifier:NSStringFromClass([CustomAnnotation class])];
        
        ((MKPinAnnotationView *)returnedAnnotationView).pinColor = MKPinAnnotationColorRed;
        ((MKPinAnnotationView *)returnedAnnotationView).animatesDrop = YES;
        ((MKPinAnnotationView *)returnedAnnotationView).canShowCallout = YES;
    }
    
    PFFile *userImageFile = deal[FIELD_DEAL_IMAGE_FILE];
    PFImageView *itemImageView = [[PFImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    
    
    
    itemImageView.image = [UIImage imageNamed:@"no-image.png"]; // placeholder image
    itemImageView.file = (PFFile *)userImageFile;
   
    [[SharedStore store]customizeImageView:itemImageView];
    itemImageView.layer.cornerRadius=8;
//    [itemImageView setContentMode:UIViewContentModeCenter];
    
//    [cell.contentView addSubview:itemImageView];
    [itemImageView loadInBackground];
    returnedAnnotationView.leftCalloutAccessoryView=itemImageView;
    return returnedAnnotationView;
}

@end

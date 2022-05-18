//
//  Deal.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/15/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Deal : NSObject


@property(nonatomic, strong) PFObject *itemCategory;
@property(nonatomic, strong) NSString *itemName;
@property(nonatomic, strong) NSNumber *originalPrice;
@property(nonatomic, strong) NSNumber *dealPrice;
@property(nonatomic, strong) NSString *itemDescription;
@property(nonatomic, strong) NSString *tags;
@property(nonatomic, strong) NSDate *validFromDate;
@property(nonatomic, strong) NSDate *validToDate;
@property(nonatomic, strong) UIImage *dealImage;
@property(nonatomic, strong) PFObject *dealOwner;

@end

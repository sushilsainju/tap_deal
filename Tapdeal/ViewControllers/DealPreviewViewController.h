//
//  DealPreviewViewController.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/15/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deal.h"

@protocol DealPreviewDelegate <NSObject>

-(void)dismissDealDetailView;

@end

@interface DealPreviewViewController : UIViewController

@property(nonatomic, strong) PFObject *deal;

@property (nonatomic, strong) UIImage *dealImage;

@property (nonatomic, weak) id <DealPreviewDelegate> delegate;


@end

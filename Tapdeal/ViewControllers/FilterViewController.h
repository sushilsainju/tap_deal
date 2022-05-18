//
//  FilterViewController.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/21/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ActionSheetStringPicker.h>

@protocol FilterViewDelegate <NSObject>

-(void) doSearch;

@end


@interface FilterViewController : UIViewController

@property (nonatomic, assign)id <FilterViewDelegate> delegate;

@property (nonatomic, assign) BOOL isSliderHidden;


@end

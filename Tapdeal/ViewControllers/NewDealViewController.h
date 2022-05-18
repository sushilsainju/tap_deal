//
//  NewDealViewController.h
//  Tapdeal
//
//  Created by Neetin on 7/10/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Parse/Parse.h>

@interface NewDealViewController : UIViewController<UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>



@property (nonatomic, strong) PFObject *deal;

@property (nonatomic, weak) id previewDelegate;


@end

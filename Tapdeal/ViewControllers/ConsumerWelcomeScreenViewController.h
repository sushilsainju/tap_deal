//
//  ConsumerWelcomeScreenViewController.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/8/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsumerWelcomeScreenViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

// properties



// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *selectCategeoryButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *viewAllDealsButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;


@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *whereToLabel;



// IBAction
- (IBAction)didPressCategoryButton:(id)sender;
- (IBAction)didPressSubmitButton:(id)sender;
- (IBAction)didPressViewAllDeals:(id)sender;



@end

//
//  BusinessSignupViewController.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/2/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessSignupViewController : UIViewController<UITextFieldDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *bodyTitleLabel;


// IBActions
- (IBAction)didPressBackButton:(id)sender;
- (IBAction)didPressRegisterButton:(id)sender;

@end

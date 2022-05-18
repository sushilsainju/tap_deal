//
//  BusinessLoginViewController.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/2/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessLoginViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>

// properties


// IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;


@property (weak, nonatomic) IBOutlet UILabel *bodyTitleLabel;


// IBActions
- (IBAction)didPressLoginButton:(id)sender;
- (IBAction)didPressForgotPasswordButton:(id)sender;
- (IBAction)didPressBackButton:(id)sender;


@end

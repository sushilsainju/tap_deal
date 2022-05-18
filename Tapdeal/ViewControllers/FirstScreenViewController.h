//
//  FirstScreenViewController.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/1/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstScreenViewController : UIViewController

// IBOutlets

@property (weak, nonatomic) IBOutlet UIButton *loginWithFacebookButton;

@property (weak, nonatomic) IBOutlet UILabel *bodyTitlelabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyfooterLabel;


// IBActions

- (IBAction)didPressLoginWithFacebook:(id)sender;
- (IBAction)didPressLoginButton:(id)sender;
- (IBAction)didPressRegisterButton:(id)sender;

@end

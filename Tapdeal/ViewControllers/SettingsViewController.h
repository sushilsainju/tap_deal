//
//  SettingsViewController.h
//  Tapdeal
//
//  Created by Neetin on 7/10/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *loginbutton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *changePwdButton;
@property (weak, nonatomic) IBOutlet UIButton *editBusinessButton;
- (IBAction)editBusinessClicked:(id)sender;
- (IBAction)changePasswordClicked:(id)sender;
- (IBAction)logoutClicked:(id)sender;
- (IBAction)loginClicked:(id)sender;

@end

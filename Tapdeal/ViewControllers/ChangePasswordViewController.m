//
//  ChangePasswordViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 8/29/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "ChangePasswordViewController.h"

#import <Parse/Parse.h>

#import "UITextField+Custom.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import "AppDelegate.h"

#import "UITextField+Custom.h"

@interface ChangePasswordViewController ()

// IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *navBarTitlelabel;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *changePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmChangePasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;


// IBActions
- (IBAction)didPressChangePasswordButton:(id)sender;
- (IBAction)didPressCloseButton:(id)sender;



// Properties


@end

@implementation ChangePasswordViewController

@synthesize navBarTitlelabel, changePasswordButton, currentPasswordTextField;

@synthesize changePasswordTextField, confirmChangePasswordTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) customizeView{
    [currentPasswordTextField setTheme];
    [changePasswordTextField setTheme];
    [confirmChangePasswordTextField setTheme];
}


-(BOOL)validateForm{
    
    if ([currentPasswordTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Please insert your current password"];
        return NO;
    }
    else if ([changePasswordTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"New password is required"];
        return NO;
    }
    else if ([confirmChangePasswordTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Confirm password is required"];
        return NO;
    }
    else if ([changePasswordTextField.text length] < 8) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Password must be atleast 8 characters."];
        return NO;
    }
    else if ([confirmChangePasswordTextField.text length] < 8) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Confirm password must be atleast 8 characters."];
        return NO;
    }
    else if (![confirmChangePasswordTextField.text isEqualToString:changePasswordTextField.text]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"New password and confirm password should be matched"];
        return NO;
    }
    
    return YES;
}


- (IBAction)didPressChangePasswordButton:(id)sender {
    
    
    if (![self validateForm])
        return;
    
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser){
        
        NSString *email = currentUser.email;
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [PFUser logInWithUsernameInBackground:email password:currentPasswordTextField.text
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                // Do stuff after successful login.
                                                
                                                NSLog(@"user current passowrd is ok");
                                                
                                                currentUser.password = changePasswordTextField.text;
                                                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                    if (succeeded) {
                                                        NSLog(@"password changed");
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                    }else{
                                                        NSLog(@"there is an error: %@", [error userInfo]);
                                                        
                                                        [DELEGATE showAlertViewWithTitle:@"Error" withMessage:@"Unknown error, please try later."];
                                                    }
                                                    
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                }];
                                                
                                                
                                            } else {
                                                if ([[[error userInfo] valueForKey:@"code"] intValue] == 101) {
                                                    [DELEGATE showAlertViewWithTitle:@"Invalid Password" withMessage:@"Invalid current password"];
                                                    
                                                }else{
                                                    [DELEGATE showAlertViewWithTitle:@"Error" withMessage:@"Unknown error, please try later."];
                                                }

                                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                            }
                                        }];
    }
    
    
}

- (IBAction)didPressCloseButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

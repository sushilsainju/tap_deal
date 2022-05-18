//
//  BusinessLoginViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/2/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "BusinessLoginViewController.h"
#import "UITextField+Custom.h"
#import "UIButton+Custom.h"
#import "UILabel+Custom.h"

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SharedStore.h"

#import "ParseOperations.h"

#import "HelpViewController.h"

@interface BusinessLoginViewController()

@property(nonatomic, strong) UITextField *askEmailForResetPasswordTextField;
@end

@implementation BusinessLoginViewController

@synthesize emailTextField, passwordTextField, loginButton, backButton, helpButton, forgotButton;

@synthesize askEmailForResetPasswordTextField, navBarTitleLabel, bodyTitleLabel;


-(void) viewDidLoad{
    [super viewDidLoad];
    [self customizeView];

}

#pragma mark - Custom methods

-(void)customizeView{
    [emailTextField setTheme];
    [passwordTextField setTheme];
    
    // setting button and label fonts
    [loginButton setCustomFont];
    [navBarTitleLabel setNavBarFont];
    [forgotButton setCustomSmallFont];
    [helpButton setCustomSmallFont];
    [bodyTitleLabel setLargeFont];
    
}

-(void) resignFirstResponderFromAllTextFields{
    
    [emailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
//    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
}

-(BOOL)validateForm{
   
   if ([emailTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Email is required. Please fill it"];
        return NO;
    }
    else if (![emailTextField isValidEmail]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Email is Invalid."];
        return NO;
    }
    else if ([passwordTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Password is required. Please fill it"];
        return NO;
    }
    
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // not in use
    if ([[segue identifier] isEqualToString:@"privacyPolicySegue"]) {
        
        HelpViewController *hvc = [segue destinationViewController];
        hvc.termsAndPrivacyID = ID_PRIVACY_POLICY;
       
    }
    else if ([[segue identifier] isEqualToString:@"appDisclaimerSegue"]) {
        
        HelpViewController *hvc = [segue destinationViewController];
        hvc.termsAndPrivacyID = ID_APP_DISCLAIMER;
        
    }
    else if ([[segue identifier] isEqualToString:@"termsOfUseSeque"]) {
        
        HelpViewController *hvc = [segue destinationViewController];
        hvc.termsAndPrivacyID = ID_TERMS_OF_USE;
        
    }

}


#pragma mark - IBActions

- (IBAction)didPressLoginButton:(id)sender {
    // resign first responder from all
    [self resignFirstResponderFromAllTextFields];
    
    
    if ([self validateForm]) {
        NSLog(@"form is valid");
        
        NSLog(@"email text : %@", emailTextField.text);
        
        loginButton.enabled = NO;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [PFUser logInWithUsernameInBackground:emailTextField.text password:passwordTextField.text
                                        block:^(PFUser *user, NSError *error) {
                                            
                                            loginButton.enabled =YES;
                                            if (user) {
                                                // Do stuff after successful login.
                                                NSLog(@"user logins");
                                                
                                                NSString *userType = user[FIELD_USER_USERTYPE];
                                                
                                                if ([userType isEqualToString:USER_TYPE_BUSINESS]){
                                                    ParseOperations *operations = [ParseOperations sharedInstance];
                                                    [operations getMyBusinessInfo];
                                                }
                                                
                                                PFQuery *businessQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
                                                [businessQuery whereKey:FIELD_BUSINESS_DEALER equalTo:[PFUser currentUser]];
                                                PFObject *myBusiness = [businessQuery getFirstObject];
                                                
                                                if (myBusiness) {
                                                    BOOL verifiedBusiness = [myBusiness[FIELD_BUSINESS_IS_VERIFIED] boolValue];
                                                    [DEFAULTS setBool:verifiedBusiness forKey:FIELD_BUSINESS_IS_VERIFIED];
                                                }
                                                
                                                [DEFAULTS setObject:userType forKey:FIELD_USER_USERTYPE];
                                                [DEFAULTS synchronize];
                                                
                                                NSLog(@"if business verified: %d", [DEFAULTS boolForKey:FIELD_BUSINESS_IS_VERIFIED]);
                                                
                                                
                                                
                                                // checking if the user has already created business
                                                PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
                                                [query whereKey:FIELD_BUSINESS_DEALER equalTo:user];
                                                
                                                
                                                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                                    if (!error) {
                                                        // The find succeeded.
                                                        NSLog(@"If user has a business: %lu", (unsigned long)objects.count);
                                                        
                                                        if ([objects count] > 0) {
                                                            [DEFAULTS setBool:YES forKey:@"ifDealerHasBusiness"];
                                                            [DEFAULTS synchronize];
                                                            
                                                        }else{
                                                            [DEFAULTS setBool:NO forKey:@"ifDealerHasBusiness"];
                                                            [DEFAULTS synchronize];
                                                        }
                                                        
                                                    } else {
                                                        // Log details of the failure
                                                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                                                    }
                                                    
                                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                    
                                                    // passing control to segue handler
                                                    // [self performSegueWithIdentifier:@"login" sender:sender];   // not in use
                                                    
                                                    // just dismiss modal view
                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                }];
                                                
                                            } else {
                                                // The login failed. Check error to see why.
                                                NSLog(@"user login failed");
                                                if ([[[error userInfo] valueForKey:@"code"] intValue] == 101) {
                                                    [DELEGATE showAlertViewWithTitle:@"Invalid Login" withMessage:@"Invalid Login Credentials"];
                                                }
                                                
                                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                            }
                                            
                                        }];
    }
}

- (IBAction)didPressForgotPasswordButton:(id)sender {
    
    if ([emailTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Please enter you email address and Press Forgot Password again"];
    }else if (![emailTextField isValidEmail]){
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Please enter valid email address and Press Forgot Password again"];
    }else{
        NSString *text = [NSString stringWithFormat:@"Your email address: %@ \nAre you sure you want to reset your password?", emailTextField.text];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APPLICATION_NAME message:text delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alertView.tag = 99;
        [alertView show];
    }
    
}
- (IBAction)didPressBackButton:(id)sender {
    
    NSLog(@"didPressBackButton");
    [self resignFirstResponderFromAllTextFields];
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UITextFiled delegate

-(void) textFieldDidBeginEditing:(UITextField *)textField{
//    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 256, 0);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
//    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return YES;
}

#pragma mark - alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 99) {
        NSLog(@"button index %ld", (long)buttonIndex);
        if (buttonIndex == 1) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [PFUser requestPasswordResetForEmailInBackground:emailTextField.text block:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"reset password done");
                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Your password has been reset. Please check your email."];
                }else{
                    NSLog(@"error ayo; %@", [error localizedDescription]);
                    // checking for both username and email id
                    if ([[[error userInfo] valueForKey:@"code"] intValue] == 205) {
                        [DELEGATE showAlertViewWithTitle:@"Invlid Email" withMessage:@"No user found with this email to reset password."];
                    }else{
                        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Unknown error occurred!"];
                    }
                }
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
        }
    }
    
}

@end

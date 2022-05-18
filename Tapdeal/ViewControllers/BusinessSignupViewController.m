//
//  BusinessSignupViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/2/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "BusinessSignupViewController.h"
#import "AppDelegate.h"
#import "UITextField+Custom.h"
#import "UIButton+Custom.h"
#import "UILabel+Custom.h"

#import "SharedStore.h"
#import <parse/Parse.h>
#import "NSString+custom.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface BusinessSignupViewController ()

// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *businessOwnerLable;
@property (weak, nonatomic) IBOutlet UISwitch *becomeABusinessOwnerSwitch;

// IBAction

- (IBAction)didTapBusinessOwnerSwitch:(id)sender;

// properties

@property (nonatomic) BOOL isBusinessOwner;

@end

@implementation BusinessSignupViewController

@synthesize nameTextField, emailTextField, passwordTextField, confirmPasswordTextField, registerButton;
@synthesize scrollView, bodyTitleLabel, navBarTitleLabel, businessOwnerLable, becomeABusinessOwnerSwitch;

@synthesize isBusinessOwner;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    isBusinessOwner = NO;
    [becomeABusinessOwnerSwitch setOn:NO];
    [self customizeView];
    [self resetScrollView];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // not in use 
    if ([[segue identifier] isEqualToString:@"register"]) {
        NSLog(@"opening welcome screen... check anything here after validation if required");
    }
}


#pragma mark - custom methods

-(void)customizeView{
    [nameTextField setTheme];
    [emailTextField setTheme];
    [passwordTextField setTheme];
    [confirmPasswordTextField setTheme];
    
    // setting button and label fonts
    [registerButton setCustomFont];
    [navBarTitleLabel setNavBarFont];
    [bodyTitleLabel setLargeFont];
    [businessOwnerLable setNormalFont];
    
}

-(void)resetScrollView{
    
    [scrollView setContentSize:(CGSizeMake(320, ScreenSize.height - 64))];
    
    CGRect frame = self.scrollView.frame;
    
    frame.size = CGSizeMake(320, ScreenSize.height - 64);
    
    [self.scrollView setFrame:frame];
    NSLog(@"scroll view height: %f", scrollView.frame.size.height);
}

-(void) resignFirstResponderFromAllTextFields{
    
    [nameTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [confirmPasswordTextField resignFirstResponder];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
}
-(BOOL)validateForm{
    if ([nameTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Name is required. Please fill it"];
        return NO;
    }
    else if ([emailTextField isEmpty]) {
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
    else if ([passwordTextField.text length] < 8) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Password must be atleast 8 characters."];
        return NO;
    }
    else if ([confirmPasswordTextField isEmpty]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Confirm Password is required. Please fill it"];
        return NO;
    }
    else if (![passwordTextField.text isEqualToString: confirmPasswordTextField.text]) {
        [DELEGATE showAlertViewWithTitle:@"Invalid Data" withMessage:@"Passwords should be matched"];
        return NO;
    }

    return YES;
}


#pragma mark - IBActions

- (IBAction)didPressBackButton:(id)sender {
    NSLog(@"didPressBackButton");
    [self resignFirstResponderFromAllTextFields];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressRegisterButton:(id)sender {
    [registerButton setEnabled:NO];
    
    
    // resign first responder from all
    [self resignFirstResponderFromAllTextFields];
    if ([self validateForm]) {
        NSLog(@"form is valid");
        
        NSLog(@"email text : %@", emailTextField.text);
        
        PFUser *user = [PFUser user];
       
        // creating a hash for username by using email
        /*
        NSString *username = [emailTextField.text sha1]; // hashing email address to get username if required
        user.username = username;
        */
        
        user.username = emailTextField.text;
        user.password = passwordTextField.text;
        user.email = emailTextField.text;
        
        // other fields can be set just like with PFObject
         user[FIELD_USER_FULLNAME] = nameTextField.text;
        if (isBusinessOwner) {
             user[FIELD_USER_USERTYPE] = USER_TYPE_BUSINESS;
        }else{
             user[FIELD_USER_USERTYPE] = USER_TYPE_CONSUMER;
        }
        
        // settings fav deal, fav biz empty array
        NSArray *empty = [NSArray new];
        user[FIELD_USER_FAVORITE_BUSINESSES] = empty;
        user[FIELD_USER_FAVORITE_DEALS] = empty;
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            registerButton.enabled =YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error) {
                NSLog(@"USER ------ %@", [PFUser currentUser]);
                
                
                // pass control to segue handler
                //  [self performSegueWithIdentifier:@"register" sender:sender];
                
               // just dismiss modal view
                
                if (isBusinessOwner) {
                    [DEFAULTS setObject:USER_TYPE_BUSINESS forKey:FIELD_USER_USERTYPE];
                    [DEFAULTS synchronize];
                }else{
                    [DEFAULTS setObject:USER_TYPE_CONSUMER forKey:FIELD_USER_USERTYPE];
                    [DEFAULTS synchronize];
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);

                // checking for both username and email id
                if ([[[error userInfo] valueForKey:@"code"] intValue] == 202 || [[[error userInfo] valueForKey:@"code"] intValue] == 203 ) {
                    [DELEGATE showAlertViewWithTitle:@"Invlid Email" withMessage:@"Email is already in use. Please use another email"];
                }
            }
            
    }];
        
    }else{
        NSLog(@"invalid form");
        [registerButton setEnabled:YES];
    }
    
}


#pragma mark - UITextFiled delegate

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 256, 0);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return YES;
}

- (IBAction)didTapBusinessOwnerSwitch:(id)sender {
    UISwitch *checkSwitch = sender;
    
    if (checkSwitch.on) {
        NSLog(@"switch is on");
        isBusinessOwner = YES;
    }else{
        NSLog(@"switch is off");
        isBusinessOwner = NO;
    }
    
}
@end

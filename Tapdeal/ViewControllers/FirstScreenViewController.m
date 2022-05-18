//
//  FirstScreenViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/1/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "FirstScreenViewController.h"
#import "AppDelegate.h"
#import "InternetStatus.h"
#import "SharedStore.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "UILabel+Custom.h"
#import "ParseOperations.h"

@interface FirstScreenViewController ()

// IBActions

- (IBAction)didPressCancelButton:(id)sender;

@end

@implementation FirstScreenViewController

@synthesize loginWithFacebookButton, bodyfooterLabel, bodyTitlelabel;

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

    // TAKE THE USER TO HOME SCREEN IF HE IS ALREADY SIGNED IN
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // Get the storyboard named secondStoryBoard from the main bundle:
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Tabs" bundle:nil];
        
        // Load the initial view controller from the storyboard.
        // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
        UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
        [self.navigationController pushViewController:theInitialViewController animated:YES];
        
    }
    
    [self customizeView];
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
    
    // following is not in use now
    /*
    if ([[segue identifier] isEqualToString:@"BusinessUser"]) {
        NSLog(@"navigating to Business welcome screen view controller");
    }
    if ([[segue identifier] isEqualToString:@"consumerWelcome"]) {
        NSLog(@"got consumerWelcome page");
    }
    
     */
}


#pragma mark - custom methods

-(void)customizeView{
    [bodyTitlelabel setLargeFont];
    
    [bodyfooterLabel setNormalBoldFont];
}

#pragma mark - IBActions

- (IBAction)didPressLoginWithFacebook:(id)sender {
    NSLog(@"fb login button pressed...");

    // CHECK INTERNET CONNECTION
//    if (!([InternetStatus internetStatus].hostActive)) {
//         [DELEGATE showAlertViewWithTitle:@"Error" withMessage:Message_InternetOffline];
//        return;
//    }
    
    // loading overlay
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"public_profile",@"email"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self saveFBUser];
            
        } else {
            NSLog(@"User with facebook logged in!");
            [self updateFBUser];
        }
        
        
    }];
}


-(void)saveFBUser{
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            //                    NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *email;
            
            if(userData[@"email"] == NULL){
                email = @"";
            } else {
                email = userData[@"email"];
            }
            NSLog(@"name: %@, email: %@", name, email);
 
            [[PFUser currentUser] setObject:email    forKey:FIELD_USER_EMAIL];
            [[PFUser currentUser] setObject:name     forKey:FIELD_USER_FULLNAME];
            [[PFUser currentUser] setObject:USER_TYPE_CONSUMER forKey:FIELD_USER_USERTYPE];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"USER ------ %@", [PFUser currentUser]);
                    
                    [DEFAULTS setObject:USER_TYPE_CONSUMER forKey:FIELD_USER_USERTYPE];
                    [DEFAULTS synchronize];

                    
                    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
                    {
                        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:nil block:^(BOOL succeeded, NSError *error)
                        {
                            if (succeeded) {
                                
                                loginWithFacebookButton.enabled =YES;
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                
                                NSLog(@"Woohoo, user logged in with Facebook!");
                               [self dismissViewControllerAnimated:YES completion:nil];

                            }
                        }];
                    }else{
                        loginWithFacebookButton.enabled =YES;
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        
                        NSLog(@"Woohoo, user logged in with Facebook!");
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
//            [self logoutButtonTouchHandler:nil];
            loginWithFacebookButton.enabled =YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            NSLog(@"Some other error: %@", error);
            loginWithFacebookButton.enabled =YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        
    }];
}


-(void)updateFBUser{
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            //                    NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *email = userData[@"email"];
            
            NSLog(@"name: %@, email: %@", name, email);
            
            if(email)
            [[PFUser currentUser] setObject:email    forKey:FIELD_USER_EMAIL];
            [[PFUser currentUser] setObject:name     forKey:FIELD_USER_FULLNAME];
            
            
            NSString *userType = [[PFUser currentUser] objectForKey:FIELD_USER_USERTYPE];
            
            [DEFAULTS setObject:userType forKey:FIELD_USER_USERTYPE];
            [DEFAULTS synchronize];
            
            if ([userType isEqualToString:USER_TYPE_BUSINESS]){
                ParseOperations *operations = [ParseOperations sharedInstance];
                [operations getMyBusinessInfo];
            }
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"USER ------ %@", [PFUser currentUser]);
                    
                    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
                        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:nil block:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                
                                loginWithFacebookButton.enabled =YES;
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                
                                NSLog(@"Woohoo, user logged in with Facebook!");
                                [self dismissViewControllerAnimated:YES completion:nil];
                                
                            }
                        }];
                    }else{
                        loginWithFacebookButton.enabled =YES;
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        
                        NSLog(@"Woohoo, user logged in with Facebook!");
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            //            [self logoutButtonTouchHandler:nil];
            loginWithFacebookButton.enabled =YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            NSLog(@"Some other error: %@", error);
            loginWithFacebookButton.enabled =YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        
    }];
}



- (IBAction)didPressLoginButton:(id)sender {
}

- (IBAction)didPressRegisterButton:(id)sender {
}

- (IBAction)didPressCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FB error handling

- (void)handleAuthError:(NSError *)error
{
    NSString *alertText;
    NSString *alertTitle;
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
        // Error requires people using you app to make an action outside your app to recover
        alertTitle = @"Something went wrong";
        alertText = [FBErrorUtility userMessageForError:error];
        [DELEGATE showAlertViewWithTitle:alertTitle withMessage:alertText];
    } else {
        // You need to find more information to handle the error within your app
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            //The user refused to log in into your app, either ignore or...
            alertTitle = @"Login cancelled";
            alertText = @"You need to login to access this part of the app";
            [DELEGATE showAlertViewWithTitle:alertTitle withMessage:alertText];
            
        } else {
            // All other errors that can happen need retries
            // Show the user a generic error message
            alertTitle = @"Something went wrong";
            alertText = @"Please retry";
            [DELEGATE showAlertViewWithTitle:alertTitle withMessage:alertText];
        }
    }
}


@end

//
//  SettingsViewController.m
//  Tapdeal
//
//  Created by Neetin on 7/10/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SharedStore.h"
#import "AppDelegate.h"

#import "UIButton+Custom.h"
#import "UILabel+Custom.h"
#import <Parse/Parse.h>
#import "SharedStore.h"

#import "ParseOperations.h"

@interface SettingsViewController ()<UITableViewDataSource, UITabBarDelegate>

// Properties
@property(nonatomic, strong) NSMutableArray *settingsTableDataArray;

// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet UILabel *nabBarTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIView *userNameView;


@end

@implementation SettingsViewController

@synthesize settingsTableDataArray, settingsTableView, nabBarTitleLabel;
@synthesize editBusinessButton,changePwdButton,logoutButton,loginbutton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [nabBarTitleLabel setNavBarFont];
    
    settingsTableDataArray = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NSLog(@"in viewWillAppear in settings...");
    [self configureSettings];
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

#pragma mark - Custom methods
-(void)showLogin :(bool)show
{
    [loginbutton setHidden:!show];
    [logoutButton setHidden:show];
    [editBusinessButton setHidden:show];
    [changePwdButton setHidden:show];
    [_userNameView setHidden:show];
    }


-(void) configureSettings{

                               
    [settingsTableDataArray removeAllObjects];
    
    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"current user in settings : %@", currentUser);
    if (!currentUser)
    {
       [self showLogin:YES];
        
//        [settingsTableDataArray  addObject:@"Login"];
    }
    else
    {
        [self showLogin:NO];
        
        self.userName.text=[NSString stringWithFormat:@"Logged in as %@",[currentUser valueForKey:@"fullname"] ];
        if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        {
            [changePwdButton setHidden:NO];
            
        }
        else
            [changePwdButton setHidden:YES];
        [editBusinessButton setBackgroundImage:[self changeImageForBusinessButton:currentUser] forState:UIControlStateNormal];

    }
//        NSString *logoutText = [NSString stringWithFormat:@"Logout from %@", currentUser[FIELD_USER_FULLNAME]];
//        
//        if ([currentUser[FIELD_USER_USERTYPE] isEqualToString:USER_TYPE_BUSINESS])
//        {
//            if ([[DEFAULTS valueForKey:@"ifDealerHasBusiness"] boolValue])
//            {
//                [settingsTableDataArray addObject:@"Edit a Business"];
//                [settingsTableDataArray addObject:@"Change Password"];
//                [settingsTableDataArray addObject:logoutText];
//            }
//            else
//            {
//                [settingsTableDataArray addObject:@"Add a Business"];
//                [settingsTableDataArray addObject:@"Change Password"];
//                [settingsTableDataArray addObject:logoutText];
//            }
//
//        }
//        else
//        {
//            [settingsTableDataArray addObject:@"Become a Business user"];
//            [settingsTableDataArray addObject:@"Change Password"];
//            [settingsTableDataArray addObject:logoutText];
//        }
//    }
//    
//    [settingsTableView reloadData];
}

-(UIImage *)changeImageForBusinessButton:(PFUser *)currentuser
{
    UIImage *buttonImage;
    if ([currentuser[FIELD_USER_USERTYPE] isEqualToString:USER_TYPE_BUSINESS])
                {
                    if ([[DEFAULTS valueForKey:@"ifDealerHasBusiness"] boolValue])
                    {
                        buttonImage= [UIImage imageNamed:@"edit-business.png"];
                    }
                    else
                    {
                        buttonImage= [UIImage imageNamed:@"add-a-business.png"];

                    }
        
                }
                else
                {
                    [settingsTableDataArray addObject:@"Become a Business user"];
                    buttonImage= [UIImage imageNamed:@"become-business-user.png"];
                }
    return buttonImage;

}

#pragma mark - Table view data source

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellIdentifier = @"settingsTableViewCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    
//    // this is required, otherwise it content will overlap on every reload
//    for (UIView *view in cell.contentView.subviews) {
//        [view removeFromSuperview];
//    }
//    
//    [self configureCell:cell atIndexPath:indexPath];
//    return cell;
//}
//
//
//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    
//    NSLog(@"setting cell data: %@", [settingsTableDataArray objectAtIndex:[indexPath row]]);
//    cell.textLabel.text = [settingsTableDataArray objectAtIndex:[indexPath row]];
//}
//
//
//#pragma mark - Table View delegate
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    
//    return [settingsTableDataArray count];
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    return 44;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 0.01f;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    NSLog(@"index selected: %ld", (long)[indexPath row]);
//    
//    PFUser *currentUser = [PFUser currentUser];
//    
//    if([settingsTableDataArray count] == 1){
//        // must be login
//        // Get the storyboard named secondStoryBoard from the main bundle:
//        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        
//        // Load the initial view controller from the storyboard.
//        // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
//        UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
//        
//        [self presentViewController:theInitialViewController animated:YES completion:nil];
//
//    }else{
//        
//        if ([indexPath row] == 0) {
//            
//            if ([currentUser[FIELD_USER_USERTYPE] isEqualToString:USER_TYPE_BUSINESS]) {
//                
//                // Get the storyboard named secondStoryBoard from the main bundle:
//                UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                
//                // Load the initial view controller from the storyboard.
//                // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
//                UIViewController *theInitialViewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"businessRegistration"];
//                
//                [self presentViewController:theInitialViewController animated:YES completion:nil];
//                
//            }else{
//                
//                
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APPLICATION_NAME message:@"Are you sure, you want to be a business dealer?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"Yes", nil];
//                alertView.tag = 2;
//                [alertView show];
//                
//                            }
//        }
//        else if ([indexPath row] == 1) {
//            // change password
//            UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            UIViewController *theInitialViewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"changePasswordVC"];
//            
//            [self presentViewController:theInitialViewController animated:YES completion:nil];
//            
//        }
//        else{
//            
//            // logout
//            
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APPLICATION_NAME message:@"Are you sure, you want to logout?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"Yes", nil];
//            alertView.tag = 1;
//            [alertView show];
//            
//            
//        }
//    }
//    
//        [settingsTableView deselectRowAtIndexPath:indexPath animated:NO];
//}
//
//
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"button index of alert : %d", buttonIndex);
    
    if (alertView.tag == 1)
    {
        
        if (buttonIndex == 1) {
            [PFUser logOut];
            
            /* don't forget to set these value */
            [DEFAULTS setBool:NO forKey:@"ifDealerHasBusiness"];
            [DEFAULTS removeObjectForKey:FIELD_USER_USERTYPE];
            [DEFAULTS setBool:NO forKey:FIELD_BUSINESS_IS_VERIFIED];
            
            [DEFAULTS synchronize];
            
            [self configureSettings];
            
            ParseOperations *parseOperations = [ParseOperations sharedInstance];
            parseOperations.myBusinesses = nil;  // setting my business parse object to nil if it was set before
            parseOperations.myDeals = nil;
            parseOperations.myDealsSearch = nil;
            parseOperations.myFavoriteDeals = nil;
            parseOperations.myFavoriteBusinessesDeals = nil;
            parseOperations.favoriteDealerDeals = nil;
            parseOperations.favoriteDealerDealsSearch = nil;
            
            [self.tabBarController setSelectedIndex:3];

        }
    }
    else if (alertView.tag == 2)
    {
        
        if (buttonIndex == 1){
            PFUser *currentUser = [PFUser currentUser];
            currentUser[FIELD_USER_USERTYPE] = USER_TYPE_BUSINESS;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self configureSettings];
                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Now you are a business dealer. Before posting a deal, please add your business details."];
                }else{
                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Unknow error occurred, please try later."];
                }
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
            }];
        }
    }
}



- (IBAction)editBusinessClicked:(id)sender
{
    PFUser *currentUser = [PFUser currentUser];
    if ([currentUser[FIELD_USER_USERTYPE] isEqualToString:USER_TYPE_BUSINESS])
    {
        
        // Get the storyboard named secondStoryBoard from the main bundle:
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        // Load the initial view controller from the storyboard.
        // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
        UIViewController *theInitialViewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"businessRegistration"];
        
        [self presentViewController:theInitialViewController animated:YES completion:nil];
    }
    else{
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APPLICATION_NAME message:@"Are you sure, you want to be a business dealer?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"Yes", nil];
        alertView.tag = 2;
        [alertView show];
        
    }
}

- (IBAction)changePasswordClicked:(id)sender
{
//     change password
                UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *theInitialViewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"changePasswordVC"];
    
                [self presentViewController:theInitialViewController animated:YES completion:nil];
    
    
    
}

- (IBAction)logoutClicked:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APPLICATION_NAME message:@"Are you sure, you want to logout?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"Yes", nil];
                alertView.tag = 1;
                [alertView show];
}

- (IBAction)loginClicked:(id)sender
{
            // Get the storyboard named secondStoryBoard from the main bundle:
            UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
            // Load the initial view controller from the storyboard.
            // Set this by selecting 'Is Initial View Controller' on the appropriate view controller in the storyboard.
            UIViewController *theInitialViewController = [secondStoryBoard instantiateInitialViewController];
    
            [self presentViewController:theInitialViewController animated:YES completion:nil];
}
@end

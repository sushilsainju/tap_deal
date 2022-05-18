//
//  HelpViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/9/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "HelpViewController.h"
#import "SharedStore.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"

@interface HelpViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *navBarTitleLabel;

@property (nonatomic, strong) NSString *url;


@end

@implementation HelpViewController

@synthesize termsAndPrivacyID, navBarTitleLabel, url;


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
    
    NSLog(@"termsAndPrivacyID : %@", termsAndPrivacyID);
    
    if ([termsAndPrivacyID isEqual:ID_TERMS_OF_USE]) {
        navBarTitleLabel.text = @"Terms of use";
        url = @"http://www.tapdeal.com.au/terms.php";
    }
    else if ([termsAndPrivacyID isEqual:ID_APP_DISCLAIMER]) {
        navBarTitleLabel.text = @"App Disclaimer";
        url = @"http://www.tapdeal.com.au/disclaimer.php";
    }
    else if ([termsAndPrivacyID isEqual:ID_PRIVACY_POLICY]) {
        navBarTitleLabel.text = @"Privacy Policy";
        url = @"http://www.tapdeal.com.au/privacy.php";
    }
    
    
    [self loadRemotePdfWithURL:url];
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

- (IBAction)didPressCloseButton:(id)sender {
    NSLog(@"didPressCloseButton");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void) loadRemotePdfWithURL: (NSString *) link
{
    float height = ScreenSize.height - 49;
    
    UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,64,320,height)];
    myWebView.autoresizesSubviews = YES;
    myWebView.scalesPageToFit = YES;
    myWebView.delegate = self;
    
    myWebView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    NSURL *myUrl = [NSURL URLWithString:link];
    NSURLRequest *myRequest = [NSURLRequest requestWithURL:myUrl];
   
    [myWebView loadRequest:myRequest];
   
    
    
    [self.view addSubview: myWebView];

}



- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"webViewDidFinishLoad");
    
   
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    
    NSLog(@"didFailLoadWithError , error: %@", [error localizedDescription]);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:[error localizedDescription]];
  
}
@end

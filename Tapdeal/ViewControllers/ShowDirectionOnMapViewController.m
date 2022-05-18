//
//  ShowDirectionOnMapViewController.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 8/6/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "ShowDirectionOnMapViewController.h"
#import "SharedStore.h"
#import "UILabel+Custom.h"

@interface ShowDirectionOnMapViewController ()

// IBoutlet
@property (weak, nonatomic) IBOutlet UILabel *navBarTitleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


- (IBAction)didPressbackButton:(id)sender;



@end

@implementation ShowDirectionOnMapViewController

@synthesize navBarTitleLabel, webView, request;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
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
    // Do any additional setup after loading the view.
    [self customizeView];
    
    [webView loadRequest:request];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)customizeView{
    
    [navBarTitleLabel setNavBarFont];
    
    CGRect frame = webView.frame;
    frame.size = CGSizeMake(320, ScreenSize.height - 114);
    [webView setFrame:frame];
    NSLog(@"scroll view height: %f", webView.frame.size.height);

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

- (IBAction)didPressbackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

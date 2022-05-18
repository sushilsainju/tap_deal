//
//  HelpViewController.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/9/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController

// IBOutlets

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic, strong) NSNumber *termsAndPrivacyID;

// IBActions
- (IBAction)didPressCloseButton:(id)sender;



@end

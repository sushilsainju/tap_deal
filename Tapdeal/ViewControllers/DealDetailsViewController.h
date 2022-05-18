//
//  DealDetailsViewController.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/25/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DealDetailsViewController : UIViewController<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate>{
    
}

@property (nonatomic, strong) PFObject *deal;

@property (nonatomic, assign) BOOL isModal;

@end

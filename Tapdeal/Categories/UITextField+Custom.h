//
//  UITextField+Custom.h
//  Machineshop
//
//  Created by Neetin Mac Mini on 6/16/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Custom)


-(void) setTheme;

-(void) setDisabledTheme;

-(BOOL) isEmpty;

-(BOOL) isNumber;

-(BOOL) isValidEmail;

-(BOOL) checkLimitCharacter:(NSInteger)limit;

@end

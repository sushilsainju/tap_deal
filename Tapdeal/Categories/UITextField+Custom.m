//
//  UITextField+Custom.m
//  Machineshop
//
//  Created by Neetin Mac Mini on 6/16/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "UITextField+Custom.h"
#import <QuartzCore/QuartzCore.h>
#import "SharedStore.h"

@implementation UITextField (Custom)



-(void) setTheme{
    self.layer.borderColor = THEME_COLOR_LIGHT.CGColor;
    self.layer.borderWidth = 2.0;
    self.textAlignment = NSTextAlignmentCenter;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.font = App_Default_font_15;
    self.layer.cornerRadius = 14.0f;
}

-(void) setDisabledTheme{
    self.layer.borderColor = THEME_COLOR_DISABLED.CGColor;
    self.enabled = NO;
    self.text = @"";
}

-(BOOL) isEmpty{
    return [self.text length] ? NO: YES;
}

- (BOOL) isNumber{
    
    if ([self isEmpty]) {
        return NO;
    }
    
    NSString *someRegexp = @"^(?:[0-9]\\d*)(?:\\.\\d*)?$";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", someRegexp];    
    return [myTest evaluateWithObject: self.text] ? YES: NO;
}

-(BOOL) isValidEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self.text] ? YES: NO;
}


-(BOOL) checkLimitCharacter:(NSInteger)limit{
    return ([self.text length] <= limit) ? YES: NO;
}

@end

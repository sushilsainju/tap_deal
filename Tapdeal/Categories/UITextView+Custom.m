//
//  UITextView+Custom.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/11/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "UITextView+Custom.h"
#import "SharedStore.h"

@implementation UITextView (Custom)



-(void) setTheme{
    self.layer.borderColor = THEME_COLOR_LIGHT.CGColor;
    self.layer.borderWidth = 1.0;
    self.textAlignment = NSTextAlignmentCenter;
    self.font = App_Default_font_13;
    self.layer.cornerRadius = 14.0f;
}



-(BOOL) isEmpty{
    return [self.text length] ? NO: YES;
}

-(void) setSmallFont{
    [self setFont: App_Default_font_12];
    [self setTextColor:THEME_COLOR];
    
}

-(void) setNormalFont{
    [self setFont: App_Default_font_14];
    [self setTextColor:THEME_COLOR];
    
}

-(void) setNormalGreyFont{
    [self setFont: App_Default_font_14];
    [self setTextColor:THEME_COLOR_GREY];
    
}

-(BOOL) checkLimitCharacter:(NSInteger)limit{
    return ([self.text length] <= limit) ? YES: NO;
}


@end

//
//  UIButton+Custom.m
//  Machineshop
//
//  Created by Neetin Mac Mini on 6/17/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "UIButton+Custom.h"
#import "SharedStore.h"

@implementation UIButton (Custom)


-(void)setThemeWithTitleText: (NSString *) title withFrame:(CGRect) frame{
    [self setFrame:frame];
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setBackgroundColor: THEME_COLOR];
    [self.titleLabel setFont: App_Default_font_12];

}

-(void) setDisabledTheme{
    self.enabled = NO;
    [self setBackgroundColor:THEME_COLOR_DISABLED];
}

-(void) setEnabledTheme{
    self.enabled = YES;
    [self setBackgroundColor:THEME_COLOR];
}


-(void) setCustomFont{
    [self.titleLabel setFont: App_Default_font_16_Medium];
    [self setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
}

-(void) setCustomSmallFont{
    [self.titleLabel setFont: App_Default_font_14];
    [self setTitleColor:THEME_COLOR forState:UIControlStateNormal];
}

-(void)setCustomFontWithWhiteColor{
    [self.titleLabel setFont: App_Default_font_16_Medium];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end

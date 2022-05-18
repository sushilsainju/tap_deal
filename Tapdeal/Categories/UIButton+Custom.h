//
//  UIButton+Custom.h
//  Machineshop
//
//  Created by Neetin Mac Mini on 6/17/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Custom)


-(void)setThemeWithTitleText: (NSString *) title withFrame:(CGRect) frame;

-(void) setDisabledTheme;

-(void) setEnabledTheme;


-(void) setCustomFont;

-(void) setCustomSmallFont;

-(void)setCustomFontWithWhiteColor;

@end

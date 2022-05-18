//
//  UILabel+Custom.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/17/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "UILabel+Custom.h"
#import "SharedStore.h"

@implementation UILabel (Custom)


-(void) setLargeFont{
    [self setFont: App_Default_font_24_Medium];
    [self setTextColor:THEME_COLOR];
    
}

-(void) setNavBarFont{
    [self setFont: App_Default_font_16_Medium];
    [self setTextColor:THEME_NAVBAR_COLOR];
    
}

-(void) setNormalFont{
    [self setFont: App_Default_font_14];
    [self setTextColor:THEME_COLOR];
    
}

-(void) setNormalBoldFont{
    [self setFont: App_Default_font_16_Medium];
    [self setTextColor:THEME_COLOR];
    
}


-(void) setSmallFont{
    [self setFont: App_Default_font_11];
    [self setTextColor:THEME_DESCRIPTIONCOLOR];
    
}

-(void) setTinyFont{
    [self setFont: App_Default_font_10_Light];
    [self setTextColor:THEME_COLOR_GREY];
    
}

-(void) strikeThrough{
    
//    CGSize textSize = [[self text] sizeWithFont:[self font]];
    CGSize textSize = [[self text] sizeWithAttributes:
                   @{NSFontAttributeName:
                         [self font]}];
    CGFloat strikeWidth = textSize.width;
    CGRect rect = self.frame;
    
    float x = self.frame.size.width - strikeWidth;
    
    UIView* slabel = [[UIView alloc] initWithFrame:CGRectMake(x, rect.size.height/2, strikeWidth, 1)];
    [slabel setBackgroundColor:self.textColor];
    [self addSubview:slabel];
    
}

@end

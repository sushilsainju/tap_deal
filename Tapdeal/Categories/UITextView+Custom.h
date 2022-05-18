//
//  UITextView+Custom.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/11/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Custom)


-(void) setTheme;

-(BOOL) isEmpty;

-(void) setSmallFont;

-(void) setNormalFont;

-(void) setNormalGreyFont;

-(BOOL) checkLimitCharacter:(NSInteger)limit;

@end

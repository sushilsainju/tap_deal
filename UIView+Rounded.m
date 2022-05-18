//
//  UIView+Rounded.m
//  FranchiseCare
//
//  Created by samesh on 3/8/14.
//  Copyright (c) 2014 franchisecare. All rights reserved.
//

#import "UIView+Rounded.h"

@implementation UIView (Rounded)

+(void)setRoundedBorder:(CALayer *)item withRadius:(CGFloat)cornerRadius{
	CALayer *layer = item;
	layer.masksToBounds = YES;
	layer.cornerRadius = cornerRadius;
	layer.borderWidth = 1.5;
	UIColor *grayColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.5];
	layer.borderColor = [grayColor CGColor];
}

+(void)setRoundedBorder:(CALayer *)item withWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor andRadius:(CGFloat)cornerRadius {
	CALayer *layer = item;
	layer.masksToBounds = YES;
	layer.cornerRadius = cornerRadius;
	layer.borderWidth = borderWidth;
	layer.borderColor = [borderColor CGColor];
}

+(void)setRoundedClearBorder:(CALayer *)item withRadius:(CGFloat)cornerRadius {
	CALayer *layer = item;
	layer.masksToBounds = YES;
	layer.cornerRadius = cornerRadius;
	layer.borderWidth = 1.5;
	layer.borderColor = [[UIColor clearColor] CGColor];
}

@end

//
//  UIView+Rounded.h
//  FranchiseCare
//
//  Created by samesh on 3/8/14.
//  Copyright (c) 2014 franchisecare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Rounded)

+(void)setRoundedBorder:(CALayer *)item withRadius:(CGFloat)cornerRadius;
+(void)setRoundedBorder:(CALayer *)item withWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor andRadius:(CGFloat)cornerRadius;
+(void)setRoundedClearBorder:(CALayer *)item withRadius:(CGFloat)cornerRadius;


@end

//
//  RoundedButton.m
//  TrackDown
//
//  Created by Gocy on 16/7/27.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "RoundedButton.h"

@interface RoundedButton ()


@end

@implementation RoundedButton



#pragma mark - Setters

-(void)setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

-(void)setBorderWidth:(CGFloat)borderWidth{
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

@end

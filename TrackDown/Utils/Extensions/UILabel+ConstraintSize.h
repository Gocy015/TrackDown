//
//  UILabel+ConstraintSize.h
//  TrackDown
//
//  Created by Gocy on 16/8/25.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel(ConstraintSize)

+(instancetype)mediumLabelWithSize:(CGFloat)size;

-(void)resizeWithConstraintSize:(CGSize)size;

@end

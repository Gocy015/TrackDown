//
//  UILabel+ConstraintSize.m
//  TrackDown
//
//  Created by Gocy on 16/8/25.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "UILabel+ConstraintSize.h"

@implementation UILabel(ConstraintSize)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(instancetype)mediumLabelWithSize:(CGFloat)size{
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
    label.textColor = [UIColor colorWithWhite:1 alpha:0.9];
    
    return label;
}

-(void)resizeWithConstraintSize:(CGSize)size{
    NSString *text = self.text;
    self.numberOfLines = 0;
    CGRect expectedRect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil];
    self.bounds = CGRectMake(0, 0, expectedRect.size.width, expectedRect.size.height);
}

@end

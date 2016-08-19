//
//  TipView.m
//  TrackDown
//
//  Created by Gocy on 16/8/8.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "TipView.h"

@interface TipView ()

@property (nonatomic) CGFloat bgAlpha;

@end



@implementation TipView


#pragma mark - Initializer

-(instancetype)initWithTip:(NSString *)tip triangleDirection:(TriangleDirection)dir triangleXPosition:(CGFloat)xPos triangleYPosition:(CGFloat)yPos{
    if (self = [super initWithTriangleDirection:dir triangleXPosition:xPos triangleYPosition:yPos]) {
//        _triXPosition = xPos;
//        _triYPosition = yPos;
//        _direction = dir;
        self.maxTriangleSize = CGSizeMake(10, 5);
        [self setTip:tip];
    }
    
    return self;
}




#pragma mark - Instance Methods


#pragma mark - Helpers#pragma mark - Setters & Getter


-(UILabel *)label{
    UILabel *l = (UILabel *)self.contentView;
    if (!l) {
        l = [UILabel new];
        l.font = [UIFont systemFontOfSize:11 weight:UIFontWeightUltraLight];
        
//        [self addSubview:l];
        self.contentView = l;
        self.alpha = 0.7;
    }
    return l;
}

-(void)setTip:(NSString *)tip{
    if ([_tip isEqualToString:tip]) {
        return;
    }
    UILabel *label = [self label];
    label.text = tip;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    
    CGSize labelSize = label.bounds.size;
    
    CGFloat labelWidthPortion = 0.1;
    CGFloat labelHeightPortion = 0.6;
    
    self.bounds = CGRectMake(0, 0, labelSize.width * (1 + labelWidthPortion), labelSize.height * (1 + labelHeightPortion) + [self triangleHeight]);
    
}
 

@end

//
//  GuideInfo.m
//  TrackDown
//
//  Created by Gocy on 16/8/25.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "GuideInfo.h"

@implementation GuideInfo

#pragma mark - Life Cycle

-(instancetype)init{
    if (self = [super init]) {
        _guideRect = CGRectZero;
        _guideDescriptionView = nil;
        _relativePosition = CGPointZero;
        _cornerRadius = 0.0f;
        _hPos = HorizontalPosition_Unknown;
        _vPos = VerticalPosition_Unknown;
    }
    return self;
}

-(instancetype)initWithGuideRect:(CGRect)guideRect descriptionView:(UIView *)desView relativePosition:(CGPoint)relPos cornerRadius:(CGFloat)cornerRadius{
    if (self = [super init]) {
    
        _guideRect = guideRect;
        _guideDescriptionView = desView;
        _relativePosition = relPos;
        _cornerRadius = cornerRadius;
        _hPos = HorizontalPosition_Unknown;
        _vPos = VerticalPosition_Unknown;
    }
    
    return self;
    
}

-(instancetype)initWithGuideRect:(CGRect)guideRect descriptionView:(UIView *)desView verticalPosition:(VerticalPosition)vPos horizontalPosition:(HorizontalPosition)hPos cornerRadius:(CGFloat)cornerRadius{
    if (self = [super init]) {
        
        _guideRect = guideRect;
        _guideDescriptionView = desView;
        _relativePosition = CGPointZero;
        _cornerRadius = cornerRadius;
        _hPos = hPos;
        _vPos = vPos;
    }
    
    return self;
}

@end

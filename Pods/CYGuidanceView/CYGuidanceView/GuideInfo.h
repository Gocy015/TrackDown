//
//  GuideInfo.h
//  TrackDown
//
//  Created by Gocy on 16/8/25.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIkit.h>

typedef NS_ENUM(NSUInteger , VerticalPosition){
    VerticalPosition_Unknown,
    VerticalPosition_Top ,
    VerticalPosition_Middle ,
    VerticalPosition_Bottom
};

typedef NS_ENUM(NSUInteger , HorizontalPosition){
    HorizontalPosition_Unknown,
    HorizontalPosition_Left,
    HorizontalPosition_Middle,
    HorizontalPosition_Right
};

@interface GuideInfo : NSObject

-(instancetype)initWithGuideRect:(CGRect)guideRect descriptionView:(UIView *)desView relativePosition:(CGPoint)relPos cornerRadius:(CGFloat)cornerRadius;


-(instancetype)initWithGuideRect:(CGRect)guideRect descriptionView:(UIView *)desView verticalPosition:(VerticalPosition)vPos horizontalPosition:(HorizontalPosition)hPos cornerRadius:(CGFloat)cornerRadius;

@property (nonatomic) CGRect guideRect;
@property (nonatomic ,strong) UIView *guideDescriptionView;
@property (nonatomic) CGPoint relativePosition;
@property (nonatomic) CGFloat cornerRadius;

/**
 *  Built-in relative vertical position ,this value will be ignored if property relativePosition is set to non-zero value.
 */
@property (nonatomic) VerticalPosition vPos;
/**
 *  Built-in relative horizontal position ,this value will be ignored if property relativePosition is set to non-zero value.
 */
@property (nonatomic) HorizontalPosition hPos;

@end

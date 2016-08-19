//
//  ArrowContainerView.h
//  TrackDown
//
//  Created by Gocy on 16/8/19.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger ,TriangleDirection){
    TriangleDirection_Top,
    TriangleDirection_Left,
    TriangleDirection_Bottom,
    TriangleDirection_Right
};


@interface ArrowContainerView : UIView


-(instancetype)initWithTriangleDirection:(TriangleDirection)dir triangleXPosition:(CGFloat)xPos triangleYPosition:(CGFloat)yPos;

-(CGFloat)triangleHeight;

-(CGFloat)triangleWidth;


@property (nonatomic ,strong) UIColor *backgroundFillColor;
@property (nonatomic ,weak) UIView *contentView;
@property (nonatomic) CGFloat triYPosition;
@property (nonatomic) CGFloat triXPosition;
@property (nonatomic) CGSize maxTriangleSize;
@property (nonatomic) TriangleDirection direction;
@property (nonatomic) CGPoint showPoint;



@end

//
//  TipView.h
//  TrackDown
//
//  Created by Gocy on 16/8/8.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger ,TriangleDirection){
    TriangleDirection_Top,
    TriangleDirection_Left,
    TriangleDirection_Bottom,
    TriangleDirection_Right
};

@interface TipView : UIView


@property (nonatomic ,copy) NSString *tip;
@property (nonatomic) CGFloat triYPosition;
@property (nonatomic) CGFloat triXPosition;
@property (nonatomic) TriangleDirection direction;

-(instancetype)initWithTip:(NSString *)tip triangleDirection:(TriangleDirection)dir triangleXPosition:(CGFloat)xPos triangleYPosition:(CGFloat)yPos;

-(void)setShowPoint:(CGPoint)p;



@end

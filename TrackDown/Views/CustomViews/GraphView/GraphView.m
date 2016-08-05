//
//  GraphView.m
//  TrackDown
//
//  Created by Gocy on 16/8/5.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "GraphView.h"
#import "UIColor+Hex.h"


@interface GraphView (){
    UIColor * _startColor;
    UIColor * _endColor;
    
    CGFloat _widthPerElement;
    CGFloat _topBorder ;
    CGFloat _bottomBorder;
    CGFloat _graphHeight;
    CGFloat _maxValue;
    CGFloat _maxHeight;
}

@end

@implementation GraphView

#pragma mark - Life Cycle

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initColors];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        [self initColors];
    }
    return self;
}



#pragma mark - Draw Method

-(void)drawRect:(CGRect)rect{
    if (self.graphPoints.count <= 0) {
        return;
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)];
    [path addClip];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef colors[] = {_startColor.CGColor ,_endColor.CGColor};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat colorLocs[] = {0.0f,1.0f};
    
    CFArrayRef cfcolors = CFArrayCreate(NULL, (const void **)colors, 2, &kCFTypeArrayCallBacks);
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, cfcolors, colorLocs);
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(0, self.bounds.size.height);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    
    CGFloat maxWidth = self.bounds.size.width;
    _maxHeight = self.bounds.size.height;
    
    _widthPerElement = maxWidth / (CGFloat)self.graphPoints.count ;
    
    _topBorder = _maxHeight * 0.2;
    _bottomBorder = _maxHeight * 0.2;
    _graphHeight = _maxHeight - _topBorder - _bottomBorder;
    _maxValue = [self getMaxValue];
    
    [[UIColor whiteColor] setFill];
    [[UIColor whiteColor] setStroke];
    
    UIBezierPath *graphPath = [UIBezierPath new];
    [graphPath moveToPoint:CGPointMake([self xPositionAtIndex:0], [self yPositionAtIndex:0])];
    
    for (int i = 0;  i<self.graphPoints.count;  ++i) {
        CGPoint next = CGPointMake([self xPositionAtIndex:i], [self yPositionAtIndex:i]);
        [graphPath addLineToPoint:next];
    }
    
    CGContextSaveGState(context);
    
    UIBezierPath *clippingPath = [graphPath copy];
    
    [clippingPath addLineToPoint:CGPointMake([self xPositionAtIndex:self.graphPoints.count - 1], _maxHeight)];
    [clippingPath addLineToPoint:CGPointMake([self xPositionAtIndex:0], _maxHeight)];
    [clippingPath closePath];
    
    [clippingPath addClip];
    
    CGFloat highestY = _topBorder;
    startPoint = CGPointMake([self xPositionAtIndex:0], highestY);
    endPoint = CGPointMake(startPoint.x, _maxHeight);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    
    CGContextRestoreGState(context);
    
    CGContextSetLineWidth(context, 2);
    [graphPath stroke];
    
    
    CGFloat radius = 4.0;
    for (int i = 0 ; i < self.graphPoints.count;  ++i) {
        CGPoint cirPoint = CGPointMake([self xPositionAtIndex:i], [self yPositionAtIndex:i]);
        
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(cirPoint.x - radius/2, cirPoint.y - radius/2, radius, radius)];
        [circle fill];
    }
    
    UIBezierPath *linePath = [UIBezierPath new];
    
    [linePath moveToPoint:CGPointMake(0, highestY)];
    [linePath addLineToPoint:CGPointMake(maxWidth, highestY)]; // topLine
    
    
    [linePath moveToPoint:CGPointMake(0, highestY + _graphHeight / 2)];
    [linePath addLineToPoint:CGPointMake(maxWidth, highestY + _graphHeight / 2)]; // midLine
    
    [linePath moveToPoint:CGPointMake(0, highestY + _graphHeight )];
    [linePath addLineToPoint:CGPointMake(maxWidth, highestY + _graphHeight)]; // midLine
    
    UIColor *lineColor = [UIColor colorWithWhite:1 alpha:0.25];
    [lineColor setStroke];
    CGContextSetLineWidth(context, 1);
    [linePath stroke];
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
}



#pragma mark - Helpers

-(void)initColors{
    _startColor = [UIColor colorFromHex:@"#FAE9DE"];
    _endColor = [UIColor colorFromHex:@"#FC4F08"];
    self.backgroundColor = [UIColor clearColor];
}

-(CGFloat)getMaxValue{
    if ([self.graphPoints count] <= 0) {
        return 0;
    }
    CGFloat max = [self.graphPoints[0] doubleValue];
    for (int i = 1; i < self.graphPoints.count; ++i) {
        if ([self.graphPoints[i] doubleValue] > max) {
            max = [self.graphPoints[i] doubleValue];
        }
    }
    return max;
}

-(CGFloat)xPositionAtIndex:(NSUInteger)idx{
    return 0.5 * _widthPerElement + idx * _widthPerElement;
}

-(CGFloat)yPositionAtIndex:(NSUInteger)idx {
    CGFloat v = [self.graphPoints[idx] doubleValue];
    CGFloat absoluteHeight = v/_maxValue * _graphHeight; //CG coordinates , y is at bottom
    CGFloat flipHeight = _graphHeight + _topBorder - absoluteHeight;
    
    return flipHeight;
}


//#pragma mark - Setters
//-(void)setGraphPoints:(NSArray *)graphPoints{
//    _graphPoints = graphPoints;
//    [self setNeedsDisplay];
//}

@end

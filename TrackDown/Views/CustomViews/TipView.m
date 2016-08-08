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
@property (nonatomic) CGPoint showPoint;

@end

static const CGFloat kTriangleXPortion = 0.12;
static const CGFloat kTriangleYPortion = 0.12;


@implementation TipView


#pragma mark - Initializer

-(instancetype)initWithTip:(NSString *)tip triangleDirection:(TriangleDirection)dir triangleXPosition:(CGFloat)xPos triangleYPosition:(CGFloat)yPos{
    if (self = [super init]) {
        _triXPosition = xPos;
        _triYPosition = yPos;
        _direction = dir;
        [self setTip:tip];
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.8;
    }
    
    return self;
}


-(void)drawRect:(CGRect)rect{
    
    UIBezierPath *triangle = [self bezierPathForTriangle];
    
    [[UIColor blackColor] setFill];
    [triangle fill];
    
    UIBezierPath *rectangle = [self bezierPathForRoundedRect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [rectangle addClip];
    [rectangle fill];
    
    CGContextRestoreGState(context);
    
    
    
}


#pragma mark - Instance Methods

-(void)setShowPoint:(CGPoint)p{
    
    _showPoint = p;
    CGPoint origin;
    
    CGFloat maxWidth = self.bounds.size.width;
    CGFloat maxHeight = self.bounds.size.height;
    CGFloat x = maxWidth * _triXPosition;
    CGFloat y = maxHeight * _triYPosition;
    switch (_direction) {
        case TriangleDirection_Top:
            origin = CGPointMake(p.x - x, p.y);
            break;
        case TriangleDirection_Bottom:
            origin = CGPointMake(p.x - x, p.y-maxHeight);
            break;
            
        case TriangleDirection_Left:
            origin = CGPointMake(p.x, p.y - y);
            break;
            
        case TriangleDirection_Right:
            origin = CGPointMake(p.x - maxWidth, p.y - y);
            break;
            
        default:
            break;
    }
    
    self.frame = CGRectMake(origin.x , origin.y, maxWidth, maxHeight);
}


#pragma mark - Helpers
-(UIBezierPath *)bezierPathForTriangle{
    UIBezierPath *triPath = [UIBezierPath new];
    
    CGFloat maxWidth = self.bounds.size.width;
    CGFloat maxHeight = self.bounds.size.height;
    CGFloat x = maxWidth * _triXPosition;
    CGFloat y = maxHeight * _triYPosition;
    CGFloat w = [self triangleWidth];
    CGFloat h = [self triangleHeight];
    //triangleView
    switch (_direction) {
        case TriangleDirection_Top:
            [triPath moveToPoint:CGPointMake(x, 0)];
            [triPath addLineToPoint:CGPointMake(x-w/2.0, h)];
            [triPath addLineToPoint:CGPointMake(x+w/2.0, h)];
            [triPath closePath];
            break;
        case TriangleDirection_Bottom:
            [triPath moveToPoint:CGPointMake(x, maxHeight)];
            [triPath addLineToPoint:CGPointMake(x-w/2.0, maxHeight-h)];
            [triPath addLineToPoint:CGPointMake(x+w/2.0, maxHeight-h)];
            [triPath closePath];
            break;
            
        case TriangleDirection_Left:
            [triPath moveToPoint:CGPointMake(0, y)];
            [triPath addLineToPoint:CGPointMake(w, y-h/2.0)];
            [triPath addLineToPoint:CGPointMake(w, y+h/2.0)];
            [triPath closePath];
            
            break;
            
        case TriangleDirection_Right:
            
            [triPath moveToPoint:CGPointMake(maxWidth, y)];
            [triPath addLineToPoint:CGPointMake(maxWidth - w, y-h/2.0)];
            [triPath addLineToPoint:CGPointMake(maxWidth - w, y+h/2.0)];
            [triPath closePath];
            break;
            
            
    }
    return triPath;
}

-(UIBezierPath *)bezierPathForRoundedRect{
    CGRect rect = [self boundingRectForRoundedRect];
    
    CGFloat maxWidth = self.bounds.size.width;
    CGFloat maxHeight = self.bounds.size.height;
    
    
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:MIN(maxWidth, maxHeight) * 0.1];
    
    return rectPath;
}


-(CGRect)boundingRectForRoundedRect{
    CGRect rect;
    
    CGFloat maxWidth = self.bounds.size.width;
    CGFloat maxHeight = self.bounds.size.height;
    
    CGFloat w = maxWidth - [self triangleWidth] + 1;
    CGFloat h = maxHeight - [self triangleHeight] + 1;
    
    switch (_direction) {
        case TriangleDirection_Top:
            rect = CGRectMake(0, [self triangleHeight] - 1, maxWidth, h);
            break;
        case TriangleDirection_Bottom:
            
            rect = CGRectMake(0, 0, maxWidth, h);
            
            break;
            
        case TriangleDirection_Left:
            rect = CGRectMake([self triangleWidth] - 1, 0, w, maxHeight);
            
            break;
            
        case TriangleDirection_Right:
            
            rect = CGRectMake(0, 0, w, maxHeight);
            break;
    }
    return rect;
}

#pragma mark - Setters & Getter

-(CGFloat)triangleWidth{
    if (_direction == TriangleDirection_Left || _direction == TriangleDirection_Right) {
        return MIN(kTriangleXPortion * self.bounds.size.width , 5);;
    }
    return MIN(kTriangleXPortion * self.bounds.size.width , 10);
    
}

-(CGFloat)triangleHeight{
    if (_direction == TriangleDirection_Left|| _direction == TriangleDirection_Right) {
        return MIN(kTriangleYPortion * self.bounds.size.height * 3 , 10);;
    }
    
    return  MIN(kTriangleYPortion * self.bounds.size.height , 5);
 
}

-(UILabel *)label{
    UILabel *l = [self viewWithTag:222];
    if (!l) {
        l = [UILabel new];
        l.font = [UIFont systemFontOfSize:11 weight:UIFontWeightUltraLight];
        l.tag = 222;
        [self addSubview:l];
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
    
    CGRect rect = [self boundingRectForRoundedRect];
    
    label.frame = CGRectMake(rect.origin.x + (rect.size.width - labelSize.width) / 2.0, rect.origin.y + (rect.size.height - labelSize.height) / 2.0, labelSize.width, labelSize.height);
    
    self.showPoint = self.showPoint; // trigger setter to re-locate
    
    [self setNeedsDisplay];
}
 

@end

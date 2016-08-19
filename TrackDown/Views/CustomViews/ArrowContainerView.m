//
//  ArrowContainerView.m
//  TrackDown
//
//  Created by Gocy on 16/8/19.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "ArrowContainerView.h"



static const CGFloat kTriangleXPortion = 0.12;
static const CGFloat kTriangleYPortion = 0.12;

@implementation ArrowContainerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithTriangleDirection:(TriangleDirection)dir triangleXPosition:(CGFloat)xPos triangleYPosition:(CGFloat)yPos{
    if (self = [super init]) {
        _triXPosition = xPos;
        _triYPosition = yPos;
        _direction = dir;
        
        _maxTriangleSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        _backgroundFillColor = [UIColor blackColor];
        
        self.backgroundColor = [UIColor clearColor];
//        self.alpha = 0.8;
    }
    return self;
}


-(void)drawRect:(CGRect)rect{
    
    UIBezierPath *triangle = [self bezierPathForTriangle];
    
    [self.backgroundFillColor setFill];
    [triangle fill];
    
    UIBezierPath *rectangle = [self bezierPathForRoundedRect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [rectangle addClip];
    [rectangle fill];
    
    CGContextRestoreGState(context);
    
    
    
}


#pragma mark - Setters & Getters

-(void)setContentView:(UIView *)contentView{
    if (_contentView) {
        [_contentView removeFromSuperview];
    }
    if (![contentView isDescendantOfView:self]) {
        [self addSubview:contentView];
    }
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _contentView = contentView;
    
    //estimated size
//    self.bounds = CGRectMake(0, 0, _contentView.bounds.size.width * 1.2, _contentView.bounds.size.height * 1.2);
}

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


-(void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    
    CGRect rect = [self boundingRectForRoundedRect];
    
    _contentView.translatesAutoresizingMaskIntoConstraints = YES;
    _contentView.frame = CGRectMake(rect.origin.x + (rect.size.width - _contentView.bounds.size.width) / 2.0, rect.origin.y + (rect.size.height - _contentView.bounds.size.height) / 2.0, _contentView.bounds.size.width, _contentView.bounds.size.height);
    
    self.showPoint = self.showPoint; // trigger setter to re-locate
    
    [self setNeedsDisplay];
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
    
    switch (self.direction) {
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



-(CGFloat)triangleWidth{
    if (_direction == TriangleDirection_Left || _direction == TriangleDirection_Right) {
        return MIN(kTriangleXPortion * self.bounds.size.width , _maxTriangleSize.height);;
    }
    return MIN(kTriangleXPortion * self.bounds.size.width , _maxTriangleSize.width);
    
}

-(CGFloat)triangleHeight{
    if (_direction == TriangleDirection_Left|| _direction == TriangleDirection_Right) {
        return MIN(kTriangleYPortion * self.bounds.size.height * 3 , _maxTriangleSize.width);;
    }
    
    return  MIN(kTriangleYPortion * self.bounds.size.height , _maxTriangleSize.height);
    
}

//-(CGFloat)triWidthWithContentViewWidth:(CGFloat)contentWidth{
//    
//}
//
//
//-(CGFloat)triHeightWithContentViewHeight:(CGFloat)contentHeight{
//    
//}
@end

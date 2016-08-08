//
//  GraphView.m
//  TrackDown
//
//  Created by Gocy on 16/8/5.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "GraphView.h"
#import "UIColor+Hex.h"
#import "Masonry.h"
#import "TipView.h"


@interface GraphView (){
    UIColor * _startColor;
    UIColor * _endColor;
    UIColor * _lineColor;
    UIColor * _circleColor;
    
    CGFloat _widthPerElement;
    CGFloat _topBorder ;
    CGFloat _bottomBorder;
    CGFloat _graphHeight;
    CGFloat _maxValue;
    CGFloat _maxHeight;
}

@property (nonatomic ,strong) TipView *tipView;

@end

@implementation GraphView

#pragma mark - Life Cycle

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initColors];
        [self initGestures];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        [self initColors];
        [self initGestures];
    }
    return self;
}

-(void)dealloc{
    if (_tipView) {
        [_tipView removeFromSuperview];
        _tipView = nil;
    }
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
    
    _topBorder = _maxHeight * 0.22;
    _bottomBorder = _maxHeight * 0.2;
    _graphHeight = _maxHeight - _topBorder - _bottomBorder;
    _maxValue = [self getMaxValue];
    
    [_lineColor setFill];
    [_lineColor setStroke];
    
    UIBezierPath *graphPath = [UIBezierPath new];
    [graphPath moveToPoint:CGPointMake([self xPositionAtIndex:0], [self yPositionAtIndex:0])];
    
    for (int i = 0;  i<self.graphPoints.count;  ++i) {
        CGPoint next = CGPointMake([self xPositionAtIndex:i], [self yPositionAtIndex:i]);
        [graphPath addLineToPoint:next];
    }
    
    CGContextSaveGState(context);
    
    //draw line gradient
    
    UIBezierPath *clippingPath = [graphPath copy];
    
    [clippingPath addLineToPoint:CGPointMake([self xPositionAtIndex:self.graphPoints.count - 1], _maxHeight)];
    [clippingPath addLineToPoint:CGPointMake([self xPositionAtIndex:0], _maxHeight)];
    [clippingPath closePath];
    
    [clippingPath addClip];
    
    CGFloat highestY = _topBorder;
    startPoint = CGPointMake([self xPositionAtIndex:0], highestY);
    endPoint = CGPointMake(startPoint.x, _maxHeight);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    
    CGContextRestoreGState(context);//restore to clear clip
    
    
    //draw totalGradient
    CGContextSetLineWidth(context, 2);
    [graphPath stroke];
    
    
    //draw point
    
    CGContextSaveGState(context);
    [_circleColor setFill];
    CGFloat radius = 4.0;
    for (int i = 0 ; i < self.graphPoints.count;  ++i) {
        CGPoint cirPoint = CGPointMake([self xPositionAtIndex:i], [self yPositionAtIndex:i]);
        
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(cirPoint.x - radius/2, cirPoint.y - radius/2, radius, radius)];
        [circle fill];
    }
    CGContextRestoreGState(context);
    
    //draw line
    
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
    
    [self installLabels];
    
}



#pragma mark - Helpers

-(void)initColors{
//    _startColor = [UIColor colorFromHex:@"#ff99cc"];
//    _endColor = [UIColor colorFromHex:@"#cc0052"]; //pink
    
//    _startColor = [UIColor colorFromHex:@"#ff80df"];
//    _endColor = [UIColor colorFromHex:@"#b30086"]; //purple
    
    _startColor = [UIColor colorFromHex:@"#FABC96"];
    _endColor = [UIColor colorFromHex:@"#D15441"]; //orange - red
    
//    _startColor = [UIColor colorFromHex:@"#C4C4C4"];
//    _endColor = [UIColor colorFromHex:@"#6A6B6B"]; //gray - black
    
    _lineColor = [UIColor colorFromHex:@"#ffffff"];
    _circleColor = [UIColor colorFromHex:@"#ffffff"];
    
    
    self.backgroundColor = [UIColor clearColor];
}

-(void)initGestures{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self addGestureRecognizer:tap];
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


-(void)installLabels{
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }
    }
    //upper left year label
    UILabel *yearLabel = [UILabel new];
    yearLabel.text = [NSString stringWithFormat:@"%lu",self.year];
    yearLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:17];
    yearLabel.textColor = [UIColor whiteColor];
    [yearLabel sizeToFit];
    
    CGFloat top = (_topBorder - yearLabel.bounds.size.height) / 2.0f;

    [self addSubview:yearLabel];
    __weak typeof(self) superview = self;
    [yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superview).offset(15);
        make.top.equalTo(superview).offset(top);
    }];
    
    //month label
    CGFloat monthy = top + _topBorder + _graphHeight;
    for (NSInteger i = 0 ; i < _titles.count ; ++i){
        NSString *title = _titles[i];
        UILabel *monthLabel = [UILabel new];
        
        monthLabel.text = title;
        monthLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:12];
        monthLabel.textColor = [UIColor whiteColor];
        [monthLabel sizeToFit];
        
        [self addSubview:monthLabel];
        CGFloat x = [self xPositionAtIndex:i] - monthLabel.bounds.size.width/2;
        
        [monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superview).offset(x);
            make.top.equalTo(superview).offset(monthy);
        }];
    }
    
}


-(NSInteger)nearestIndexForXPosition:(CGFloat)x{
    NSInteger index = -1;
    for (NSInteger i = 0; i < _graphPoints.count;  ++i) {
        CGFloat midx = [self xPositionAtIndex:i];
        if (midx - _widthPerElement/2 <= x && midx + _widthPerElement/2 >= x) {
            index = i;
            break;
        }
    }
    return index;
}

-(void)showTip:(BOOL)show{
    if (show) {
        self.tipView.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.tipView.alpha = 1;
        }];
    }
    else{
        self.tipView.alpha = 1;
        [UIView animateWithDuration:0.2 animations:^{
            self.tipView.alpha = 0;
        }];
    }
}

#pragma mark - Actions

-(void)tapView:(UITapGestureRecognizer *)tap{
    
    if (self.tipView.alpha > 0) {
        [self showTip:NO];
        return ;
    }
    
    CGPoint p = [tap locationInView:self];
    
    
    
    //set to default apperance
    
    
    NSInteger index = [self nearestIndexForXPosition:p.x];
    
    if(index < 0){
        return ;
    }
    
    CGPoint sp = CGPointMake([self xPositionAtIndex:index], [self yPositionAtIndex:index]);
    
    self.tipView.direction = TriangleDirection_Bottom;
    self.tipView.triXPosition = 0.35;
    
    [self.tipView setTip:self.descriptions[index]];
    [self.tipView setShowPoint:sp];
    
    CGPoint tipOrigin = self.tipView.frame.origin;
    CGSize tipSize = self.tipView.frame.size;
    
    
    
    BOOL needsRedraw = NO;
    if (tipOrigin.x <= 0) { //too left
        CGFloat offset = fabs(tipOrigin.x);
        CGFloat movePortion = offset / tipSize.width;
        
        [self.tipView setTriXPosition:self.tipView.triXPosition - movePortion];
        
        needsRedraw = YES;
    }else if (tipOrigin.x + tipSize.width > self.bounds.size.width){ // too right
        
        CGFloat offset = fabs(self.bounds.size.width - tipOrigin.x - tipSize.width);
        CGFloat movePortion = offset / tipSize.width;
        
        [self.tipView setTriXPosition:self.tipView.triXPosition + movePortion];
        needsRedraw = YES;
    }
    
    if (tipOrigin.y <= 0) { // too high
        
        [self.tipView setDirection:TriangleDirection_Top];

        needsRedraw = YES;
    }else if (tipOrigin.y + tipSize.height > self.bounds.size.height){
        
        [self.tipView setDirection:TriangleDirection_Bottom];
        
        needsRedraw = YES;
    }
    
    if (needsRedraw) {
        [self.tipView setNeedsDisplay];
        [self.tipView setShowPoint:sp];
    }
    
    [self showTip:YES];
}

-(void)hideTip{
    if (_tipView) {
        _tipView.hidden = YES;
    }
}



#pragma mark - Getters

-(TipView *)tipView{
    if (!_tipView) {
        _tipView = [[TipView alloc] initWithTip:@"" triangleDirection:TriangleDirection_Bottom triangleXPosition:0.35 triangleYPosition:0.35];
        [self addSubview:_tipView];
        _tipView.alpha = 0;
    }
    
    return _tipView;
}

//#pragma mark - Setters
//-(void)setGraphPoints:(NSArray *)graphPoints{
//    _graphPoints = graphPoints;
//    [self setNeedsDisplay];
//}

@end

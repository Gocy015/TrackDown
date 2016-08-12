//
//  CYPieChart.m
//  TrackDown
//
//  Created by Gocy on 16/8/12.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "CYPieChart.h"
#import "PieChartDataObject.h"
#import "HighlightPie.h"

@interface CYPieChart (){
    NSInteger _tapIndex;
    NSInteger _lastIndex;
    double _sum;
}


@property (nonatomic ,strong) NSMutableArray *paths;
@property (nonatomic ,strong) NSMutableArray *startAngles;
@property (nonatomic ,strong) NSMutableArray *titleLabels;
@property (nonatomic ,weak) HighlightPie *pie;
@property (nonatomic ,weak) HighlightPie *pie2;

@end

static CGFloat kAnimationDuration = 0.3f;

@implementation CYPieChart

#pragma mark - Life Cycle

-(void)awakeFromNib{
    [self initialize];
}

-(instancetype)init{
    if (self = [super init]) {
        [self initialize];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    
    return self;
}




-(void)initialize{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:tap];
    
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowOffset = CGSizeMake(0, 6);
    self.backgroundColor = [UIColor clearColor];
    
    _tapIndex = -1;
    _lastIndex = -1;
    _moveRadius = 16;
    _moveScale = 1;
    _sum = 0.0;
}


-(void)dealloc{
    NSLog(@"CYPieChart dealloc");
    [self.paths removeAllObjects];
    for (UIView *v in self.titleLabels) {
        [v removeFromSuperview];
    }
    [self.titleLabels removeAllObjects];
}

#pragma mark - Drawing & Drawing Helpers
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    NSLog(@"Draw Rect");
    
    [self.paths removeAllObjects];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    
    CGPoint center = CGPointMake(self.bounds.size.width /2, self.bounds.size.height/2);
    CGFloat radius = self.bounds.size.width / 2 ;
    
    
    UIBezierPath *shadow = [UIBezierPath new];
    CGContextSaveGState(context);
    
    CGFloat lastAngle = M_PI;
    for (int i = 0; i < self.objects.count; ++i) {
        CGFloat angle = [self angleForObjectAtIndex:i];
        CGFloat startAngle = [self.startAngles[i] doubleValue];
        CGFloat endAngle = startAngle + angle;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [path addLineToPoint:center];
        [path closePath];
        
        if (_tapIndex == i || _lastIndex == i) {
            
            [[UIColor clearColor] setFill];
            
        }else{
            
            [self.colors[i] setFill];
            [shadow appendPath:path];
            
        }
        
        [path fill];
        
        [self.paths addObject:path];
        lastAngle = endAngle;
    }
    
    CGContextRestoreGState(context);
    
    
    self.layer.shadowPath = shadow.CGPath;
    

}


#pragma mark - Actions
-(void)didTap:(UITapGestureRecognizer *)tap{
    CGPoint p = [tap locationInView:self];
    BOOL found = NO;
    for (UIBezierPath *path in self.paths) {
        if ([path containsPoint:p]) {
            found = YES;
            NSInteger idx = [self.paths indexOfObject:path];
            if (idx == _tapIndex) {
                _tapIndex = -1;
            }else{
                _tapIndex = idx;
            }
            
            break;
        }
    }
    if (!found) {
        _tapIndex = -1;
    }
    
    NSInteger temp = _tapIndex;
    
    self.pie2.hidden = YES;
    self.pie2.path = nil;
    self.pie2.fillColor = nil;
        
    if (_lastIndex >= 0) {
        self.pie2.fillColor = self.pie.fillColor;
        self.pie2.path = self.pie.path;
        self.pie2.transform = self.pie.transform;
        [self.pie2 setNeedsDisplay];
        self.pie2.hidden = NO;
//        UILabel *label = self.titleLabels[_lastIndex];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.pie2.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _lastIndex = temp;
            self.pie2.hidden = YES;
            [self setNeedsDisplay];
        }];
    }else{
        _lastIndex = temp;
    }
    
    
    
    self.pie.hidden = YES;
    self.pie.path = nil;
    self.pie.fillColor = nil;
    self.pie.transform = CGAffineTransformIdentity;
    
    [self setNeedsDisplay];
    
    
    if (_tapIndex >= 0) {
        
        self.pie.fillColor = self.colors[_tapIndex];
        self.pie.path = self.paths[_tapIndex];
        [self.pie setNeedsDisplay];
        self.pie.hidden = NO;
        
        CGFloat range = [self angleForObjectAtIndex:_tapIndex];
        CGFloat start = [self.startAngles[_tapIndex] doubleValue];
        
        CGFloat angle = start + range/2.0;
       
        //TODO: -Animate
        CGAffineTransform trans;
        if ([self.colors count] > 1) {
            trans = CGAffineTransformMakeTranslation(cos(angle) * self.moveRadius, sin(angle) * self.moveRadius);
            trans = CGAffineTransformScale(trans, self.moveScale, self.moveScale);
        }else{
            trans = CGAffineTransformMakeScale(self.moveScale, self.moveScale);
        }
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.pie.transform = trans;
        }];
    }
    [self calculateStartAngles];
    [self setupTitleLabels];
}


-(void)updateApperance{
    [self setNeedsDisplay];
    [self calculateStartAngles];
    [self setupTitleLabels];
}

#pragma mark - Helpers


-(CGFloat)angleForObjectAtIndex:(NSUInteger)idx{
    if (_sum <= 0) {
        return 0;
    }
    CGFloat angle = M_PI * 2 * (self.objects[idx].value) / _sum;
    return angle;
}


-(void)calculateStartAngles{
    [self.startAngles removeAllObjects];
    CGFloat lastAngle = M_PI;
    for (int i = 0; i < self.objects.count; ++i) {
        CGFloat angle = [self angleForObjectAtIndex:i];
        CGFloat startAngle = lastAngle;
        lastAngle = startAngle + angle;
        
        [self.startAngles addObject:@(startAngle)];
    }
}

-(void)setupTitleLabels{
    if (self.titleLabels.count != self.objects.count) {
        for (UIView *v in self.titleLabels) {
            [v removeFromSuperview];
        }
        [self.titleLabels removeAllObjects];
        for (NSUInteger i = 0; i < self.objects.count; ++i) {
            
            UILabel *label = [UILabel new];
            label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
            label.textColor = [UIColor whiteColor];
            label.text = self.objects[i].title;
            label.shadowOffset = CGSizeMake(0, 4);
            
            [label sizeToFit];
            
            [self addSubview:label];
            [self.titleLabels addObject:label];
            
            CGFloat range = [self angleForObjectAtIndex:i];
            CGFloat start = [self.startAngles[i] doubleValue];
            
            CGFloat angle = start + range/2.0;
            CGPoint offset = CGPointMake(cos(angle) * self.bounds.size.width / 4 , sin(angle) * self.bounds.size.width / 4 );
            CGPoint center = CGPointMake(self.bounds.size.width / 2 , self.bounds.size.height / 2);
            
            label.center = CGPointMake(center.x + offset.x, center.y + offset.y);
        }
    }
    
    
    for (NSUInteger i = 0; i < self.objects.count; ++i) {
        
        UILabel *label = self.titleLabels[i];
        
        if (_tapIndex == i) {
            
            CGFloat range = [self angleForObjectAtIndex:i];
            CGFloat start = [self.startAngles[i] doubleValue];
            
            CGFloat angle = start + range/2.0 ;
            
            CGAffineTransform trans = CGAffineTransformMakeTranslation(cos(angle) * self.moveRadius, sin(angle) * self.moveRadius);
            trans = CGAffineTransformScale(trans, self.moveScale, self.moveScale);
            [UIView animateWithDuration:kAnimationDuration animations:^{
                label.transform = trans;
            }];
        }
        else if (_lastIndex != _tapIndex && _lastIndex == i) {
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                
                label.transform = CGAffineTransformIdentity;
            }];
        }
        
    }
}


#pragma mark - Setters & Getters


-(NSMutableArray *)paths{
    if (!_paths) {
        _paths = [NSMutableArray new];
    }
    return _paths;
}

-(NSMutableArray *)startAngles{
    if (!_startAngles) {
        _startAngles = [NSMutableArray new];
    }
    return _startAngles;
}

-(NSMutableArray *)titleLabels{
    if (!_titleLabels) {
        _titleLabels = [NSMutableArray new];
    }
    return _titleLabels;
}



-(HighlightPie *)pie{
    if (!_pie) {
        HighlightPie *p = [[HighlightPie alloc] initWithFrame:self.bounds];
        [self addSubview:p];
        p.hidden = YES;
        
        _pie = p;
    }
    [self sendSubviewToBack:_pie];
    return _pie;
}


-(HighlightPie *)pie2{
    if (!_pie2) {
        HighlightPie *p = [[HighlightPie alloc] initWithFrame:self.bounds];
        [self addSubview:p];
        p.hidden = YES;
        
        _pie2 = p;
    }
    [self sendSubviewToBack:_pie2];
    return _pie2;
}

-(void)setObjects:(NSArray<__kindof PieChartDataObject *> *)objects{
    _objects = objects;
    _sum = 0.0f;
    for (PieChartDataObject *obj in objects) {
        _sum += obj.value;
    }
}


@end

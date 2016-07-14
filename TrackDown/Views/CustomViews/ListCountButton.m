//
//  ListCountButton.m
//  TrackDown
//
//  Created by Gocy on 16/7/14.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "ListCountButton.h"
#import "UIImage+Resize.h"

@interface ListCountButton ()

@property (nonatomic ,weak) UIView *counterView;
@property (nonatomic ,weak) UIImageView *listView;
@property (nonatomic ,weak) UILabel *counterLabel;

@property (nonatomic ,weak) NSObject *obj;
@property (nonatomic) SEL selector;

@end

@implementation ListCountButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self constructSubviews];
        [self initGestures];
    }
    
    return self;
}

-(void)addTarget:(NSObject *)obj action:(SEL)selector{
    _obj = obj;
    _selector = selector;
}

-(void)setCount:(NSUInteger)count animated:(BOOL)animate{
    
    if (!animate) {
        _counterLabel.text = [NSString stringWithFormat:@"%li",count];
    }else{
        CGAffineTransform large = CGAffineTransformMakeScale(1.5, 1.5);
//        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            _counterView.transform = large;
//        } completion:^(BOOL finished) {
//            _counterLabel.text = [NSString stringWithFormat:@"%li",count];
//            [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                _counterView.transform = CGAffineTransformIdentity;
//            } completion:^(BOOL finished) {
//                
//            }];
//        }];
        
        [UIView animateKeyframesWithDuration:0.4 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.25 animations:^{
                _counterView.transform = large;
            }];
            _counterLabel.text = [NSString stringWithFormat:@"%li",count];
            
            [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.15 animations:^{
                _counterView.transform = CGAffineTransformIdentity;
            }];
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)showCounter:(BOOL)show{
    if (_counterView.hidden == show) {
        _counterView.hidden = !show;
    }
}

-(void)incrementBy:(NSUInteger)inc limit:(NSUInteger)limit animated:(BOOL)animate{
    NSUInteger num = [self getCurrentCount];
    if (num+inc <= limit) {
        [self setCount:num+inc animated:YES];
    }
}

-(void)decrementBy:(NSUInteger)dec limit:(NSUInteger)limit animated:(BOOL)animate{
    NSUInteger num = [self getCurrentCount];
    if (num-dec >= limit) {
        [self setCount:num-dec animated:YES];
    }
}

#pragma mark - Helpers

-(void)initGestures{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
}

-(void)tap{
    if (_obj && _selector) {
        [_obj performSelector:_selector withObject:nil afterDelay:0];
    }
}


-(NSUInteger)getCurrentCount{
    return [_counterLabel.text integerValue];
}

-(void)constructSubviews{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    UIImage *list = [UIImage imageNamed:@"list"];
    list = [list resize:self.frame.size];
    imageView.image = list;
    
    _listView = imageView;
    
    [self addSubview:imageView];
    
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) / 3.5;
    
    UIView *ct = [[UIView alloc]initWithFrame:CGRectMake(-radius / 2, -radius / 2, 2*radius, 2*radius)];
    ct.backgroundColor = [UIColor redColor];
    ct.layer.cornerRadius = radius;
    
    _counterView = ct;
    
    [self addSubview:ct];
    
    UILabel *label = [[UILabel alloc] initWithFrame:ct.bounds];
    label.font = [UIFont systemFontOfSize:8 weight:1.5];
    label.text = @"99";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [ct addSubview:label];
    
    _counterLabel = label;
}



@end

//
//  CYGuidanceView.m
//  TrackDown
//
//  Created by Gocy on 16/8/25.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "CYGuidanceView.h"

@interface CYGuidanceView ()

@property (nonatomic ,strong) NSMutableArray <NSArray <GuideInfo *> *> *steps;
@property (nonatomic) NSUInteger currentStep;
@property (nonatomic ,strong) UIImage *snapShot;
@property (nonatomic ,strong) NSMutableArray <UIImageView *> *imageViews;
@property (nonatomic ,weak) UILabel *hintLabel;


@end

@implementation CYGuidanceView

#pragma mark - Life Cycle

-(instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
        [self initGestures];
    }
    return self;
}


-(void)dealloc{
    NSLog(@"CYGuidanceView dealloc");
}

-(void)layoutSubviews{
    if(_hintLabel && [_hintText length] > 0){ // do not layout if there is no hint
        
        [self.hintLabel sizeToFit];
        
        self.hintLabel.frame = CGRectMake((self.bounds.size.width - self.hintLabel.bounds.size.width) / 2, self.bounds.size.height - self.hintLabel.bounds.size.height - 6, self.hintLabel.frame.size.width, self.hintLabel.frame.size.height);
    }
}

#pragma mark - Drawing
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    
//}


#pragma mark - Instance Method
-(void)addStep:(NSArray<GuideInfo *> *)step{
    [self.steps addObject:step];
}

-(void)showInView:(UIView *)view animated:(BOOL)animate{
    if (self.steps.count <= 0) {
        return ;
    }
    
    _currentStep = 0;
    
    UIImage *img = nil;
    //Take Shot
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    self.snapShot = [img copy];
    
    [self gotoStep:_currentStep];
    
    
    self.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
        
    
    [view addSubview:self];
    if (animate) {
        self.alpha = 0;
        [UIView animateWithDuration:0.22 animations:^{
            self.alpha = 1;
        }];
    }
    
}



#pragma mark - Helpers
-(void)initGestures{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextStep:)];
    [self addGestureRecognizer:tap];
}

-(void)nextStep:(UITapGestureRecognizer *)tap{
    
    
    if (self.currentStep == self.steps.count - 1){
//         no more step
        [self dismissAndCleanup];
        return ;
    }
    [self gotoStep:++self.currentStep];
    
}

-(void)gotoStep:(NSUInteger)s{
    
    if (s >= self.steps.count ) {
        return ;
    }
    
    //get shots
    NSArray <GuideInfo *> *infos = self.steps[s];
    NSArray <GuideInfo *> *lastInfos = @[];
    if (s >= 1) {
        lastInfos = self.steps[s - 1];
    }
    
    
    NSMutableArray *oldImageViews = [NSMutableArray arrayWithArray:self.imageViews];
    [self.imageViews removeAllObjects];
    
    for (GuideInfo *info in infos) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGRect converted = CGRectMake(info.guideRect.origin.x * scale, info.guideRect.origin.y * scale, info.guideRect.size.width * scale, info.guideRect.size.height * scale);
        CGImageRef imgRef = CGImageCreateWithImageInRect(self.snapShot.CGImage, converted);
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:info.guideRect];
        imgView.layer.cornerRadius = info.cornerRadius;
        
        UIImage *img = [UIImage imageWithCGImage:imgRef];
        
        imgView.image = img;
        
        CGImageRelease(imgRef);
        
        imgView.alpha = 0;
        [self.imageViews addObject:imgView];
        [self addSubview:imgView];
        
        if (!CGPointEqualToPoint(info.relativePosition, CGPointZero)) {
            info.guideDescriptionView.frame = CGRectMake(imgView.frame.origin.x + info.relativePosition.x, imgView.frame.origin.y + info.relativePosition.y, info.guideDescriptionView.frame.size.width, info.guideDescriptionView.frame.size.height);
        }else {
            CGPoint offset = [self calculateRelativePositionForRect:imgView.frame info:info];
            info.guideDescriptionView.frame = CGRectMake(imgView.frame.origin.x + offset.x, imgView.frame.origin.y + offset.y, info.guideDescriptionView.frame.size.width, info.guideDescriptionView.frame.size.height);
        }
        info.guideDescriptionView.alpha = 0;
        [self addSubview:info.guideDescriptionView];
    }
    
    
    
    [UIView animateWithDuration:0.22 animations:^{
        for (UIImageView *imgView in oldImageViews) {
            imgView.alpha = 0;
        }
        
        for (GuideInfo *info in lastInfos) {
            info.guideDescriptionView.alpha = 0;
        }
        
        
        for (UIImageView *imgView in self.imageViews) {
            imgView.alpha = 1;
        }
        for (GuideInfo *info in infos) {
            info.guideDescriptionView.alpha = 1;
        }
    } completion:^(BOOL finished) {
        for (UIImageView *imgView in oldImageViews) {
            [imgView removeFromSuperview];
        }
        for (GuideInfo *info in lastInfos) {
            [info.guideDescriptionView removeFromSuperview];
        }
        
        [oldImageViews removeAllObjects];
        
    }];
}

-(void)dismissAndCleanup{
    
    if(!self.superview){
        return ;
    }
    
    [self resignFirstResponder];
    
    [UIView animateWithDuration:0.22 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        for (UIImageView *imgView in self.imageViews) {
            [imgView removeFromSuperview];
        }
        
        for (GuideInfo *info in self.steps.lastObject) {
            [info.guideDescriptionView removeFromSuperview];
        }
        [self.imageViews removeAllObjects];
        
        [self.steps removeAllObjects];
        self.steps = nil;
        
        [self removeFromSuperview];
        
    }];
}

#pragma mark - Helpers

-(CGPoint)calculateRelativePositionForRect:(CGRect)rect info:(GuideInfo *)info{
    CGPoint ret = CGPointZero;
    CGSize guideSize = info.guideDescriptionView.frame.size;
    switch (info.vPos) { //Vertical position
        case VerticalPosition_Top:
            ret.y = - 6 - guideSize.height;
            break;
        case VerticalPosition_Bottom:
            ret.y = rect.size.height + 6;
            break;
            
        case VerticalPosition_Middle:
            ret.y = (rect.size.height - guideSize.height) / 2;
            break;
        default:
            break;
    }
    
    switch (info.hPos) {
        case HorizontalPosition_Left:
            ret.x = - guideSize.width - 6;
            break;
        case HorizontalPosition_Right:
            ret.x = rect.size.width + 6;
            break;
        case HorizontalPosition_Middle:
            ret.x = (rect.size.width - guideSize.width) / 2;
            break;
        default:
            break;
    }
    
    return ret;
}

#pragma mark - Getters & Setters

-(NSMutableArray <NSArray <GuideInfo *> *> *)steps{
    if (!_steps) {
        _steps = [NSMutableArray new];
    }
    return _steps;
}

-(NSMutableArray <UIImageView *> *)imageViews{
    if (!_imageViews) {
        _imageViews = [NSMutableArray new];
    }
    
    return _imageViews;
}

-(UILabel *)hintLabel{
    if (!_hintLabel) {
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        label.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        label.text = self.hintText;
        [label sizeToFit];
        [self addSubview:label];
        if([label.text length]){
            [label setNeedsLayout];
        }
        _hintLabel = label;
    }
    return _hintLabel;
}


-(void)setHintText:(NSString *)hintText{
    if ([_hintText isEqualToString: hintText]) {
        return ;
    }
    _hintText = hintText;
    self.hintLabel.text = hintText;
    [self.hintLabel setNeedsLayout];
}
@end

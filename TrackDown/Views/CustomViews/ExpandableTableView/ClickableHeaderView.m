//
//  ClickableHeaderView.m
//  TrackDown
//
//  Created by Gocy on 16/7/22.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "ClickableHeaderView.h"
#import "Masonry.h"

#define Width self.bounds.size.width
#define Height self.bounds.size.height

@interface ClickableHeaderView ()

@property (nonatomic ,weak) UILabel *headerLabel;
@property (nonatomic ,weak) UIView *bgView;

@end

@implementation ClickableHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Life cycle

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        [self initDefaultColors];
        [self constructViews];
        [self initGestures];
    }
    
    return self;
}


-(instancetype)init{
    if (self = [super init]) {
        
        [self initDefaultColors];
        [self constructViews];
        [self initGestures];
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self initDefaultColors];
        [self constructViews];
        [self initGestures];
    }
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self initDefaultColors];
        [self constructViews];
        [self initGestures];
    }
    return self;
}


#pragma mark - Helpers



-(void)initDefaultColors{
    _normalFillColor = [[UIColor grayColor] colorWithAlphaComponent:0.05];
    _normalTextColor = [UIColor blackColor];
    
    _selectedFillColor = [UIColor darkGrayColor];
    _selectedTextColor = [UIColor whiteColor];
}


-(void)constructViews{
    
    UIView *backgroundView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width, Height)];
    
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // 灰色背景
    UIView *contentView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width, Height)];
    contentView.backgroundColor = _normalFillColor;
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    _bgView = contentView;
    
    UIView *line1         = [[UIView alloc]init];
    line1.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.22];
    [contentView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView); 
        make.height.mas_equalTo(0.5);
        make.leading.equalTo(contentView);
        make.top.equalTo(contentView);
    }];
    
    UIView *line2         = [[UIView alloc] init];
    line2.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.22];
    
    [contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView);
        make.height.mas_equalTo(0.5);
        make.leading.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-0.5);
    }];
    
    
    UILabel *label = [UILabel new];
    //default
    label.font = [UIFont systemFontOfSize:14];
    label.text = _headerText;
    label.textColor = _normalTextColor;
    UIView *v = self;
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(v).offset(30);
        make.centerY.equalTo(v);
    }];
    _headerLabel = label;
}

-(void)initGestures{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickHeader)];
    [self addGestureRecognizer:tap];
}


#pragma mark - Actions

-(void)didClickHeader{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickHeaderView:)]) {
        [self.delegate didClickHeaderView:self];
    }
}


#pragma mark - Setters

-(void)setOpened:(BOOL)opened{
    
    if (opened == _opened) {
        return;
    }
    
    if (opened) {
        //animate open
        CGAffineTransform trans = CGAffineTransformMakeTranslation(16, 0);
        [UIView animateWithDuration:0.25 animations:^{
            self.headerLabel.transform = trans;
            self.headerLabel.font = [UIFont systemFontOfSize:14 weight:2.2];
            self.headerLabel.textColor = _selectedTextColor;
            self.bgView.backgroundColor = _selectedFillColor;
        }];
    }
    
    else{
        // animate close
        [UIView animateWithDuration:0.25 animations:^{
            self.headerLabel.transform = CGAffineTransformIdentity;
            self.headerLabel.font = [UIFont systemFontOfSize:14];
            self.headerLabel.textColor = _normalTextColor;
            self.bgView.backgroundColor = _normalFillColor;
        }];
    }
    
    _opened = opened;
}


-(void)setHeaderText:(NSString *)headerText{
    _headerText = headerText;
    self.headerLabel.text = headerText;
}

//-(void)setBounds:(CGRect)bounds{
//    [super setBounds:bounds];
//    [self layoutIfNeeded];
//}

@end

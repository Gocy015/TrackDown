//
//  BlankFooterView.m
//  TrackDown
//
//  Created by Gocy on 16/7/27.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "BlankFooterView.h"

@implementation BlankFooterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
    return self;
}

@end

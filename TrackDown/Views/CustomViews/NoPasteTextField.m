//
//  NoPasteTextField.m
//  TrackDown
//
//  Created by Gocy on 16/7/19.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "NoPasteTextField.h"

@implementation NoPasteTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(paste:)) {
        return NO;
    }
    return YES;
}

@end

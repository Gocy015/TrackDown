//
//  ListCountButton.h
//  TrackDown
//
//  Created by Gocy on 16/7/14.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCountButton : UIView

-(void)addTarget:(NSObject *)obj action:(SEL)selector;

-(void)setCount:(NSUInteger)count animated:(BOOL)animate;

-(void)showCounter:(BOOL)show;

-(void)incrementBy:(NSUInteger)inc limit:(NSUInteger)limit animated:(BOOL)animate;

-(void)decrementBy:(NSUInteger)dec limit:(NSUInteger)limit animated:(BOOL)animate;

@end

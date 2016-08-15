//
//  CYPieChart.h
//  TrackDown
//
//  Created by Gocy on 16/8/12.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieChartDataObject;

@interface CYPieChart : UIView

@property (nonatomic ,strong) NSArray <__kindof PieChartDataObject *> *objects;
@property (nonatomic ,strong) NSArray <UIColor *> *colors;

@property (nonatomic) CGFloat moveRadius;
@property (nonatomic) CGFloat moveScale;

-(void)updateApperance;

-(void)goNextWithClockwise:(BOOL)clockwise;

@end

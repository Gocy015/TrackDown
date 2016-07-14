//
//  TrainingViewController.h
//  TrackDown
//
//  Created by Gocy on 16/7/13.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TargetMuscle;

@interface TrainingViewController : UIViewController

@property (nonatomic ,strong)NSMutableArray <TargetMuscle*> *plan;


@end

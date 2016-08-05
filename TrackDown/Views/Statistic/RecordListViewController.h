//
//  RecordListViewController.h
//  TrackDown
//
//  Created by Gocy on 16/7/22.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TargetMuscle;

@interface RecordListViewController : UIViewController

@property (nonatomic ,strong) NSArray <TargetMuscle *> * workouts;

@end

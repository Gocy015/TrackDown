//
//  WorkoutPlanningViewController.h
//  TrackDown
//
//  Created by Gocy on 16/7/12.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TargetMuscle;

@protocol WorkoutPlanningDelegate <NSObject>

@required
-(void)didFinishPlanningWorkout:(NSArray <TargetMuscle *>*)plan;

@end

@interface WorkoutPlanningViewController : UIViewController

@property (nonatomic ,weak) id <WorkoutPlanningDelegate> delegate;

@end

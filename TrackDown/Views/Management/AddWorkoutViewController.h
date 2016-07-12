//
//  AddWorkoutViewController.h
//  TrackDown
//
//  Created by Gocy on 16/7/11.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TargetMuscle;

@interface AddWorkoutViewController : UIViewController

/**
 *  Specify nonnull value when adding concrete action.
 *  Otherwise it's considered as adding target muscle
 */
@property (nonatomic ,strong)TargetMuscle *muscle;

@end

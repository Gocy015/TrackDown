//
//  TargetMuscle.h
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WorkoutAction;

@interface TargetMuscle : NSObject

@property (nonatomic ,copy) NSString *muscle;
@property (nonatomic ,strong) NSMutableArray <__kindof WorkoutAction *> *actions;
 

@end

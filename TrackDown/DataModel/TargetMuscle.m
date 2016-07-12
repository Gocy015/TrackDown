//
//  TargetMuscle.m
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "TargetMuscle.h"
#import "WorkoutAction.h"

@implementation TargetMuscle

-(NSMutableArray *)actions{
    if (!_actions) {
        _actions = [NSMutableArray new];
    }
    return _actions;
}

@end

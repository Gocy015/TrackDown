//
//  WorkoutAction.m
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "WorkoutAction.h"

@implementation WorkoutAction

-(instancetype)initWithCoder:(NSCoder *)decoder{
    if (self = [super init]) {
        _actionName = [decoder decodeObjectForKey:@"actName"];
        _sets = [decoder decodeIntegerForKey:@"sets"];
        _weightPerSet = [decoder decodeObjectForKey:@"weightPerSet"];
        _repeatsPerSet = [decoder decodeObjectForKey:@"repsPerSet"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_actionName forKey:@"actName"];
    [encoder encodeInteger:_sets forKey:@"sets"];
    [encoder encodeObject:_weightPerSet forKey:@"weightPerSet"];
    [encoder encodeObject:_repeatsPerSet forKey:@"repsPerSet"];
}

-(void)setSets:(NSUInteger)sets{
    if (_sets != sets) {
        _sets = sets;
        _weightPerSet = [NSMutableArray new];
        _repeatsPerSet = [NSMutableArray new];
    }
}

@end

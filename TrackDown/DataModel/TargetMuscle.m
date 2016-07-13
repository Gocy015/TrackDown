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


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _muscle = [aDecoder decodeObjectForKey:@"muscle"];
        _actions = [aDecoder decodeObjectForKey:@"actions"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_muscle forKey:@"muscle"];
    [aCoder encodeObject:_actions forKey:@"actions"];
}


-(NSMutableArray *)actions{
    if (!_actions) {
        _actions = [NSMutableArray new];
    }
    return _actions;
}

@end

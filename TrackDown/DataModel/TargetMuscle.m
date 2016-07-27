//
//  TargetMuscle.m
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "TargetMuscle.h"
#import "WorkoutAction.h"
#import "ExpandableObjectProtocol.h"
#import "NSArray+Map.h"

@interface TargetMuscle () <ExpandableObject ,NSCopying>{
    BOOL _opened;
}

@end


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

-(id)copyWithZone:(NSZone *)zone{
    TargetMuscle *m = [TargetMuscle new];
    m.muscle = [self.muscle copyWithZone:zone]; 
    m.actions = [self.actions mutableCopyWithZone:zone];
    m.opened = _opened;
    return m;
}

-(NSMutableArray *)actions{
    if (!_actions) {
        _actions = [NSMutableArray new];
    }
    return _actions;
}


#pragma mark - Expandable Object Protocol

-(NSUInteger)countOfSecondaryObjects{
    return self.actions.count;
}

-(NSArray *)descriptionForSecondaryObjects{
    return [self.actions map:^NSString *(WorkoutAction *act) {
        return [NSString stringWithFormat:@"%@ x %lu 组",act.actionName,act.sets];
    }];
}

-(NSString *)description{
    return self.muscle;
}

-(BOOL)opened{
    return _opened;
}

-(void)setOpened:(BOOL)op{
    _opened = op;
}

@end

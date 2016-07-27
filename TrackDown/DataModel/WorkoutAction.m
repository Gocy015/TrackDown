//
//  WorkoutAction.m
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "WorkoutAction.h"
#import "ExpandableObjectProtocol.h"


@interface WorkoutAction () <ExpandableObject ,NSCopying>{
    BOOL _opened;
}

@end

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

-(id)copyWithZone:(NSZone *)zone{
    WorkoutAction *act = [WorkoutAction new];
    act.actionName = [_actionName copyWithZone:zone];
    act.sets = _sets;
    act.weightPerSet = [_weightPerSet mutableCopyWithZone:zone];
    act.repeatsPerSet = [_repeatsPerSet mutableCopyWithZone:zone];
    act.opened = _opened;
    
    return act;
}

#pragma mark - Expandable Object Protocol

-(NSUInteger)countOfSecondaryObjects{
    return self.sets;
}

-(NSArray *)descriptionForSecondaryObjects{
    NSMutableArray *des = [NSMutableArray new];
    
    for (NSInteger i = 0; i < self.sets; ++i) {
        NSString *str = [NSString stringWithFormat:@"第%lu组，负重%.2lfkg，完成%lu次",i+1,[_weightPerSet[i] doubleValue],[_repeatsPerSet[i] integerValue]];
        [des addObject:str];
    }
    
    return des;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ x %lu 组",self.actionName,self.sets];
}

-(BOOL)opened{
    return _opened;
}

-(void)setOpened:(BOOL)op{
    _opened = op;
}
@end

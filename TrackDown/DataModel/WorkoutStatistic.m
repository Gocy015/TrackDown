//
//  WorkoutStatistic.m
//  TrackDown
//
//  Created by Gocy on 16/7/13.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "WorkoutStatistic.h"



NSString *const key_weight = @"weight";
NSString *const key_reps = @"reps";
NSString *const key_sets = @"sets";


@interface WorkoutStatistic (){
    BOOL _opened;
}

@end

@implementation WorkoutStatistic

#pragma mark - Expandable Object Protocol

-(NSUInteger)countOfSecondaryObjects{
    return 1;
}

-(NSArray *)descriptionForSecondaryObjects{
    return nil;
}

-(NSString *)description{
    return self.key;
}

-(BOOL)opened{
    return _opened;
}

-(void)setOpened:(BOOL)op{
    _opened = op;
}

@end

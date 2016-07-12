//
//  CYWorkoutDataParser.m
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "CYWorkoutDataParser.h"
#import "TargetMuscle.h"
#import "WorkoutAction.h"
#import "NSArray+Map.h"

#define m_fileManager [NSFileManager defaultManager]

static NSString * const key_TargetMuscle = @"TargetMuscle";
static NSString * const key_WorkoutActions = @"WorkoutActions";


@implementation CYWorkoutDataParser


+(instancetype)defaultParser{
    
    static CYWorkoutDataParser *s_parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_parser = [CYWorkoutDataParser new];
    });
    
    return s_parser;
}

-(NSArray <TargetMuscle *> *)parseWorkoutTypesFromFile:(NSString *)filePath{
    NSData *jsonData = [m_fileManager contentsAtPath:filePath];
    
    NSError *err = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
    
    if (!jsonArray || err) {
        NSLog(@"parse no good , cannot parse data! error : %@",[err description]);
        return nil;
    }

    if (![[jsonArray firstObject] isKindOfClass:[NSDictionary class]]) {
        NSLog(@"parse no good ! array contains illegal obj !");
        return nil;
    }
    
    NSMutableArray *workouts = [NSMutableArray array];
    
    for (NSDictionary *dic in jsonArray) {
        NSString *muscleName = [dic objectForKey:key_TargetMuscle];
        NSArray *actions = [dic objectForKey:key_WorkoutActions];
        if (!muscleName || !actions) {
            NSLog(@"parse no good ! dictionary does not contain appropriate data");
            return nil;
        }
        TargetMuscle *muscle = [TargetMuscle new];
        muscle.muscle = muscleName;
        for (NSString *actionName in actions){
            WorkoutAction *act = [WorkoutAction new];
            act.actionName = actionName;
            [muscle.actions addObject:act];
        }
        [workouts addObject:muscle];
    }
    
    
    return workouts;
}

-(NSArray <TargetMuscle *> *)parseWorkoutTypesFromString:(NSString *)jsonString{
    
    return nil;
}

-(NSData *)serializeWorkoutArray:(NSArray<TargetMuscle *> *)array{
    NSData *ret = nil;
    NSMutableArray *workoutArr = [NSMutableArray array];
    for (TargetMuscle *m in array) {
        if(![m isKindOfClass:[TargetMuscle class]]){
            NSLog(@"Cannot Serialize non-TargetMuscle class");
            return nil;
        }
        NSArray *actionNames = [m.actions map:^NSString* (WorkoutAction *act) {
            return act.actionName;
        }];
        NSDictionary *workout = @{key_TargetMuscle:m.muscle,key_WorkoutActions:actionNames};
        [workoutArr addObject:workout];
    }
    
    ret = [NSJSONSerialization dataWithJSONObject:workoutArr options:NSJSONWritingPrettyPrinted error:nil];
    
    return ret;
}

@end

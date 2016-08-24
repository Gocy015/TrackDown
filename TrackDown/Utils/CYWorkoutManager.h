//
//  CYWorkoutManager.h
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TargetMuscle;
@class WorkoutAction;

extern NSString *const n_WriteToDiskSuccessNotification;
extern NSString *const n_WriteToDiskFailNotification;

extern NSString *const n_AddMuscleSuccessNotification;
extern NSString *const n_DeleteMuscleSuccessNotification;
extern NSString *const n_AddActionSuccessNotification ;
extern NSString *const n_DeleteActionSuccessNotification;

@interface CYWorkoutManager : NSObject

//getter
+(instancetype)sharedManager;

//file management
-(void)createWorkoutTypesIfNeeded;


//workouts
-(NSArray *)getCurrentWorkoutTypes;
-(NSArray *)getWorkoutRecordsFromDate:(NSDate *)from toDate:(NSDate *)to;


-(void)addTargetMuscle:(TargetMuscle *)targetMuscle writeToDiskImmediatly:(BOOL)writeNow completion:(void(^)(BOOL success))completion;
-(void)deleteTargetMuscle:(TargetMuscle *)targetMuscle writeToDiskImmediately:(BOOL)writeNow;


-(void)addAction:(WorkoutAction *)act toMuscle:(TargetMuscle *)m writeToDiskImmediatly:(BOOL)writeNow completion:(void(^)(BOOL success))completion;
-(void)deleteAction:(WorkoutAction *)act fromMuscle:(TargetMuscle *)m writeToDiskImmediatly:(BOOL)writeNow;

-(void)didFinishWorkoutPlan:(NSArray <TargetMuscle *>*)workoutPlan;

-(void)workoutRecordsForMonthInDate:(NSDate *)date completion:(void(^)(NSDictionary *))block;
-(void)workoutActionStatisticForYearInDate:(NSDate *)date completion:(void (^)(NSArray * ,NSDate *))block;

/**
 *  读取动作所有数据
 *
 *  @param block 回调字典res , @{date:statisticArray,date2:statisticArray2, ... }
 */
-(void)loadAllActionStatistics:(void(^)(NSDictionary *res))block;


/**
 *  读取所有部位数据
 *
 *  @param block 回调Array，@{statisticMuscle1,statisticMuscle2, ...}
 */
-(void)loadAllMuscleStatistics:(void(^)(NSArray *res))block;


-(void)releaseRecordCache;


//time break

-(NSUInteger)getTimeBreak;
-(void)setTimeBreak:(NSUInteger)time;

@end

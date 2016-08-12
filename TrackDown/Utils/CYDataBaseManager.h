//
//  CYDataBaseManager.h
//  TrackDown
//
//  Created by Gocy on 16/7/13.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TargetMuscle;
@class WorkoutStatistic;

@interface CYDataBaseManager : NSObject


//getter
+(instancetype)sharedManager;
 

-(BOOL)storeWorkoutPlan:(NSArray <TargetMuscle *>*)plan forDate:(NSDate *)date;

-(BOOL)storeStatistic:(NSArray <WorkoutStatistic *> *)stat forDate:(NSDate *)date;

-(NSDictionary *)queryWorkoutRecordsForMonth:(NSDate *)date;
-(NSArray *)queryWorkoutActionStatisticForYear:(NSDate *)date;
-(NSArray *)queryWorkoutMuscleStatisticForYear:(NSDate *)date;

-(void)clearRecordsCache;

@end

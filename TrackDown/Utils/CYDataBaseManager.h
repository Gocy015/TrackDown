//
//  CYDataBaseManager.h
//  TrackDown
//
//  Created by Gocy on 16/7/13.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TargetMuscle;

@interface CYDataBaseManager : NSObject


//getter
+(instancetype)sharedManager;
 

-(BOOL)storeWorkoutPlan:(NSArray <TargetMuscle *>*)plan forDate:(NSDate *)date;

-(BOOL)storeStatistic;

@end

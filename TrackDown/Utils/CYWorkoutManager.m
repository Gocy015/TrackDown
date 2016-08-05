//
//  CYWorkoutManager.m
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "CYWorkoutManager.h"
#import "PathDefines.h"
#import "CYWorkoutDataParser.h"
#import "TargetMuscle.h"
#import "WorkoutAction.h"
#import "CYDataBaseManager.h"
#import "WorkoutStatistic.h"
#import "NSArray+Map.h"

#define m_fileManager [NSFileManager defaultManager]

static const char *ioQueueIdentifier = "gocy.trackdown.io";

@interface CYWorkoutManager()
@property (nonatomic ,copy) NSString *libPath;
@property (nonatomic ,copy) NSMutableArray *workoutTypes;
@property (nonatomic) dispatch_queue_t ioQueue;

@end

NSString *const n_WriteToDiskSuccessNotification = @"n_WriteToDiskSuccessNotification";
NSString *const n_WriteToDiskFailNotification = @"n_WriteToDiskFailNotification";
NSString *const n_AddMuscleSuccessNotification = @"n_AddMuscleSuccessNotification";
NSString *const n_DeleteMuscleSuccessNotification = @"n_DeleteMuscleSuccessNotification";
NSString *const n_AddActionSuccessNotification = @"n_AddActionSuccessNotification";
NSString *const n_DeleteActionSuccessNotification = @"n_DeleteActionSuccessNotification";

static NSString * const Key_TimeBreak = @"TrackDown_TimeBreak";

@implementation CYWorkoutManager


#pragma mark - Class Method
+(instancetype)sharedManager{
    
    static CYWorkoutManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [CYWorkoutManager new];
    });
    
    return s_manager;
}

#pragma mark - Life Cycle

#pragma mark - Instance Method
-(void)createWorkoutTypesIfNeeded{
    
    NSLog(@"%@",[self workoutTypePath]);
    
    if ([m_fileManager fileExistsAtPath:[self workoutTypePath]]) {
        
        return;
    }
    NSLog(@"Creating WorkoutTypes");
    NSString *folder = [[self libraryPath] stringByAppendingPathComponent:kWorkoutFolderName];
    if(![m_fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil]){
        NSLog(@"Fail to create workoutType dir");
        return;
    }
    
    NSString *rsPath = [[NSBundle mainBundle]pathForResource:@"workouts" ofType:@"json"];
    
    
    
    if (![m_fileManager copyItemAtPath:rsPath toPath:[self workoutTypePath] error:nil]) {
        NSLog(@"Fail to copy workoutType file");
        return ;
    }
    
    
}


-(void)addTargetMuscle:(TargetMuscle *)targetMuscle writeToDiskImmediatly:(BOOL)writeNow{
    for (TargetMuscle *m in _workoutTypes) {
        if ([m.muscle isEqualToString:targetMuscle.muscle]) {
            return;
        }
    }
    
    [_workoutTypes addObject:targetMuscle];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:n_AddMuscleSuccessNotification object:targetMuscle];
    if (writeNow) {
        [self saveCurrentWorkoutToDisk];
    }
}
-(void)deleteTargetMuscle:(TargetMuscle *)targetMuscle writeToDiskImmediately:(BOOL)writeNow{
    NSInteger index = -1;
    for (TargetMuscle *m in _workoutTypes) {
        if ([m.muscle isEqualToString:targetMuscle.muscle]) {//add actions
            index = [_workoutTypes indexOfObject:m];
            [_workoutTypes removeObject:m];
            break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:n_DeleteMuscleSuccessNotification object:@(index)];
    if (writeNow) {
        [self saveCurrentWorkoutToDisk];
    }
}


-(void)addAction:(WorkoutAction *)act toMuscle:(TargetMuscle *)targetMuscle writeToDiskImmediatly:(BOOL)writeNow{
    BOOL found = NO;
    for (TargetMuscle *m in _workoutTypes) {
        if ([m.muscle isEqualToString:targetMuscle.muscle]) {//add actions
            found = YES;
            [m.actions addObject:act];
            break;
        }
    }
    if (!found) {//new muscle
        [targetMuscle.actions addObject:act];
        [_workoutTypes addObject:targetMuscle];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:n_AddActionSuccessNotification object:act];
    if (writeNow) {
        [self saveCurrentWorkoutToDisk];
    }
}
-(void)deleteAction:(WorkoutAction *)act fromMuscle:(TargetMuscle *)targetMuscle writeToDiskImmediatly:(BOOL)writeNow{
    NSInteger index = -1;
    for (TargetMuscle *m in _workoutTypes) {
        if ([m.muscle isEqualToString:targetMuscle.muscle]) {//add actions
            index = [m.actions indexOfObject:act];
            [m.actions removeObject:act];
            break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:n_DeleteActionSuccessNotification object:@(index)];
    if (writeNow) {
        [self saveCurrentWorkoutToDisk];
    }
    
}


-(void)didFinishWorkoutPlan:(NSArray<TargetMuscle *> *)workoutPlan{
//    [[CYDataBaseManager sharedManager] storeWorkoutPlan:[self mergeActionsWithSameMuscle:workoutPlan] forDate:[NSDate date]];
    
    NSArray *arr = [[NSArray alloc] initWithArray:workoutPlan copyItems:YES];//avoid conflict
    
    [[CYDataBaseManager sharedManager] storeWorkoutPlan:[self mergeConsecutiveMuscle:workoutPlan] forDate:[NSDate date]];
    
    [[CYDataBaseManager sharedManager] storeStatistic:[self convertPlanIntoStatistics:arr] forDate:[NSDate date]];
     
}


#pragma mark - Helpers

-(NSString *)libraryPath{
    if (!_libPath) {
        NSArray *urls = [m_fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
        _libPath = [(NSURL *)[urls firstObject] path];
    }
    
    return _libPath;
}

-(NSString *)workoutTypePath{
    return [[[self libraryPath] stringByAppendingPathComponent:kWorkoutFolderName ] stringByAppendingPathComponent:kWorkoutFileName];
}

-(NSArray<TargetMuscle *> *)mergeConsecutiveMuscle:(NSArray<TargetMuscle *> *)plan{
    NSMutableArray *mergedArr = [NSMutableArray new];
    TargetMuscle *prev = nil;
    
    for (TargetMuscle *m in plan) {
        if (prev == nil || ![prev.muscle isEqualToString:m.muscle]) {
            [mergedArr addObject:m];
            prev = m;
            continue;
        }
        if ([prev.muscle isEqualToString:m.muscle]) {
            //merge
            [prev.actions addObjectsFromArray:m.actions];
            
        }
    }
    
    return mergedArr;
}

-(NSArray <WorkoutStatistic *> *)convertPlanIntoStatistics:(NSArray<TargetMuscle *> *)plan{
//    NSMutableDictionary <NSString *,WorkoutStatistic *>*muscleDic = [NSMutableDictionary dictionary];
    NSMutableDictionary <NSString *,WorkoutStatistic *>*actionDic = [NSMutableDictionary dictionary];
         
    NSArray *mergedPlan = [self mergeActionsWithSameMuscle:plan];
    
    NSMutableArray *statArr = [NSMutableArray new];
    
    for (TargetMuscle *m in mergedPlan) {
        double weight = 0;
        WorkoutStatistic *mStat = [WorkoutStatistic new];
        mStat.type = StatTypeMuscle;
        mStat.key = m.muscle;
        [statArr addObject:mStat];
        for (WorkoutAction *act in m.actions) {
            if ([actionDic objectForKey:act.actionName] != nil) {
                WorkoutStatistic *stat = [actionDic objectForKey:act.actionName];
                NSNumber *actWeight = [act.weightPerSet sum];
                
                //cal weight of muscle
                weight = weight + actWeight.doubleValue;
                
                NSNumber *actReps = [act.repeatsPerSet sum];
                
                double statWeight = [[stat.data objectForKey:key_weight] doubleValue] + actWeight.doubleValue;
                NSUInteger statReps = [[stat.data objectForKey:key_reps] integerValue] + actReps.integerValue;
                NSUInteger statSets = [[stat.data objectForKey:key_sets] integerValue] + act.sets;
                
                [stat.data setValue:@(statWeight) forKey:key_weight];
                [stat.data setValue:@(statSets) forKey:key_sets];
                [stat.data setValue:@(statReps) forKey:key_reps];
                
            }else{
                WorkoutStatistic *stat = [WorkoutStatistic new];
                stat.type = StatTypeAction;
                stat.key = act.actionName;
                NSNumber *actWeight = [act.weightPerSet sum];
                weight = weight + actWeight.doubleValue;
                stat.data = [NSMutableDictionary dictionaryWithDictionary:@{key_weight:actWeight,key_sets:@(act.sets),key_reps:[act.repeatsPerSet sum]}];
                [actionDic setObject:stat forKey:act.actionName];
                [statArr addObject:stat];
            }
        }
        mStat.data = [NSMutableDictionary dictionaryWithDictionary:@{key_weight:@(weight)}];
    }
    
    return [statArr copy];
}

-(NSArray<TargetMuscle *> *)mergeActionsWithSameMuscle:(NSArray<TargetMuscle *> *)plan{
    NSMutableDictionary <NSString *,TargetMuscle *>*dic = [NSMutableDictionary dictionary];
    NSMutableArray *mergedArr = [NSMutableArray new];
    for (TargetMuscle *m in plan) {
        if ([dic objectForKey:m.muscle] != nil) {
            [[dic objectForKey:m.muscle].actions addObjectsFromArray:m.actions];
        }else{
            [dic setObject:m forKey:m.muscle];
            [mergedArr addObject:m];
        }
    }
    return [mergedArr copy];
}


#pragma mark - Get workout whereabouts

-(NSArray *)getCurrentWorkoutTypes{
    if (!_workoutTypes) {
        NSArray *workouts = [[CYWorkoutDataParser defaultParser] parseWorkoutTypesFromFile:[self workoutTypePath]];
        _workoutTypes = [NSMutableArray arrayWithArray:workouts];
    }
    
    return [NSArray arrayWithArray: _workoutTypes];
}

-(NSArray *)getWorkoutRecordsFromDate:(NSDate *)from toDate:(NSDate *)to{
    return nil;
}



#pragma mark - Memory Managing

-(void)saveCurrentWorkoutToDisk{
    NSData *writeData = [[CYWorkoutDataParser defaultParser] serializeWorkoutArray:_workoutTypes];
    if (!writeData) {
        return ;
    }
    
    dispatch_async(self.ioQueue, ^{
        
        BOOL success = [writeData writeToFile:[self workoutTypePath] atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [[NSNotificationCenter defaultCenter]postNotificationName:n_WriteToDiskSuccessNotification object:nil];
            }
            else{
                [[NSNotificationCenter defaultCenter]postNotificationName:n_WriteToDiskFailNotification object:nil];
            }
        });
    });
    
}

-(void)workoutRecordsForMonthInDate:(NSDate *)date completion:(void (^)(NSDictionary *))block{
    dispatch_async(self.ioQueue, ^{
        NSDictionary *res = [[CYDataBaseManager sharedManager]queryWorkoutRecordsForMonth:date];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(res);
        });
    });
}

-(void)workoutStatisticForMonthInDate:(NSDate *)date completion:(void(^)(NSArray *))block{
    dispatch_async(self.ioQueue, ^{
        NSArray *res = [[CYDataBaseManager sharedManager] queryWorkoutActionStatisticForMonth:date];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(res);
        });
    });
}

-(void)releaseRecordCache{
    [[CYDataBaseManager sharedManager] clearRecordsCache];
}


-(NSUInteger)getTimeBreak{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:Key_TimeBreak]) {
        return [[defaults objectForKey:Key_TimeBreak] integerValue];
    }
    //
    [self setTimeBreak:60];//default value;
    return 60;
}


-(void)setTimeBreak:(NSUInteger)time{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(time) forKey:Key_TimeBreak];
    [defaults synchronize];
    
}

#pragma mark - Getters
-(dispatch_queue_t)ioQueue{
    if (!_ioQueue) {
        _ioQueue = dispatch_queue_create(ioQueueIdentifier, DISPATCH_QUEUE_CONCURRENT);
    }
    return _ioQueue;
}

@end



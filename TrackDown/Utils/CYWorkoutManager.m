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
#import "NSDate+Components.h"

#define m_fileManager [NSFileManager defaultManager]

static const char *ioQueueIdentifier = "gocy.trackdown.io";

@interface CYWorkoutManager()
@property (nonatomic ,copy) NSString *libPath;
@property (nonatomic ,copy) NSMutableArray *workoutTypes;
@property (nonatomic) dispatch_queue_t ioQueue;
@property (nonatomic ,strong) NSDictionary *actionStatCache;
@property (nonatomic ,strong) NSArray *muscleStatCache;

@property (nonatomic ,strong) NSMutableDictionary *actionsMap;

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


-(void)addTargetMuscle:(TargetMuscle *)targetMuscle writeToDiskImmediatly:(BOOL)writeNow completion:(void (^)(BOOL))completion{
    for (TargetMuscle *m in _workoutTypes) {
        if ([m.muscle isEqualToString:targetMuscle.muscle]) {
            completion(NO); //duplicate muscle
            return;
        }
    }
    
    [_workoutTypes addObject:targetMuscle];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:n_AddMuscleSuccessNotification object:targetMuscle];
    completion(YES);
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
            for (WorkoutAction *act in m.actions) {
                [_actionsMap removeObjectForKey:act.actionName];
            }
            break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:n_DeleteMuscleSuccessNotification object:@(index)];
    if (writeNow) {
        [self saveCurrentWorkoutToDisk];
    }
}

-(void)updateMuscleActions:(TargetMuscle *)targetMuscle{
    for (TargetMuscle *m in _workoutTypes) {
        if ([m.muscle isEqualToString:targetMuscle.muscle]) {//add actions
            m.actions = [NSMutableArray arrayWithArray:targetMuscle.actions];
            break;
        }
    }
    
    [self saveCurrentWorkoutToDisk];
    
}

-(void)addAction:(WorkoutAction *)act toMuscle:(TargetMuscle *)targetMuscle writeToDiskImmediatly:(BOOL)writeNow completion:(void (^)(BOOL))completion{
    BOOL found = NO;
    
    if ([_actionsMap objectForKey:act.actionName] != nil) {
        completion(NO);
        return ;
    }
    
    for (TargetMuscle *m in _workoutTypes) {
        if ([m.muscle isEqualToString:targetMuscle.muscle]) {//add actions
            found = YES;
//            [m.actions addObject:act];
            [m.actions insertObject:act atIndex:0];
            break;
        }
    }
    if (!found) {//new muscle
        [targetMuscle.actions insertObject:act atIndex:0];
        [_workoutTypes addObject:targetMuscle];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:n_AddActionSuccessNotification object:act];
    completion(YES);
    if (writeNow) {
        [self saveCurrentWorkoutToDisk];
    }
}
-(void)deleteAction:(WorkoutAction *)act fromMuscle:(TargetMuscle *)targetMuscle writeToDiskImmediatly:(BOOL)writeNow{
    NSInteger index = -1;
    for (TargetMuscle *m in _workoutTypes) {
        if ([m.muscle isEqualToString:targetMuscle.muscle]) {
            index = [m.actions indexOfObject:act];
            [m.actions removeObject:act];
            [_actionsMap removeObjectForKey:act.actionName];
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
    
    
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *com = [NSDateComponents new];
//    com.year = [NSDate date].year;
//    com.month = [NSDate date].month + 1;
//    com.day = [NSDate date].day;
//    NSDate *d = [cal dateFromComponents:com];
    NSDate *d = [NSDate date];
    
    self.actionStatCache = nil;
    self.muscleStatCache = nil;
    
    [[CYDataBaseManager sharedManager] storeWorkoutPlan:[self mergeConsecutiveMuscle:workoutPlan] forDate:d];
    
    [[CYDataBaseManager sharedManager] storeStatistic:[self convertPlanIntoStatistics:arr] forDate:d];
     
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

-(NSString *)dbPath{
    return [[self libraryPath] stringByAppendingPathComponent:kDatabaseFolderName];
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
    
    NSDate *d = [NSDate date];
    
    for (TargetMuscle *m in mergedPlan) {
        double weight = 0;
        WorkoutStatistic *mStat = [WorkoutStatistic new];
        mStat.type = StatTypeMuscle;
        mStat.key = m.muscle;
        mStat.storeDate = [d day];
        mStat.storeMonth = [d month];
        [statArr addObject:mStat];
        for (WorkoutAction *act in m.actions) {
            if ([actionDic objectForKey:act.actionName] != nil) {
                WorkoutStatistic *stat = [actionDic objectForKey:act.actionName];
                NSNumber *actWeight = [act.weightPerSet sum];
                
                //cal weight of muscle
                for (int i = 0; i < act.weightPerSet.count; ++i) {
                    weight = weight + [act.weightPerSet[i] doubleValue] * [act.repeatsPerSet[i] doubleValue];
                }
                
                
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
                stat.mus = m.muscle;
                
                stat.storeDate = [d day];
                stat.storeMonth = [d month];
                NSNumber *actWeight = [act.weightPerSet sum];
                
                for (int i = 0; i < act.weightPerSet.count; ++i) {
                    weight = weight + [act.weightPerSet[i] doubleValue] * [act.repeatsPerSet[i] doubleValue];
                }
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
        
        _actionsMap = [NSMutableDictionary new];
        for (TargetMuscle *m in _workoutTypes) {
            for (WorkoutAction *act in m.actions) {
                [_actionsMap setObject:@(1) forKey:act.actionName];
            }
        }
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
    
    [self ioProcess:^{
        
        BOOL success = [writeData writeToFile:[self workoutTypePath] atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [[NSNotificationCenter defaultCenter]postNotificationName:n_WriteToDiskSuccessNotification object:nil];
            }
            else{
                [[NSNotificationCenter defaultCenter]postNotificationName:n_WriteToDiskFailNotification object:nil];
            }
        });
    }];
    
}

-(void)workoutRecordsForMonthInDate:(NSDate *)date completion:(void (^)(NSDictionary *))block{
    [self ioProcess: ^{
        NSDictionary *res = [[CYDataBaseManager sharedManager]queryWorkoutRecordsForMonth:date];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(res);
        });
    }];
}
 


-(void)workoutActionStatisticForYearInDate:(NSDate *)date completion:(void (^)(NSArray * ,NSDate *))block{
//    NSInteger year = [date year];
//    NSInteger day = 1;
//    
//    NSMutableArray *ret = [NSMutableArray new];
    
//    NSLog(@"Start fetch statistic for whole year ! %f",CFAbsoluteTimeGetCurrent());
    
    [self ioProcess:^{
        NSArray *res = [[CYDataBaseManager sharedManager] queryWorkoutActionStatisticForYear:date];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(res,date);
        });
    }];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDateComponents *com = [NSDateComponents new];
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        for (NSInteger i = 1; i <= 12; i ++) {
//            com.year = year;
//            com.month = i;
//            com.day = day;
//            NSDate *d = [calendar dateFromComponents:com];
//            dispatch_sync(self.ioQueue, ^{ // sync to make return array sorted
//                NSArray *res = [[CYDataBaseManager sharedManager] queryWorkoutActionStatisticForMonth:d];
//                if ([res count]) {
//                    [ret addObject:res];
//                }
//            });
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            block([[NSArray alloc] initWithArray:ret copyItems:YES]);
//            NSLog(@"End fetch statistic for whole year ! %f",CFAbsoluteTimeGetCurrent());
//        });
//    });
    
}


-(void)loadAllActionStatistics:(void (^)(NSDictionary *))block{
    
    if (self.actionStatCache) {
        block(self.actionStatCache);
        NSLog(@"Action Statistic Hit Cache !");
        return ;
    }
    
    [self ioProcess:^{
        NSArray *files = [m_fileManager contentsOfDirectoryAtPath:[self dbPath] error:nil];
        if (files) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            NSDateComponents *com = [NSDateComponents new];
            NSCalendar *cal = [NSCalendar currentCalendar];
            for (NSString *file in files) {
                NSString *p = [self validateDirectory:file];
                if (p) {
                    com.year = [file integerValue];
                    com.month = 1;
                    com.day = 1;
                    NSDate * d = [cal dateFromComponents:com];
                    NSArray *res = [[CYDataBaseManager sharedManager] queryWorkoutActionStatisticForYear:d];
                    [dic setObject:res forKey:d];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.actionStatCache = [[NSDictionary alloc] initWithDictionary:dic];
                block(self.actionStatCache);
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil);
            });
        }
        
    }];
}


-(void)loadAllMuscleStatistics:(void (^)(NSArray *))block{
    
    if (self.muscleStatCache) {
        block(self.muscleStatCache);
        NSLog(@"Muscle Statistic Hit Cache !");
        return ;
    }
    
    [self ioProcess:^{
        NSArray *files = [m_fileManager contentsOfDirectoryAtPath:[self dbPath] error:nil];
        if (files) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            NSDateComponents *com = [NSDateComponents new];
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSMutableArray *arr = [NSMutableArray new];
            for (NSString *file in files) {
                NSString *p = [self validateDirectory:file];
                if (p) {
                    com.year = [file integerValue];
                    com.month = 1;
                    com.day = 1;
                    NSDate * d = [cal dateFromComponents:com];
                    NSArray *res = [[CYDataBaseManager sharedManager] queryWorkoutMuscleStatisticForYear:d];
                    
                    for(WorkoutStatistic *stat in res){
                        if (dic[stat.key] != nil) {
                            WorkoutStatistic *statInDic = dic[stat.key];
                            double sum = [statInDic.data[key_weight] doubleValue] + [stat.data[key_weight] doubleValue];
                            statInDic.data[key_weight] = @(sum);
                        }else{
                            dic[stat.key] = stat;
                            [arr addObject:stat];
                        }
                    }
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.muscleStatCache = [NSArray arrayWithArray:arr];
                block(self.muscleStatCache);
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil);
            });
        }
        
    }];

}

-(void)releaseRecordCache{
    [[CYDataBaseManager sharedManager] clearRecordsCache];
}

-(NSString *)validateDirectory:(NSString *)file{
    if ([file integerValue]) {
        NSString *path = [[self dbPath] stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        if ([m_fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            return path;
        }
    }
    
    return nil;
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


-(void)ioProcess:(dispatch_block_t)block{
    dispatch_async(self.ioQueue, block);
}

#pragma mark - Getters
-(dispatch_queue_t)ioQueue{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ioQueue = dispatch_queue_create(ioQueueIdentifier, DISPATCH_QUEUE_CONCURRENT);
    });
 
    return _ioQueue;
}

@end



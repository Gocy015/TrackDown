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
#define m_fileManager [NSFileManager defaultManager]

@interface CYWorkoutManager()
@property (nonatomic ,copy) NSString *libPath;
@property (nonatomic ,copy) NSMutableArray *workoutTypes;

@end

NSString *const n_WriteToDiskSuccessNotification = @"n_WriteToDiskSuccessNotification";
NSString *const n_WriteToDiskFailNotification = @"n_WriteToDiskFailNotification";
NSString *const n_AddMuscleSuccessNotification = @"n_AddMuscleSuccessNotification";
NSString *const n_DeleteMuscleSuccessNotification = @"n_DeleteMuscleSuccessNotification";
NSString *const n_AddActionSuccessNotification = @"n_AddActionSuccessNotification";
NSString *const n_DeleteActionSuccessNotification = @"n_DeleteActionSuccessNotification";

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



#pragma mark - Instance Method
-(void)createWorkoutTypesIfNeeded{
    
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
    
    
    NSLog(@"%@",[self workoutTypePath]);
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
#pragma mark - Helpers on paths

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
    dispatch_queue_t fileQueue = dispatch_queue_create("gocy.workout.writefile", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(fileQueue, ^{
        
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

@end



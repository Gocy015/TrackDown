//
//  CYDataBaseManager.m
//  TrackDown
//
//  Created by Gocy on 16/7/13.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "CYDataBaseManager.h"
#import "FMDB.h"
#import "TargetMuscle.h"
#import "WorkoutAction.h"
#import "NSDate+Components.h"
#import "WorkoutStatistic.h"

#define m_fileManager [NSFileManager defaultManager]

static const NSUInteger kRecordCacheLimit = 8; //缓存八天训练记录。

@interface CYDataBaseManager ()

@property (nonatomic ,strong) NSString *libPath;
@property (nonatomic ,strong) NSMutableDictionary *recordCache;
@property (nonatomic ,strong) NSMutableArray *recordHitQueue;


@end

typedef NS_ENUM(NSUInteger ,KeyOption){
    KeyOption_DayAsKey = 1,
    KeyOption_MonthAsKey = 1 << 1,
    KeyOption_YearAsKey = 1 << 2
};

static NSString * const recordsDB = @"records.db";
static NSString * const statisticDB = @"statistic.db";

static NSString * const recordTable = @"RECORDS";
static NSString * const recordDate = @"date";
static NSString * const recordMuscle = @"muscle";
static NSString * const recordData = @"data";

static NSString * const statTable = @"STATISTICS";
static NSString * const statType = @"type";
static NSString * const statKey = @"key";
static NSString * const statMus = @"muscle";
static NSString * const statData = @"data";
static NSString * const statStoreMonth = @"month";
static NSString * const statStoreDate = @"date";
static NSString * const statCount = @"count";

@implementation CYDataBaseManager


#pragma mark - Life cycle

+(instancetype)sharedManager{
    static CYDataBaseManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [CYDataBaseManager new];
    });
    
    return s_manager;
}

-(instancetype)init{
    if (self = [super init]) {
        [self createDataBaseDirIfNeeded];
        [self createCurrentMonthDirIfNeeded];
        _recordCache = [NSMutableDictionary new];
        _recordHitQueue = [NSMutableArray new];
        
    }
    return self;
}


#pragma mark - Instance Methods
-(BOOL)createRecordsTableForDate:(NSDate *)date{
    BOOL success = NO;
    FMDatabase *db = [self recordsDatabaseForMonthInDate:date];
    if ([db open]) {
        NSString *create = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'(%@ integer NOT NULL ,%@ text NOT NULL ,%@ blob NOT NULL);" ,recordTable,recordDate,recordMuscle,recordData];
        if ([db executeUpdate:create]) {
            success = YES;
        }
        
        [db close];
    }
    
    return success;
}


-(BOOL)createStatisticTableForDate:(NSDate *)date{
    BOOL success = NO;
    FMDatabase *db = [self statisticDatabaseForYearInDate:date];
    if ([db open]) {
        NSString *create = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'(%@ integer NOT NULL ,%@ text NOT NULL ,%@ blob NOT NULL ,%@ integer NOT NULL ,%@ integer NOT NULL ,%@ integer NOT NULL ,%@ text);" ,statTable,statType,statKey,statData,statStoreMonth,statStoreDate,statCount,statMus];
        if ([db executeUpdate:create]) {
            success = YES;
            NSLog(@"Create Statistic db success");
        }
        
        [db close];
    }
    
    return success;
}

/*
 
 date   muscle   actions
 int     str    TargetMuscle
 
 
 */


-(BOOL)storeWorkoutPlan:(NSArray<TargetMuscle *> *)plan forDate:(NSDate *)date{
    
    [self createMonthDir:date];
    
    [self createRecordsTableForDate:date];
    
    
    [self storePlanForRecords:plan forDate:date];
    
    
    
    return NO;
}

-(BOOL)storeStatistic:(NSArray<WorkoutStatistic *> *)stat forDate:(NSDate *)date{
    [self createStatisticTableForDate:date];
    
    [self _storeStatistic:stat forDate:date];
    
    return NO;
}


-(NSDictionary *)queryWorkoutRecordsForMonth:(NSDate *)date{
    NSString *key = [self keyForDate:date options:KeyOption_YearAsKey|KeyOption_MonthAsKey];
    if ([_recordCache objectForKey:key] != nil) {
        //缓存命中
        
        [_recordHitQueue removeObject:key];
        [_recordHitQueue insertObject:key atIndex:0];
        
        return [_recordCache objectForKey:key];
    }
    FMDatabase *db = [self recordsDatabaseForMonthInDate:date];
    NSMutableDictionary *records = [NSMutableDictionary new];
    if ([db open]) {
        NSString *query = [NSString stringWithFormat:@"SELECT * from %@",recordTable];
        FMResultSet *set = [db executeQuery:query];
        while (set.next) {
            /*
             static NSString * const recordDate = @"date";
             static NSString * const recordMuscle = @"muscle";
             static NSString * const recordData = @"data";
             */
            NSUInteger day = [set unsignedLongLongIntForColumn:recordDate];
            if (records[@(day)] == nil) {
                NSMutableDictionary *dic = [NSMutableDictionary new];
                records[@(day)] = dic;
            }
            NSMutableDictionary *dic = records[@(day)];
            NSData *muscleData = [set dataForColumn:recordData];
            TargetMuscle *m = [NSKeyedUnarchiver unarchiveObjectWithData:muscleData];
            if ([dic objectForKey:m.muscle] != nil) {
                TargetMuscle *mInDic = [dic objectForKey:m.muscle];
                [mInDic.actions addObjectsFromArray:m.actions];
            }else{
                [dic setObject:m forKey:m.muscle];
            }
        }
        [db close];
    }
    
    [_recordCache setObject:records forKey:key];
    [_recordHitQueue insertObject:key atIndex:0];
    
    if (_recordHitQueue.count > kRecordCacheLimit) {
        [_recordCache removeObjectForKey:[_recordHitQueue lastObject]];
        [_recordHitQueue removeLastObject];
    }
    
    return records;
}

-(NSArray *)queryWorkoutActionStatisticForYear:(NSDate *)date{
    
    FMDatabase *db = [self statisticDatabaseForYearInDate:date];
    NSMutableArray *actions = [NSMutableArray new];
    
    
    if ([db open]) {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? ORDER BY %@ ASC",statTable,statType,statStoreMonth];
        FMResultSet *set = [db executeQuery:query,@(StatTypeAction)];
        while (set.next) {
            
            NSUInteger day = [set unsignedLongLongIntForColumn:statStoreDate];
            NSUInteger month = [set unsignedLongLongIntForColumn:statStoreMonth];
            NSUInteger count = [set unsignedLongLongIntForColumn:statCount];
            NSString *key = [set stringForColumn:statKey];
            NSString *mus = [set stringForColumn:statMus];
            NSData *data = [set dataForColumn:statData];
            
            NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
            
            WorkoutStatistic *s = [WorkoutStatistic new];
            s.storeDate = day;
            s.storeMonth = month;
            s.trainingCount = count;
            s.key = key;
            s.data = mDic;
            s.type = StatTypeAction;
            s.mus = mus;
            
            [actions addObject:s];
            
        }
        
        [db close];
    }
    
    
    NSArray *res = [[NSArray alloc] initWithArray:actions];
    return res;
}

-(NSArray *)queryWorkoutMuscleStatisticForYear:(NSDate *)date{
    FMDatabase *db = [self statisticDatabaseForYearInDate:date];
    NSMutableArray *muscles = [NSMutableArray new];
    
    
    if ([db open]) {
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?",statTable,statType];
        FMResultSet *set = [db executeQuery:query,@(StatTypeMuscle)];
        
        
        //statType,statKey,statData
        while (set.next) {
            WorkoutStatistic *mus = [WorkoutStatistic new];
            
            NSString *key = [set stringForColumn:statKey];
            
            NSData *data = [set objectForColumnName:statData];
            
            NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            mus.type = StatTypeMuscle;
            mus.key = key;
            mus.data = [NSMutableDictionary dictionaryWithDictionary:dic];
            
            [muscles addObject:mus];

        }
        
        [db close];
    }
    
    return muscles;
}

#pragma mark - Helpers


-(void)clearRecordsCache{
    [_recordHitQueue removeAllObjects];
    [_recordCache removeAllObjects];
}


-(void)clearRecordsCacheForKey:(NSString *)key{
    [_recordHitQueue removeObject:key];
    [_recordCache removeObjectForKey:key];
}


-(BOOL)storePlanForRecords:(NSArray<TargetMuscle *> *)plan forDate:(NSDate *)date{
    
    //当月 records更新，清缓存。
    NSString *key = [self keyForDate:date options:KeyOption_YearAsKey | KeyOption_MonthAsKey];
    [self clearRecordsCacheForKey:key];
    
    
    NSInteger day = [date day];
    FMDatabase *db = [self recordsDatabaseForMonthInDate:date];
    
    
    if ([db open]) {
        
        // simply insert
        for (TargetMuscle *m in plan) {
            NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ VALUES(?,?,?)",recordTable];
            NSData *mData = [NSKeyedArchiver archivedDataWithRootObject:m];
            [db executeUpdate:insert ,@(day),m.muscle,mData];
        }
        
        // merge then insert
//        NSMutableSet <TargetMuscle *> *muscleToUpdate = [NSMutableSet new];
//        NSMutableSet <TargetMuscle *> *muscleToInsert = [NSMutableSet setWithArray:plan];
        
//        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?;",recordTable,recordDate];
//        FMResultSet *set = [db executeQuery:query ,@(day)];
//        while (set.next) {
//            
//            NSString *muscleName = [set objectForColumnName:recordMuscle];
//            NSData *arrData = [set objectForColumnName:recordData];
//            TargetMuscle *mus = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
//            
//            [muscleToUpdate addObject:mus];
//            
//            for (TargetMuscle *m in plan) {
//                if ([m.muscle isEqualToString:muscleName]) {
//                    // merge actions 
//                    // simply add at back
//                    
//                    [mus.actions addObjectsFromArray:m.actions];
//                    
//                    [muscleToInsert removeObject:m];
//                }
//            }
//        }
//        
//        // merge with db complete
//        for (TargetMuscle *m in muscleToUpdate) {
//            NSString *update = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ? WHERE %@ = ? AND %@ = ?",recordTable,recordData,recordDate,recordMuscle];
//            NSData *mData = [NSKeyedArchiver archivedDataWithRootObject:m];
//            [db executeUpdate:update,mData,@(day),m.muscle];
//        }
//        
//        for (TargetMuscle *m in muscleToInsert) {
//            NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ VALUES(?,?,?)",recordTable];
//            NSData *mData = [NSKeyedArchiver archivedDataWithRootObject:m];
//            [db executeUpdate:insert ,@(day),m.muscle,mData];
//        }
        
        [db close];
    }

    
    return NO;
}


-(BOOL)_storeStatistic:(NSArray<WorkoutStatistic *> *)stat forDate:(NSDate *)date{
    
    
    NSInteger day = [date day];
    NSInteger month = [date month];
    FMDatabase *db = [self statisticDatabaseForYearInDate:date];
    
    NSMutableArray *statToInsert = [NSMutableArray arrayWithArray:stat];
    NSMutableArray *statToUpdate = [NSMutableArray new];

    if ([db open]) {
        NSString *queryForAct = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? AND %@ = ? AND %@ = ? AND %@ = ?;",statTable,statType,statKey,statStoreMonth,statMus];
        NSString *queryForMus = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? AND %@ = ?;",statTable,statType,statKey];
        FMResultSet *set = nil;
        for(WorkoutStatistic *s in stat){// costly?
            if (s.type == StatTypeMuscle) {
                set = [db executeQuery:queryForMus,@(s.type),s.key];
                if (set.next) {
                    NSData *data = [set objectForColumnName:statData];
                    
                    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    
                    double weight = [[dic objectForKey:key_weight] doubleValue] + [[s.data objectForKey:key_weight] doubleValue];
                    
                    [s.data setObject:@(weight) forKey:key_weight];
                    
                    [statToInsert removeObject:s];
                    [statToUpdate addObject:s];
                }
            
            }else{
                
                set = [db executeQuery:queryForAct,@(s.type),s.key,@(s.storeMonth),s.mus];
                
                if(set.next){
                    NSData *data = [set objectForColumnName:statData];
                    
                    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    
                    double weight = [[dic objectForKey:key_weight] doubleValue] + [[s.data objectForKey:key_weight] doubleValue];
                    NSUInteger sets = [[dic objectForKey:key_sets] integerValue] + [[s.data objectForKey:key_sets] integerValue];
                    NSUInteger reps = [[dic objectForKey:key_reps] integerValue] + [[s.data objectForKey:key_reps] integerValue];
                    
                    [s.data setObject:@(weight) forKey:key_weight];
                    [s.data setObject:@(sets) forKey:key_sets];
                    [s.data setObject:@(reps) forKey:key_reps];
                    
                    NSUInteger lastStoreDay = [set intForColumn:statStoreDate];
                    NSUInteger lastCount = [set intForColumn:statCount];
                    
                    if(lastStoreDay == day){
                        s.storeDate = lastStoreDay;
                        s.trainingCount = lastCount;
                    }else{
                        s.storeDate = day;
                        s.trainingCount = lastCount + 1;
                    }
                    s.storeMonth = month;
                    [statToInsert removeObject:s];
                    [statToUpdate addObject:s];
                }
                
            }
//            if (set.next) { // use if because every stat is unique by type&&key.
//                if (s.type == StatTypeMuscle) {
//                    //muscle
//                    NSData *data = [set objectForColumnName:statData];
//                    
//                    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//                    
//                    double weight = [[dic objectForKey:key_weight] doubleValue] + [[s.data objectForKey:key_weight] doubleValue];
//                    
//                    [s.data setObject:@(weight) forKey:key_weight];
//                    
//                }else{
//                    //action
//                    
//                    NSData *data = [set objectForColumnName:statData];
//                    
//                    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//                    
//                    double weight = [[dic objectForKey:key_weight] doubleValue] + [[s.data objectForKey:key_weight] doubleValue];
//                    NSUInteger sets = [[dic objectForKey:key_sets] integerValue] + [[s.data objectForKey:key_sets] integerValue];
//                    NSUInteger reps = [[dic objectForKey:key_reps] integerValue] + [[s.data objectForKey:key_reps] integerValue];
//                    
//                    [s.data setObject:@(weight) forKey:key_weight];
//                    [s.data setObject:@(sets) forKey:key_sets];
//                    [s.data setObject:@(reps) forKey:key_reps];
//                    
//                }
//                
//                NSUInteger lastStoreDay = [set intForColumn:statStoreDate];
//                NSUInteger lastCount = [set intForColumn:statCount];
//                
//                if(lastStoreDay == day){
//                    s.storeDate = lastStoreDay;
//                    s.trainingCount = lastCount;
//                }else{
//                    s.storeDate = day;
//                    s.trainingCount = lastCount + 1;
//                }
//                s.storeMonth = month;
//                [statToInsert removeObject:s];
//                [statToUpdate addObject:s];
//            }else{
//                //insert , do nothing
//            }
        }
        
        
        /*
         statType,statKey,statData,statStoreDate,statCount
         
         */
        for (WorkoutStatistic *s in statToInsert) {
            NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ VALUES(?,?,?,?,?,?,?);",statTable];
            NSData *sData = [NSKeyedArchiver archivedDataWithRootObject:s.data];
            [db executeUpdate:insert,@(s.type),s.key,sData,@(month),@(day),@(1),s.mus];
        }
        
        for (WorkoutStatistic *s in statToUpdate) {
            NSString *update = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ? ,%@ = ? ,%@ = ? ,%@ = ? WHERE %@ = ? AND %@ = ?",statTable,statData,statStoreMonth,statStoreDate,statCount,statType,statKey];
            NSData *sData = [NSKeyedArchiver archivedDataWithRootObject:s.data];
            
            [db executeUpdate:update ,sData,@(s.storeMonth),@(s.storeDate),@(s.trainingCount),@(s.type),s.key];
            
        }
        [db close];
    }
    
    return NO;
}

-(void)createDataBaseDirIfNeeded{
    BOOL isDir = NO;
    if (![m_fileManager fileExistsAtPath:[self dataBaseFolderPath] isDirectory:&isDir] || !isDir) {
        [m_fileManager removeItemAtPath:[self dataBaseFolderPath] error:nil];
        [m_fileManager createDirectoryAtPath:[self dataBaseFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"Create database dir ! ");
    }
}

-(void)createCurrentMonthDirIfNeeded{
    BOOL isDir = NO;
    NSString *fullPath = [self pathForCurrentMonth];
    if (![m_fileManager fileExistsAtPath:fullPath isDirectory:&isDir] || !isDir) {
        [m_fileManager removeItemAtPath:fullPath error:nil];
        [m_fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"Create Month Folder !");
    }
}


-(void)createMonthDir:(NSDate *)date{
    BOOL isDir = NO;
    NSString *fullPath = [self pathForMonthInDate:date];
    if (![m_fileManager fileExistsAtPath:fullPath isDirectory:&isDir] || !isDir) {
        [m_fileManager removeItemAtPath:fullPath error:nil];
        [m_fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"Create Month Folder !");
    }
}



-(NSString *)pathForCurrentMonth{
    return [self pathForMonthInDate:[NSDate date]];
}

-(FMDatabase *)recordsDatabaseForCurrentMonth{
    return [self database:recordsDB forMonthInDate:[NSDate date]];
}

-(FMDatabase *)recordsDatabaseForMonthInDate:(NSDate *)date{
    return [self database:recordsDB forMonthInDate:date];
}


-(FMDatabase *)statisticDatabaseForCurrentMonth{
    return [self database:statisticDB forMonthInDate:[NSDate date]];
}

-(FMDatabase *)statisticDatabaseForYearInDate:(NSDate *)date{
    return [self database:statisticDB forYearInDate:date];
}


-(FMDatabase *)database:(NSString *)dbname forYearInDate:(NSDate *)date{
    if ([m_fileManager fileExistsAtPath:[self pathForYearInDate:date]]) {
        NSString *dbpath = [[self pathForYearInDate:date] stringByAppendingPathComponent:dbname];
        FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
        return db;
    }
    return nil;
}

-(FMDatabase *)database:(NSString *)dbname forMonthInDate:(NSDate *)date{
    if ([m_fileManager fileExistsAtPath:[self pathForMonthInDate:date]]) {
        NSString *dbpath = [[self pathForMonthInDate:date] stringByAppendingPathComponent:dbname];
        FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
        return db;
    }
    return nil;
}

-(NSString *)pathForMonthInDate:(NSDate *)date{
    
    NSString *folder = [NSString stringWithFormat:@"%li/%li",[date year],[date month]];
    NSString *fullPath = [[self dataBaseFolderPath] stringByAppendingPathComponent:folder];
    return fullPath;
}

-(NSString *)pathForYearInDate:(NSDate *)date{
    
    NSString *folder = [NSString stringWithFormat:@"%li",[date year]];
    NSString *fullPath = [[self dataBaseFolderPath] stringByAppendingPathComponent:folder];
    return fullPath;
}

-(NSString *)dataBaseFolderPath{
    return [[self libraryPath] stringByAppendingPathComponent:@"DataBase"];
}

-(NSString *)libraryPath{
    if (!_libPath) {
        NSArray *urls = [m_fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
        _libPath = [(NSURL *)[urls firstObject] path];
    }
    
    return _libPath;
}


-(NSString *)keyForDate:(NSDate *)date options:(KeyOption)option{
    NSMutableString *key = [NSMutableString stringWithString:@""];
    NSString *template = @"%02d";
    
    if (option & KeyOption_YearAsKey) {
        [key appendString:[NSString stringWithFormat:@"%li",[date year]]];
    }

    if (option & KeyOption_MonthAsKey) {
        [key appendString:[NSString stringWithFormat:template,[date month]]];
    }

    if (option & KeyOption_DayAsKey) {
        [key appendString:[NSString stringWithFormat:template,[date day]]];
    }

    return [NSString stringWithString:key];
}

//-(void)test{
//    NSString *testdb = @"test.db";
//    NSString *dbPath = [[self libraryPath] stringByAppendingPathComponent:testdb];
//    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
//    NSString *sql = @"CREATE TABLE IF NOT EXISTS 'RECORDS'('date' integer NOT NULL , 'muscle' text NOT NULL , 'data' blob NOT NULL);";
//    [db open];
//    if ([db executeUpdate:sql]) {
//        NSLog(@"Creation success");
//        WorkoutAction *act = [WorkoutAction new];
//        act.actionName = @"test";
//        
//        TargetMuscle *m = [TargetMuscle new];
//        m.muscle = @"muscle";
//        [m.actions addObject:act];
//        NSArray *dataArray = @[m];
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataArray];
//        
//        NSString *insert = @"INSERT INTO 'RECORDS' VALUES(?,?,?);";
//        if([db executeUpdate:insert , @(13),m.muscle,data]){
//            NSLog(@"insert success");
//            
//            NSString *query = @"SELECT * FROM 'RECORDS' where date = ? AND muscle = ?;";
//            FMResultSet *result = [db executeQuery:query,@(13),m.muscle];
//            while (result.next) {
//                NSData *d = [result dataForColumn:@"data"];
//                NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:d];
//                NSLog(@"%@",arr);
//            }
//        }
//        
//    }
//    [db close];
//}

@end

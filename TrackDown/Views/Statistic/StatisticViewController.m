//
//  StatisticViewController.m
//  TrackDown
//
//  Created by Gocy on 16/8/5.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "StatisticViewController.h"
#import "GraphView.h"
#import "NSDate+Components.h"
#import "CustomExpandableViewProtocol.h"
#import "ExpandableTableViewController.h"
#import "Masonry.h"
#import "WorkoutStatistic.h"
#import "CYWorkoutManager.h"
#import "PreDefines.h"
#import "ExpandableObjectProtocol.h"

/*
 数组里存着[date year]对应的WorkoutStatistic，有重名stat，区别是月份 , 数据按月份升序排列。
 整理成DIC：
 {@"动作名称" : @[
 @{ @"2016" :
 @[按月份升序的stats]
 },
 @{ @"2017":
 XXXXXXX
 }
 ]
 */
@interface DisplayStatistic : NSObject <ExpandableObject ,NSCopying>{
    BOOL _opened;
}

@property (nonatomic ,copy) NSString *displayName;
@property (nonatomic ,strong) NSMutableArray *yearArray;

@end

@implementation DisplayStatistic

-(id)copyWithZone:(NSZone *)zone{
    DisplayStatistic *stat = [DisplayStatistic new];
    stat.opened = _opened;
    stat.displayName = [_displayName copyWithZone:zone];
    stat.yearArray = [_yearArray copyWithZone:zone];
    
    return stat;
}

-(NSUInteger)countOfSecondaryObjects{
    return [_yearArray count];
}

-(NSArray *)descriptionForSecondaryObjects{
    return nil;
}

-(NSString *)description{
    return self.displayName;
}

-(BOOL)opened{
    return _opened;
}

-(void)setOpened:(BOOL)op{
    _opened = op;
}

@end

@interface StatisticViewController () <CustomCellDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,weak) ExpandableTableViewController *tableVC;
@property (nonatomic ,strong) NSMutableDictionary *statistic;
@property (nonatomic ,strong) NSMutableArray *displayArray;

@end

static NSString * const kCellReuseId = @"statisticCell";
static NSInteger graphTag = 1221;
static CGFloat cellHeight = 180;

@implementation StatisticViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    GraphView *gv = [[GraphView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width * 0.8, 200)];
//    gv.tag = 22;
//    gv.graphPoints = @[@(30),@(60),@(40),@(45),@(60),@(20)];
//    gv.year = [[NSDate date] year];
//    gv.fromMonth = 6;
//    gv.toMonth = 11;
//    [self.view addSubview:gv];
    
    [self constructTableView];
    WeakSelf();
    
    NSDateComponents *com = [NSDateComponents new];

    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    com.year = [date year] - 1;
    com.month = [date month] ;
    com.day = [date day];
    NSDate *d = [calendar dateFromComponents:com];
    
    [[CYWorkoutManager sharedManager] workoutStatisticForYearInDate:d completion:^(NSArray *res, NSDate *date) {
        [weakSelf groupStatistics:res onDate:date];
    }];
    
    [[CYWorkoutManager sharedManager] workoutStatisticForYearInDate:[NSDate date] completion:^(NSArray *res ,NSDate *date) {
        [weakSelf groupStatistics:res onDate:date];
    }];
    
    self.title = @"训练统计";
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.view viewWithTag:22].center = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Helpers


-(void)constructTableView{
    ExpandableTableViewController *tbvc = [ExpandableTableViewController new];
    UIView *v = tbvc.view;
    
    [self addChildViewController:tbvc];
    [self.view addSubview:v];
    
    _tableVC = tbvc;
    _tableVC.cellDataSource = self;
    
    UIView *superview = self.view;
    
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview);
        make.leading.equalTo(superview.mas_leading);
        make.trailing.equalTo(superview.mas_trailing);
        make.bottom.equalTo(superview.mas_bottom);
    }];
}


-(void)groupStatistics:(NSArray *)stats onDate:(NSDate *)date{
    /*
     数组里存着[date year]对应的WorkoutStatistic，有重名stat，区别是月份 , 数据按月份升序排列。
     整理成DIC：
     {@"动作名称" : @[
                      @{ @"2016" :
                         @[按月份升序的stats]
                        },
                        @{ @"2017":
                            XXXXXXX
                        }
                    ]
     */
    if (!_statistic) {
        _statistic = [NSMutableDictionary new];
    }
    NSInteger year = [date year];
    
    if (!self.displayArray) {
        self.displayArray = [NSMutableArray new];
    }
//    [self.displayArray removeAllObjects];
    
    for (WorkoutStatistic *stat in stats) { // 已经是升序了！
        if (_statistic[stat.key] == nil) {
            DisplayStatistic *dStat = [DisplayStatistic new];
            dStat.displayName = stat.key;
            dStat.yearArray = [NSMutableArray new];
            NSMutableArray *statArray = [NSMutableArray new];
            [statArray addObject:stat];
            [dStat.yearArray addObject:@{@(year):
                                     statArray
                                 }];
            _statistic[stat.key] = dStat;
            [self.displayArray addObject:dStat];
        }else{
            DisplayStatistic *dStat = _statistic[stat.key];
            NSInteger insertIndex = 0;
            BOOL added = NO;
            for ( ; insertIndex < dStat.yearArray.count; ++insertIndex) {
                NSDictionary *dic = dStat.yearArray[insertIndex];
                BOOL shouldBreak = NO;
                for (NSNumber *num in dic.allKeys) { // contains only one key
                    if ([num integerValue] < year) {
                        shouldBreak = YES;
                        break;
                    }
                    if ([num integerValue] == year) {
                        [dic[num] addObject:stat];
                        shouldBreak = YES;
                        added = YES;
                        break;
                    }
                }
                if (shouldBreak) {
                    break;
                }
            }
            if (!added) {
                NSMutableArray *statArray = [NSMutableArray new];
                [statArray addObject:stat];
                [dStat.yearArray insertObject:@{@(year):
                                                    statArray
                                                } atIndex:insertIndex];
            }
        }
    }
    
    self.tableVC.data = [[NSArray alloc] initWithArray:self.displayArray copyItems:YES];
    
}


#pragma mark - CustomCell DataSource

-(CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseId];
    
    GraphView *graph = [cell viewWithTag:graphTag];
    if (!graph) {
        graph = [[GraphView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.1, cellHeight * 0.05, self.view.bounds.size.width * 0.8, cellHeight * 0.9)];
        graph.tag = graphTag;
//        graph.graphPoints = @[@(30),@(60),@(40),@(45),@(60),@(20)];
//        graph.year = [[NSDate date] year];
//        graph.fromMonth = 6;
//        graph.toMonth = 11;
        [cell addSubview:graph];
    }
    [graph hideTip];
    
    DisplayStatistic *stat = self.displayArray[indexPath.section];
    NSDictionary *dic = stat.yearArray[indexPath.row];
    for (NSNumber *num in dic.allKeys) { // only 1 key
        graph.year = [num integerValue];
    }
    NSMutableArray *titles = [NSMutableArray new];
    NSMutableArray *points = [NSMutableArray new];
    NSMutableArray *descriptions = [NSMutableArray new];
    for (NSArray *arr in dic.allValues) { // only 1 value
        //@[按月份升序的stats]
        for(WorkoutStatistic *stat in arr){
            [titles addObject:[NSString stringWithFormat:@"%lu",stat.storeMonth]];
            double weight = [stat.data[key_weight] doubleValue];
            double reps = [stat.data[key_reps] doubleValue];
            double sets = [stat.data[key_sets] doubleValue];
            
            double averageWeight = weight / sets;
            double averageReps = reps / sets;
            double averageSets = sets / stat.trainingCount;
            
            [points addObject:@(averageWeight)];
            
            [descriptions addObject:[NSString stringWithFormat:@"%.2lfkg * %.1lf组 * %.1lf次/组",averageWeight,averageSets,averageReps]];
        }
        
    }
    
    graph.titles = titles;
    graph.graphPoints = points;
    graph.descriptions = descriptions;
    [graph setNeedsDisplay];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)registerCellReuseIdForTableView:(UITableView *)tableView{
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseId];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
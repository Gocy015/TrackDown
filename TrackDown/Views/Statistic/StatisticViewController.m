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
#import "CYExpandableTableViewController.h"
#import "Masonry.h"
#import "WorkoutStatistic.h"
#import "CYWorkoutManager.h"
#import "PreDefines.h"
#import "ExpandableObjectProtocol.h"
#import "CYPieChart.h"
#import "PieChartDataObject.h"
#import "UCZProgressView.h"
#import "UIColor+Hex.h"

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
@property (nonatomic ,copy) NSString *belongedMuscle;
@property (nonatomic ,strong) NSMutableArray *yearArray;

@end

static const NSInteger leftArrowTag = 21;
static const NSInteger rightArrowTag = 22;
static const NSInteger descriptionLabelTag = 23;
static const double kUnitChangeBoundary = 200000; // 20 tons

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

@interface StatisticViewController () <CustomCellDataSource ,UISearchBarDelegate ,ExpandableTableViewEventDelegate ,CYPieChartDelegate>

@property (nonatomic ,weak) CYExpandableTableViewController *tableVC;
@property (nonatomic ,weak) CYPieChart *chart;
@property (nonatomic ,strong) NSMutableDictionary *statistic;
@property (nonatomic ,strong) NSMutableArray *displayArray;
@property (nonatomic ,strong) NSMutableArray *searchArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UCZProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *progressContainer;

@property (nonatomic ,strong) NSArray <WorkoutStatistic *>*muscleStats;

@property (nonatomic ,strong) NSArray *pieColors;


@property (nonatomic) dispatch_group_t loadGroup;

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
    
    self.searchBar.delegate = self;
    [self initPieColors];
    [self constructTableView];
    [self constructPieChart];
    
//    NSDateComponents *com = [NSDateComponents new];
//
//    NSDate *date = [NSDate date];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    com.year = [date year] ;
//    com.month = [date month] ;
//    com.day = [date day];
//    NSDate *d = [calendar dateFromComponents:com];
    
//    [[CYWorkoutManager sharedManager] workoutActionStatisticForYearInDate:d completion:^(NSArray *res, NSDate *date) {
//        [weakSelf groupStatistics:res onDate:date];
//    }];
//    
//    [[CYWorkoutManager sharedManager] workoutActionStatisticForYearInDate:[NSDate date] completion:^(NSArray *res ,NSDate *date) {
//        [weakSelf groupStatistics:res onDate:date];
//    }];
    
    [self loadData];
    
    
    self.title = @"训练统计";
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"Statistic VC dealloc !");
}

#pragma mark - Actions

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
    if (![sender isEqual: self.segment]) {
        return ;
    }
    [self.searchBar resignFirstResponder];
    if(self.segment.selectedSegmentIndex == 0){
        self.tableVC.view.hidden = NO;
        self.searchBar.hidden = NO;
        self.chart.hidden = YES;
        [self.view viewWithTag:leftArrowTag].hidden = YES;
        [self.view viewWithTag:rightArrowTag].hidden = YES;
        [self.view viewWithTag:descriptionLabelTag].hidden = YES;
        
        
    }else{
        self.chart.hidden = NO;
        if(self.chart.objects.count > 0){
            [self.view viewWithTag:leftArrowTag].hidden = NO;
            [self.view viewWithTag:rightArrowTag].hidden = NO;
        }
        
        [self.view viewWithTag:descriptionLabelTag].hidden = NO;
        self.tableVC.view.hidden = YES;
        self.searchBar.hidden = YES;
    }
}


-(void)arrowClicked:(UIButton *)sender{
    switch (sender.tag) {
        case leftArrowTag:
            [self.chart goNextWithClockwise:YES];
            break;
        case rightArrowTag:
            [self.chart goNextWithClockwise:NO];
            break;
        default:
            break;
    }
}

#pragma mark - Helpers


-(void)initPieColors{
    self.pieColors = @[
                       [UIColor colorFromHex:@"#e73069"],
                       [UIColor colorFromHex:@"#ee534f"],
                       [UIColor colorFromHex:@"#ff8c53"],
                       [UIColor colorFromHex:@"#ffc851"],
                       [UIColor colorFromHex:@"#fff35f"],
                       [UIColor colorFromHex:@"#01c48c"],
                       [UIColor colorFromHex:@"#74a9bb"],
                       [UIColor colorFromHex:@"#0489a8"],
                       [UIColor colorFromHex:@"#4b4b67"],
                       [UIColor colorFromHex:@"#582e60"],
                       ];
 
}

-(void)constructPieChart{
    CYPieChart *chart = [CYPieChart new];
    [self.view addSubview:chart];
    chart.hidden = YES;
    chart.sliceBorderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    chart.sliceBorderWidth = 1.0f;
    chart.delegate = self;
    
    chart.colors = self.pieColors;
    
    chart.titleViewAnimationBlock = ^(TitleView * v, BOOL showing){
        if (showing) {
            v.backgroundColor = [UIColor darkGrayColor];
            v.titleColor = [UIColor whiteColor];
        }else{
            v.backgroundColor = [UIColor clearColor];
            v.titleColor = [UIColor blackColor];
        }
    };
    
    UIView *v = self.view;
    
    [chart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(v);
        make.width.mas_equalTo(220);
        make.height.mas_equalTo(300);
    }];
    
    
    self.chart = chart;
    
    [self constructPieChartIteratorButton];
    [self constructPieChartDescriptionLabel];
    
}


-(void)constructPieChartDescriptionLabel{
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    label.text = @"";
    label.textColor = [UIColor grayColor];
    [label sizeToFit];
    label.tag = descriptionLabelTag;
    
    [self.view addSubview:label];
    
    UIView *v = [self.view viewWithTag:leftArrowTag];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(v.mas_bottom).offset(22);
    }];
    
}

-(void)constructPieChartIteratorButton{
    UIButton *left = [UIButton new];
    [left setImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
    left.tag = leftArrowTag;
    [left addTarget:self action:@selector(arrowClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *right = [UIButton new];
    [right setImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
    right.tag = rightArrowTag;
    [right addTarget:self action:@selector(arrowClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:left];
    [self.view addSubview:right];
    
    CGFloat w = 38;
    CGFloat h = 50;
    
    UIView *v = self.chart;
    
    [left mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(w);
        make.height.mas_equalTo(h);
        make.top.equalTo(v.mas_bottom).offset(-12);
        make.right.equalTo(v.mas_left).offset(6);
    }];
    [right mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(w);
        make.height.mas_equalTo(h);
        make.top.equalTo(v.mas_bottom).offset(-12);
        make.left.equalTo(v.mas_right).offset(-6);
    }];
    
    left.hidden = YES;
    right.hidden = YES;
}

-(void)constructTableView{
    CYExpandableTableViewController *tbvc = [CYExpandableTableViewController new];
    UIView *v = tbvc.view;
    
    [self addChildViewController:tbvc];
    [self.view addSubview:v];
    
    _tableVC = tbvc;
    _tableVC.allowsMutipleSelection = NO;
    _tableVC.cellDataSource = self;
    _tableVC.eventDelegate = self;
    
    UIView *superview = self.view;
    
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(2);
        make.leading.equalTo(superview.mas_leading);
        make.trailing.equalTo(superview.mas_trailing);
        make.bottom.equalTo(superview.mas_bottom);
    }];
}

-(void)loadData{
    WeakSelf();
    
    [self.view bringSubviewToFront:self.progressView];
    
    self.tableVC.view.alpha = self.chart.alpha = 0;
    [self.view viewWithTag:leftArrowTag].alpha = 0;
    [self.view viewWithTag:rightArrowTag].alpha = 0;
    
    if (!self.loadGroup) {
        
        self.loadGroup = dispatch_group_create();
    }
    
    dispatch_group_enter(self.loadGroup);
    dispatch_group_enter(self.loadGroup);
    //直接enter两次，避免async跑得快，先leaveGroup
//        sleep(3);
    
    [[CYWorkoutManager sharedManager] loadAllActionStatistics:^(NSDictionary *res) {
        for (NSDate *key in res.allKeys) {
            [weakSelf groupStatistics:res[key] onDate:key];
        }
        dispatch_group_leave(weakSelf.loadGroup);
        NSLog(@"Finish load actions");
    }];
    
    
    
    
    [[CYWorkoutManager sharedManager] loadAllMuscleStatistics:^(NSArray *res) {
        [weakSelf configurePieWithStatistics:res];
        dispatch_group_leave(weakSelf.loadGroup);
        NSLog(@"Finish load muscles");
    }];
    
    dispatch_group_notify(self.loadGroup, dispatch_get_main_queue(), ^{
        weakSelf.searchArray = [NSMutableArray arrayWithArray:weakSelf.displayArray];;
        weakSelf.tableVC.data = [NSArray arrayWithArray:weakSelf.searchArray];
        
        [weakSelf.chart updateAppearance];
        
        weakSelf.progressView.progress = 1;
        
        [UIView animateWithDuration:0.22f animations:^{
            weakSelf.chart.alpha = 1;
            weakSelf.tableVC.view.alpha = 1;
            weakSelf.progressContainer.alpha = 0;
            
            if (weakSelf.chart.objects.count > 1) {
                
                [self.view viewWithTag:leftArrowTag].alpha = 1;
                [self.view viewWithTag:rightArrowTag].alpha = 1;
            }
        } completion:^(BOOL finished) {
            [weakSelf.progressContainer removeFromSuperview];
        }];
        
        NSLog(@"Update UI");
    });
    
    
    //由于读取数据库操作本来就有逻辑是dispatch_async的，所以
    //用NSOperation Queue并不能保证updateUI正确执行。只能通过回调block来限制updateUI的执行时机。
    
//    NSOperationQueue *loadQueue = [[NSOperationQueue alloc] init];
//    loadQueue.maxConcurrentOperationCount = 2;
//    
//    NSBlockOperation *loadActions = [NSBlockOperation blockOperationWithBlock:^{
//        [[CYWorkoutManager sharedManager] loadAllActionStatistics:^(NSDictionary *res) {
//            for (NSDate *key in res.allKeys) {
//                [weakSelf groupStatistics:res[key] onDate:key];
//            }
//            NSLog(@"Finish load actions");
//        }];
//    }];
//    
//    NSBlockOperation *loadMuscles = [NSBlockOperation blockOperationWithBlock:^{
//        [[CYWorkoutManager sharedManager] loadAllMuscleStatistics:^(NSArray *res) {
//            [weakSelf configurePieWithStatistics:res];
//        }];
//        NSLog(@"Finish load muscles");
//    }];
//    
//    NSBlockOperation *updateUI = [NSBlockOperation blockOperationWithBlock:^{
//        
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            
//            weakSelf.tableVC.data = [[NSArray alloc] initWithArray:weakSelf.displayArray copyItems:YES];
//            
//            [weakSelf.chart updateAppearance];
//            NSLog(@"update ui ");
//        }];
//    }];
//    
//    [updateUI addDependency:loadMuscles];
//    [updateUI addDependency:loadActions];
//    
//    
//    [loadQueue addOperation:loadMuscles];
//    [loadQueue addOperation:loadActions];
//    [loadQueue addOperation:updateUI];
    
//    [loadMuscles start];
//    [loadActions start];
//    [updateUI start];
    
    
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
                         @[按月份升序的stats]
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
            dStat.belongedMuscle = stat.mus;
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
    
//    self.tableVC.data = [[NSArray alloc] initWithArray:self.displayArray copyItems:YES];
    
}


-(void)configurePieWithStatistics:(NSArray *)stats{
    NSMutableArray *objs = [NSMutableArray new];
    double sum = 0;
    double min = DBL_MAX;
    for (WorkoutStatistic *stat in stats) {
        PieChartDataObject *pieObj = [PieChartDataObject new];
        pieObj.title = stat.key;
        double weight = [stat.data[key_weight] doubleValue];
        sum += weight;
        if (min > weight) {
            min = weight;
        }
        
        pieObj.value = weight;
//        pieObj.detailText = [NSString stringWithFormat:@"%@已经累计经历了%.2fkg的训练量",stat.key,weight];
        [objs addObject:pieObj];
    }
    if (min / sum < 1.0 / 9.0) {
        self.chart.titleLayout = TitleLayout_Bottom;
    }else{
        self.chart.titleLayout = TitleLayout_Inside;
    }
    self.chart.objects = objs;
    
    
    self.muscleStats = [NSArray arrayWithArray:stats];
    
}


#pragma mark - ExpandableTableView Event Delegate


-(void)didSelectHeaderAnIndex:(NSUInteger)index{
    [self.searchBar resignFirstResponder];

}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}


#pragma mark - CYPieChart Delegate
-(void)pieChart:(CYPieChart *)pieChart didSelectPieAtIndex:(NSInteger)index{
    NSLog(@"%@ , 累计重量: %0.2fkg" ,self.muscleStats[index].key ,[self.muscleStats[index].data[key_weight] doubleValue]);
    NSString *mus = self.muscleStats[index].key;
    double weight = [self.muscleStats[index].data[key_weight] doubleValue];
    NSString *unit = @"千克";
    if (weight > kUnitChangeBoundary) {
        weight = weight / 1000.0;
        unit = @"吨";
    }
    if (weight > kUnitChangeBoundary) {
        weight = weight / 1000.0;
        unit = @"千吨";
    }
    
    UILabel *label = [self.view viewWithTag:descriptionLabelTag];
    label.text = [NSString stringWithFormat:@"%@ , 累计重量: %0.2f %@" ,mus ,weight,unit];
    [label sizeToFit];
}


#pragma mark - UISearchBar Delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    NSLog(@"%@",searchText);
    if ([searchText length] <= 0) {
        self.searchArray = [NSMutableArray arrayWithArray:self.displayArray];
    }else{
        [self.searchArray removeAllObjects];
        for (DisplayStatistic *s in self.displayArray) {
            if ([s.displayName containsString:searchText] || [s.belongedMuscle containsString:searchText]) {
                [self.searchArray addObject:s];
            }
        }
    }
    
    self.tableVC.data = [NSArray arrayWithArray:self.searchArray];
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
    
    DisplayStatistic *stat = self.searchArray[indexPath.section];
    NSDictionary *dic = stat.yearArray[indexPath.row];
    for (NSNumber *num in dic.allKeys) { // only 1 key
        graph.mainTitle = [NSString stringWithFormat:@"%lu" ,[num unsignedIntegerValue]];
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

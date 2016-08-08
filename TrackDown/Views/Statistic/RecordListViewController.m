//
//  RecordListViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/22.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "RecordListViewController.h"
#import "FSCalendar.h"
#import "NSDate+Components.h"
#import "CYWorkoutManager.h"
#import "PreDefines.h"
#import "ExpandableTableViewController.h"
#import "Masonry.h"
#import "TargetMuscle.h"

@interface RecordListViewController () <FSCalendarDelegate ,FSCalendarDataSource >

@property (nonatomic ,strong)UITableView *tableView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (nonatomic ,strong) NSDictionary *currentRecords;
@property (nonatomic ,weak) ExpandableTableViewController *tableVC;

@end

@implementation RecordListViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"训练日志";
    
    self.calendar.delegate = self;
    self.calendar.dataSource = self;
     
    // 和谐掉默认选择今天
    self.calendar.appearance.todayColor = nil;
    self.calendar.appearance.titleTodayColor = [UIColor blackColor];
    self.calendar.appearance.subtitleTodayColor = [UIColor darkGrayColor];
    
    
    [self constructTableView];
    [self loadRecords];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
//    NSDate *today = [NSDate date];
//    self.calendar.currentPage = [self.calendar dateFromString:[NSString stringWithFormat:@"%li-%li",[today year],[today month]] format:@"yyyy-MM"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[CYWorkoutManager sharedManager] releaseRecordCache];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - FSCalendar Delegate

-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    NSLog(@"calendar.select date : %@",date);
    [self updateTableView];
}



-(void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
    NSLog(@"calendar.currentPage : %@ ",calendar.currentPage);
    [self loadRecords];
}



#pragma mark - FSCalendar DataSource

-(NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date{
//    return @"训练日";
    NSInteger currentYear = [calendar.currentPage year];
    NSInteger currentMonth = [calendar.currentPage month];
    NSInteger year = [date year];
    NSInteger month = [date month];
    NSInteger day = [date day];
    if (year == currentYear && currentMonth == month && self.currentRecords && [self.currentRecords objectForKey:@(day)] != nil) {
        return @"训练日";
    }
    return nil;
}


-(NSDate *)minimumDateForCalendar:(FSCalendar *)calendar{
    return [calendar dateWithYear:1970 month:1 day:1];
}


#pragma mark - Helpers

-(void)constructTableView{
    ExpandableTableViewController *tbvc = [ExpandableTableViewController new];
    UIView *v = tbvc.view;
    
    [self addChildViewController:tbvc];
    [self.view addSubview:v];
    
    _tableVC = tbvc;
    
    UIView *superview = self.view;
    UIView *calendar = self.calendar;
    
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(calendar.mas_bottom).offset(6);
        make.leading.equalTo(superview.mas_leading);
        make.trailing.equalTo(superview.mas_trailing);
        make.bottom.equalTo(superview.mas_bottom);
    }];
}

-(void)updateTableView{
    
    //还是需要判断当前选中日期是不是本月。
    
    
    //clear
    _tableVC.data = @[];
    
    //if selectedDate is in current month ,add data to table;
    
    NSInteger currentYear = [self.calendar.currentPage year];
    NSInteger currentMonth = [self.calendar.currentPage month];
    NSInteger year = [self.calendar.selectedDate year];
    NSInteger month = [self.calendar.selectedDate month];
    NSInteger day = [self.calendar.selectedDate day];
    if(currentYear == year && currentMonth == month && self.currentRecords[@(day)] != nil){
        NSDictionary *dic = self.currentRecords[@(day)];
        NSMutableArray *arr = [NSMutableArray new];
        for (id key in [dic allKeys]) {
            TargetMuscle *m = dic[key];
            [arr addObjectsFromArray:m.actions];
        }
        _tableVC.data = [NSArray arrayWithArray:arr];;
    }
}


-(void)loadRecords{
    //读取当前月数据
    WeakSelf();
    
    [[CYWorkoutManager sharedManager]workoutRecordsForMonthInDate:self.calendar.currentPage completion:^(NSDictionary *res) {
        weakSelf.currentRecords = res;
        [weakSelf.calendar reloadData];
        if (weakSelf.calendar.selectedDate) {
            [weakSelf updateTableView];
        }
    }];
}


@end

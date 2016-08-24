//
//  WorkoutManagmentViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "WorkoutMuscleViewController.h"
#import "CYWorkoutManager.h"
#import "TargetMuscle.h"
#import "StoryboardManager.h"
#import "WorkoutActionViewController.h"
#import "AddWorkoutViewController.h"


@interface WorkoutMuscleViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *workoutTableView;

@end

static NSString *const reuseId = @"kMuscleManagementReuseCell";
static NSString * const manageVCId = @"WorkoutMuscleViewController";
static NSString * const actionVCId = @"WorkoutActionViewController";
static NSString * const addVCId = @"AddWorkoutViewController";


@implementation WorkoutMuscleViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"训练列表";
    [self.workoutTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseId];
    
    self.workoutTableView.tableFooterView = [UIView new];
    
    [self constructNaviAddButton];
    [self registerNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Notification
- (void)registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuscle:) name:n_DeleteMuscleSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMuscle:) name:n_AddMuscleSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(writeToDiskFail:) name:n_WriteToDiskFailNotification object:nil];
}

-(void)deleteMuscle:(NSNotification *)noti{
    NSObject *obj = noti.object;
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSInteger idx = [(NSNumber *)obj integerValue];
        if(idx < 0) return;
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [self.workoutTableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationFade];
    }

    
}

-(void)addMuscle:(NSNotification *)noti{
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:[[CYWorkoutManager sharedManager] getCurrentWorkoutTypes].count - 1 inSection:0];
    [self.workoutTableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)writeToDiskFail:(NSNotification *)noti{
    
}


#pragma mark - Actions

-(void)addNewTargetMuscle{
    
    AddWorkoutViewController *addVC = [[StoryboardManager storyboardWithIdentifier:@"Management"] instantiateViewControllerWithIdentifier:addVCId];
    
    [self presentViewController:addVC animated:YES completion:nil];
}


#pragma mark - Helpers
-(void)constructNaviAddButton{
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewTargetMuscle)];
    self.navigationItem.rightBarButtonItem = add;
}

#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[CYWorkoutManager sharedManager] getCurrentWorkoutTypes].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    TargetMuscle *muscle = [[[CYWorkoutManager sharedManager] getCurrentWorkoutTypes] objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    cell.textLabel.text = muscle.muscle;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove
         
        [[CYWorkoutManager sharedManager] deleteTargetMuscle:[[[CYWorkoutManager sharedManager] getCurrentWorkoutTypes] objectAtIndex:indexPath.row] writeToDiskImmediately:YES];
    }
    
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    //避免数据紊乱，不准删！
    return NO;
    return YES;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    TargetMuscle *muscle = [[[CYWorkoutManager sharedManager] getCurrentWorkoutTypes] objectAtIndex:indexPath.row];

    WorkoutActionViewController *actionVC = [[StoryboardManager storyboardWithIdentifier:@"Management"]instantiateViewControllerWithIdentifier:actionVCId];
    actionVC.muscle = muscle;
    
    [self.navigationController pushViewController:actionVC animated:true];
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

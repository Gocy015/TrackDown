//
//  TrainingViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/13.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "TrainingViewController.h"
#import "TargetMuscle.h"
#import "WorkoutAction.h"
#import "CYWorkoutManager.h"
#import "TrainingListTableViewController.h"

@interface TrainingViewController () <TrainingListViewDelegate>{
    NSUInteger _muscleIndex;
    NSUInteger _actIndex;
    NSUInteger _setCount;
    NSUInteger _currentIndex;
}
@property (weak, nonatomic) IBOutlet UILabel *currentWorkoutLabel;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UITextField *repsTextField;
@property (weak, nonatomic) IBOutlet UILabel *nextWorkoutLabel;

@property (nonatomic ,weak) WorkoutAction *currentAction;

@end

@implementation TrainingViewController


#pragma mark -  Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _muscleIndex = _actIndex = 0;
    _setCount = 1;
    _currentIndex = 0;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_currentAction) {
        self.currentWorkoutLabel.text = [NSString stringWithFormat:@"%@(%li/%li)",_currentAction.actionName,(unsigned long)_setCount,(unsigned long)_currentAction.sets];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)setPlan:(NSMutableArray *)plan{
    _plan = plan;
    _muscleIndex = _actIndex = 0;
    _setCount = 1;
    if (plan.count > 0) {
        
        [self initAction];
    }
}

#pragma mark - Actions
- (IBAction)endTraining:(id)sender { 
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextMove:(id)sender {
    [self updateUI];
}
- (IBAction)showList:(id)sender {
    [self showWorkoutList];
}

#pragma mark - Helpers

-(void)showWorkoutList{
    NSMutableArray *displayWorkouts = [NSMutableArray new];
    for (TargetMuscle *m in self.plan) {
        for (WorkoutAction *act in m.actions) {
            NSString *displayString = [NSString stringWithFormat:@"%@ x %li组",act.actionName,(unsigned long)act.sets];
            [displayWorkouts addObject:displayString];
        }
    }
    
    TrainingListTableViewController *listvc = [TrainingListTableViewController new];
    
    listvc.delegate = self;
    listvc.currentIndex = _currentIndex;
    listvc.dataArr = displayWorkouts;
    
    listvc.view.frame = self.view.bounds;
    
    [self.view addSubview:listvc.view];
    [self addChildViewController:listvc];
}

-(void)updateUI{
    [self forwardToNextActionIfNeeded];
    
    if (_currentAction) {
        self.currentWorkoutLabel.text = [NSString stringWithFormat:@"%@(%li/%li)",_currentAction.actionName,(unsigned long)_setCount,(unsigned long)_currentAction.sets];
    }
    else{
        self.currentWorkoutLabel.text = @"训练结束";
    }
}


-(void)forwardToNextActionIfNeeded{
    TargetMuscle *m = self.plan[_muscleIndex];
    WorkoutAction *act = m.actions[_actIndex];
    _currentIndex ++;
    if (_setCount < act.sets) {
        _setCount += 1;
        return ;
    }
    
    // current muscle not done
    if (_actIndex + 1 < m.actions.count) {
        _actIndex += 1;
        _currentAction = m.actions[_actIndex];
        _setCount = 1;
        return ;
    }
    
    if (_muscleIndex + 1 < self.plan.count) {
        _muscleIndex += 1;
        _actIndex = 0;
        m = self.plan[_muscleIndex];
        _currentAction = m.actions[_actIndex];
        _setCount = 1;
        return ;
    }
    
    _currentAction = nil;
    
    return ;
}

-(void)initAction{
    _currentAction = self.plan[_muscleIndex].actions[_actIndex];
    
}

-(void)moveActionFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex{
    if (fromIndex <= _currentIndex || toIndex <= _currentIndex || fromIndex == toIndex) {
        return;
    }
    
    
    // locate
    
    TargetMuscle *insert = [TargetMuscle new];
    NSUInteger insertIndex = 0;
    for (TargetMuscle *m in self.plan) {
        if (fromIndex > m.actions.count - 1) {
            fromIndex -= m.actions.count;
            continue;
        }
        insert.muscle = m.muscle;
        insert.actions = [NSMutableArray arrayWithArray:@[[m.actions objectAtIndex:fromIndex]]];
        [m.actions removeObjectAtIndex:fromIndex];
        if(m.actions.count == 0){
            [self.plan removeObject:m];
        }
        break;
    }
    
    TargetMuscle *moveBack = [TargetMuscle new];
    BOOL inserted = NO;
    for (TargetMuscle *m in self.plan) {
        
        if (toIndex > m.actions.count - 1) {
            toIndex -= m.actions.count;
            insertIndex ++;
            continue;
        }
        moveBack.muscle = m.muscle;
        for (NSUInteger i = toIndex; i < m.actions.count; ++i ) {
            [moveBack.actions addObject:m.actions[i]];
            
        }
        [m.actions removeObjectsInRange:NSMakeRange(toIndex, moveBack.actions.count)];
        if (m.actions.count == 0) {
            [self.plan removeObject:m];
        }else{
            insertIndex ++;
        }
        inserted = YES;
        [self.plan insertObject:insert atIndex:insertIndex];
        
        [self.plan insertObject:moveBack atIndex:insertIndex + 1];
        
        break;
    }
    
    if (!inserted) {
        [self.plan addObject:insert];
    }
    
    NSLog(@"%@",self.plan);
}


#pragma mark - TrainingListView Delegate

-(void)didMoveFromIndex:(NSUInteger)from toIndex:(NSUInteger)to{
    [self moveActionFromIndex:from toIndex:to];
}

@end

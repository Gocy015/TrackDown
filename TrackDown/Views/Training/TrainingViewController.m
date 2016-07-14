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

@interface TrainingViewController (){
    NSUInteger _muscleIndex;
    NSUInteger _actIndex;
    NSUInteger _setCount;
    
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

#pragma mark - Helpers

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




@end

//
//  MainViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/9.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "MainViewController.h"
#import "WorkoutMuscleViewController.h"
#import "StoryboardManager.h"
#import "WorkoutPlanningViewController.h"
#import "TrainingViewController.h"

@interface MainViewController ()<WorkoutPlanningDelegate>

@end
static NSString * const manageVCId = @"WorkoutMuscleViewController";
static NSString * const planVCId = @"WorkoutPlanningViewController";
static NSString * const trainVCId = @"TrainingViewController";


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)gotoManagement:(id)sender {
    WorkoutMuscleViewController *wkvc = [[StoryboardManager storyboardWithIdentifier:@"Management"]instantiateViewControllerWithIdentifier:manageVCId];
    [self.navigationController pushViewController:wkvc animated:YES];
}
- (IBAction)gotoPlan:(id)sender {
    WorkoutPlanningViewController *pvc = [[StoryboardManager storyboardWithIdentifier:@"Training"] instantiateViewControllerWithIdentifier:planVCId];
    pvc.delegate = self;
    [self.navigationController pushViewController:pvc animated:YES];
}


#pragma mark - WorkoutPlanning Delegate

-(void)didFinishPlanningWorkout:(NSArray<TargetMuscle *> *)plan{
    if ([[self.navigationController topViewController] isKindOfClass:[WorkoutPlanningViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
        TrainingViewController *trainVC = [[StoryboardManager storyboardWithIdentifier:@"Training"] instantiateViewControllerWithIdentifier:trainVCId];
        trainVC.plan = [NSMutableArray arrayWithArray:plan];
        [self presentViewController:trainVC animated:YES completion:nil];
    }
}

@end

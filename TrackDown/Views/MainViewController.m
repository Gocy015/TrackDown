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

@interface MainViewController ()

@end
static NSString * const manageVCId = @"WorkoutMuscleViewController";
static NSString * const planVCId = @"WorkoutPlanningViewController";

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
    [self.navigationController pushViewController:pvc animated:YES];
}

@end

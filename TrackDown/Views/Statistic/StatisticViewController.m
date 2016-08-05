//
//  StatisticViewController.m
//  TrackDown
//
//  Created by Gocy on 16/8/5.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "StatisticViewController.h"
#import "GraphView.h"

@interface StatisticViewController ()

@end

@implementation StatisticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GraphView *gv = [[GraphView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    gv.tag = 22;
    gv.graphPoints = @[@(30),@(60),@(40),@(45),@(60),@(20)];
    [self.view addSubview:gv];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view viewWithTag:22].center = self.view.center;
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

@end

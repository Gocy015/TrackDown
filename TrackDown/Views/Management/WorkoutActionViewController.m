//
//  WorkoutActionViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/11.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "WorkoutActionViewController.h"
#import "TargetMuscle.h"
#import "WorkoutAction.h"
#import "StoryboardManager.h"
#import "AddWorkoutViewController.h"
#import "CYWorkoutManager.h"
#import "CYGuidanceManager.h"
#import "CYGuidanceView.h"
#import "UILabel+ConstraintSize.h"

@interface WorkoutActionViewController ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL _changed;
}
@property (weak, nonatomic) IBOutlet UITableView *actionsTableView;


@end

static NSString *const reuseId = @"kActionReuseCell";
static NSString * const addVCId = @"AddWorkoutViewController";

@implementation WorkoutActionViewController

#pragma mark - Life cycle
-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.actionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseId];
    
    self.actionsTableView.tableFooterView = [UIView new];
    
    [self constructNaviAddButton];
    [self registerNotifications];
    
    _changed = NO;
    [self.actionsTableView setEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = self.muscle.muscle;
}

-(void)viewDidAppear:(BOOL)animated{
    [self showGuidance];
}

-(void)dealloc{
    if (_changed) {
        
        [[CYWorkoutManager sharedManager] updateMuscleActions:_muscle];

    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Actions

-(void)addNewWorkoutAction{
    AddWorkoutViewController *addVC = [[StoryboardManager storyboardWithIdentifier:@"Management"] instantiateViewControllerWithIdentifier:addVCId];
    addVC.muscle = self.muscle;
    
    [self presentViewController:addVC animated:YES completion:nil];
}



#pragma mark - Helpers

-(void)constructNaviAddButton{
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewWorkoutAction)];
    self.navigationItem.rightBarButtonItem = add;
}


-(void)showGuidance{
    if ([CYGuidanceManager shouldShowGuidance:GuideType_ActionManagement]) {
        
        CGRect first = [self.actionsTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        CGRect sec = [self.actionsTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        CGRect showRect = CGRectUnion(first, sec);
        
        UILabel *label = [UILabel mediumLabelWithSize:15];
        label.text = @"拖动单元格可重新排序，方便训练时快速选定";
        [label sizeToFit];
        
        GuideInfo *info = [[GuideInfo alloc] initWithGuideRect:showRect descriptionView:label verticalPosition:VerticalPosition_Bottom horizontalPosition:HorizontalPosition_Middle cornerRadius:6];
        
        CYGuidanceView *guide = [CYGuidanceView new];
        
        [guide addStep:@[info]];
        guide.hintText = @"点击屏幕以继续";
        
        [guide showInView:self.actionsTableView animated:YES];
        
        
        [CYGuidanceManager updateGuidance:GuideType_ActionManagement withShowStatus:YES];
    }
}


#pragma mark - Notification
- (void)registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAction:) name:n_DeleteActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAction:) name:n_AddActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(writeToDiskFail:) name:n_WriteToDiskFailNotification object:nil];
}

-(void)addAction:(NSNotification *)noti{
    
    NSObject *obj = noti.object;
    if ([obj isKindOfClass:[WorkoutAction class]]) {
//        [self.muscle.actions addObject:(WorkoutAction *)obj]; already added !! pass by ref!
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:0 inSection:0];

        [self.actionsTableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)deleteAction:(NSNotification *)noti{
    // new action
    NSObject *obj = noti.object;
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSInteger idx = [(NSNumber *)obj integerValue];
        if(idx < 0) return;
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [self.actionsTableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

-(void)writeToDiskFail:(NSNotification *)noti{
    
}

#pragma mark - UITableView Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.muscle.actions.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    WorkoutAction *act = self.muscle.actions[indexPath.row];
    
    cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    cell.textLabel.text = act.actionName;
    
    return cell;
}



//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //remove
//        [[CYWorkoutManager sharedManager] deleteAction:self.muscle.actions[indexPath.row] fromMuscle:self.muscle writeToDiskImmediatly:YES];
//        
//    }
//    
//    
//}

-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
//
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
////    return NO;
//    return YES;
//}


#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //TODO: - 动作介绍
}



-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    _changed = YES;
    [self.muscle.actions exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
}


@end

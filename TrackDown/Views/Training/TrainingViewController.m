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
#import "ListCountButton.h"
#import "SDVersion.h"
#import "UCZProgressView.h"
#import "RoundedButton.h"
#import "CYExpandableTableViewController.h"
#import "Masonry.h"

@interface TrainingViewController () <TrainingListViewDelegate,UIPopoverPresentationControllerDelegate ,UITextFieldDelegate>{
    NSUInteger _muscleIndex;
    NSUInteger _actIndex;
    NSUInteger _setCount;
    NSUInteger _currentIndex;
    NSInteger _timeElapesd;
    NSUInteger _expectedRestTime;
    NSUInteger _frameRate;
}
@property (weak, nonatomic) IBOutlet UILabel *currentWorkoutLabel;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UITextField *repsTextField;
@property (weak, nonatomic) IBOutlet UILabel *nextWorkoutLabel;

@property (weak, nonatomic) IBOutlet UIView *restView;
@property (weak, nonatomic) IBOutlet UCZProgressView *progressView;
@property (nonatomic ,weak) WorkoutAction *currentAction;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;

@property (nonatomic ,strong) CADisplayLink *countDownLink;


//complete view
@property (weak, nonatomic) IBOutlet UIView *completeView;
@property (nonatomic ,weak) CYExpandableTableViewController *doneTableVC;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;
@property (weak, nonatomic) IBOutlet RoundedButton *doneButton;



@end

@implementation TrainingViewController


#pragma mark -  Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _muscleIndex = _actIndex = 0;
    _setCount = 1;
    _currentIndex = 0;
    
    self.title = @"训练!";
    [self installNaviItems];
    [self constructCompleteView];
    [self initNotifications];
    [self configTextFields];
    
    _expectedRestTime = [[CYWorkoutManager sharedManager] getTimeBreak];
    _frameRate = 30;
//    _progressView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _restView.alpha = 0;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_currentAction) {
        self.currentWorkoutLabel.text = [NSString stringWithFormat:@"%@(%li/%li)",_currentAction.actionName,(unsigned long)_setCount,(unsigned long)_currentAction.sets];
    }
    
    
//    UIGraphicsBeginImageContext(self.restView.frame.size);
//    [[UIImage imageNamed:@"bat"] drawInRect:self.restView.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    self.restView.backgroundColor = [UIColor colorWithPatternImage:image];
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

#pragma mark - Setter



-(void)setPlan:(NSMutableArray *)plan{
    _plan = plan;
    _muscleIndex = _actIndex = 0;
    _setCount = 1;
    if (plan.count > 0) {
        
        [self initAction];
    }
}


#pragma mark - Getter

-(CADisplayLink *)countDownLink{
    if (!_countDownLink) {
        _countDownLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(doCountDown)];
        _countDownLink.frameInterval = 60 / _frameRate;
    }
    return _countDownLink;
}

#pragma mark - Actions
- (void)endTraining {
    //TODO: Alert
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)goHome:(id)sender {
    [self endTraining];
}
- (IBAction)skipRest:(id)sender {
    [self endCountDown];
}

- (IBAction)nextMove:(id)sender {
    
    if ([self verifyUserInput]) {
        [_currentAction.weightPerSet addObject:@([_weightTextField.text doubleValue])];
        [_currentAction.repeatsPerSet addObject:@([_repsTextField.text doubleValue])];
        [self startCountDown:^(BOOL started) {
            if (started) {
                [self updateUI];
            }
        }];
    }else{
        //TODO: Alert
    }
    
    
}
- (IBAction)tapBackground:(id)sender {
    [_repsTextField resignFirstResponder];
    [_weightTextField resignFirstResponder];
}

#pragma mark - Helpers

-(void)startCountDown:(void(^)(BOOL started))block{
    
    self.progressView.progress = 0;
    self.countDownLabel.text = [NSString stringWithFormat:@"%li",_expectedRestTime];
    [self.navigationController setNavigationBarHidden:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.restView.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            _timeElapesd = 0;
            [self.countDownLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        }
        
        block(finished);
    }];
}

-(void)endCountDown{
    [self.countDownLink invalidate];
    self.countDownLink = nil;
    _timeElapesd = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.restView.alpha = 0;
    } completion:^(BOOL finished) {
        
        self.progressView.progress = 0;
        [self.navigationController setNavigationBarHidden:NO];
    }];
}

-(void)doCountDown{
    if (_timeElapesd/_frameRate > _expectedRestTime) {
        
        [self endCountDown];
        return ;
    }
    self.countDownLabel.text = [NSString stringWithFormat:@"%li",_expectedRestTime - _timeElapesd/_frameRate];
    CGFloat exactTime = ((CGFloat)_timeElapesd/(CGFloat)_frameRate) / (CGFloat)_expectedRestTime;
    if (exactTime >= 1) {
        exactTime = 0.999999;
    }
    _progressView.progress = exactTime;
    
    
    _timeElapesd ++;
}

-(BOOL)verifyUserInput{
    if ([_weightTextField.text length] <= 0) {
        return NO;
    }
    if ([_repsTextField.text length] <= 0) {
        return NO;
    }
    
    //TODO: Determine input is valid num
    NSCharacterSet *weightSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890."];
    NSCharacterSet *repSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    //移除两端
    if([[_weightTextField.text stringByTrimmingCharactersInSet:weightSet] length] > 0){
        return NO;
    }
    
    if([[_repsTextField.text stringByTrimmingCharactersInSet:repSet] length] > 0){
        return NO;
    }
    return YES;
}

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
    listvc.currentIndex =  _actIndex + _muscleIndex ;
    listvc.dataArr = displayWorkouts;
    
    
    if (displayWorkouts.count <= 10) {
        
        listvc.modalPresentationStyle = UIModalPresentationPopover;
        listvc.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
        listvc.popoverPresentationController.delegate = self;
        listvc.popoverPresentationController.backgroundColor = [UIColor grayColor];
        listvc.view.alpha = 0.5;
        
        CGFloat width = 270;
        CGFloat height = MIN(44 * 10,44 * displayWorkouts.count);
        
        listvc.preferredContentSize = CGSizeMake(width, height);
        [self presentViewController:listvc animated:YES completion:nil];
    }else{
        [self.navigationController pushViewController:listvc animated:YES];
        
        listvc.title = @"训练计划";
    }
    
//    listvc.view.frame = self.view.bounds;
//    
//    [self.view addSubview:listvc.view];
//    [self addChildViewController:listvc];
}

-(void)updateUI{
    [self forwardToNextActionIfNeeded];
    
    if (_currentAction) {
        self.currentWorkoutLabel.text = [NSString stringWithFormat:@"%@(%li/%li)",_currentAction.actionName,(unsigned long)_setCount,(unsigned long)_currentAction.sets];
    }
    else{
        [self workoutComplete];
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
    if (fromIndex <= _actIndex + _muscleIndex || toIndex <= _actIndex+_muscleIndex || fromIndex == toIndex) {
        return;
    }
    BOOL upToDown = fromIndex < toIndex;
    
    // locate
    TargetMuscle *insert = [TargetMuscle new];
    for (TargetMuscle *m in self.plan) {
        if (fromIndex > m.actions.count - 1) {
            fromIndex -= m.actions.count;
            continue;
        }
        insert.muscle = m.muscle;
        insert.actions = [NSMutableArray arrayWithArray:@[[m.actions objectAtIndex:fromIndex]]];
//
        [m.actions removeObjectAtIndex:fromIndex];
        if (m.actions.count == 0) {
            [self.plan removeObject:m];
        }
        if(upToDown){
            toIndex --; // 少数一个数
        }
        break;
    }
    
    TargetMuscle *moveBack = [TargetMuscle new];
    BOOL inserted = NO;
    NSUInteger insertIndex = 0;
    for (TargetMuscle *m in self.plan) {
        
        if (toIndex > m.actions.count - 1) {
            toIndex -= m.actions.count;
            insertIndex ++;
            continue;
        }
        moveBack.muscle = m.muscle;
        
        if (upToDown) {
            toIndex ++;//从上往下拉，被占的位置应上移，反之才是下移
        }
        for (NSUInteger i = toIndex; i < m.actions.count; ++i ) {
            [moveBack.actions addObject:m.actions[i]];
            
        }
        [m.actions removeObjectsInRange:NSMakeRange(toIndex, moveBack.actions.count)];
        
        if(m.actions.count != 0){
            insertIndex ++;
        }
        inserted = YES;
        
        
        [self.plan insertObject:insert atIndex:insertIndex];
        if (moveBack.actions.count) {
            [self.plan insertObject:moveBack atIndex:insertIndex + 1];
        }
        
        if (m.actions.count == 0) {
            [self.plan removeObject:m];
        }
        
        
        break;
    }
    
    if (!inserted) {
        [self.plan addObject:insert];
    }
    
    [self log:self.plan];
}

-(void)configTextFields{
    _weightTextField.delegate = self;
    _repsTextField.delegate = self;
    
    _weightTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _repsTextField.keyboardType = UIKeyboardTypeNumberPad;
    
}

-(void)constructCompleteView{
    CYExpandableTableViewController *tbvc = [CYExpandableTableViewController new];
    UIView *v = tbvc.view;
    
    [self addChildViewController:tbvc];
    [self.completeView addSubview:v];
    
    _doneTableVC = tbvc;
    
    UIView *superview = self.completeView;
    UIView *ceil = _doneLabel;
    UIView *floor = _doneButton;
    
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ceil.mas_bottom).offset(20);
        make.bottom.equalTo(floor.mas_top).offset(-20);
        make.leading.equalTo(superview).offset(10);
        make.trailing.equalTo(superview).offset(-10);
    }];
    
    self.completeView.hidden = YES;

}

-(void)installNaviItems{
    
    //    UIImage *img = [UIImage imageNamed:@"list"];
    //
    //    UIImage *resizedImg = [img resize:CGSizeMake(22, 22)];
    
    
    UIBarButtonItem *end = [[UIBarButtonItem alloc] initWithTitle:@"结束训练" style:UIBarButtonItemStyleDone target:self action:@selector(endTraining)];
    
    self.navigationItem.leftBarButtonItem = end;
    
    ListCountButton *btn = [[ListCountButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    
    [btn addTarget:self action:@selector(showWorkoutList)];
    
    [btn setCount:0 animated:NO];
    
    [btn showCounter:NO];
    
    UIBarButtonItem *detail = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    //[[UIBarButtonItem alloc]initWithImage:resizedImg style:UIBarButtonItemStyleDone target:self action:@selector(tapNaviDetail)];
    
    self.navigationItem.rightBarButtonItem = detail;
    
}


-(void)workoutComplete{
    [[CYWorkoutManager sharedManager] didFinishWorkoutPlan:[[NSArray alloc] initWithArray:self.plan copyItems:YES]];
    
    //show workout complete view
    NSMutableArray *acts = [NSMutableArray new];
    for (TargetMuscle *m in self.plan) {
        [acts addObjectsFromArray:m.actions];
    }
    _doneTableVC.data = [NSArray arrayWithArray:acts];
    
    self.completeView.hidden = NO;
}


-(void)log:(NSArray <TargetMuscle *> *)arr{
    for (TargetMuscle *m in arr) {
        NSLog(@"muscle : %@" , m.muscle);
        NSLog(@"actions : {");
        for (WorkoutAction *act in m.actions) {
            NSLog(@"%@,",act.actionName);
        }
        NSLog(@"}");
    }
}

#pragma mark - Notifications

-(void)initNotifications{
    if([SDVersion deviceSize] <= Screen4inch){ // only observe in small screen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

-(void)keyboardWillChangeFrame:(NSNotification *)noti{
    CGRect rect = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.transform = CGAffineTransformMakeTranslation(0, -rect.size.height / 3);
    }];
}

-(void)keyboardWillHide:(NSNotification *)noti{
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:_weightTextField] && [_repsTextField.text length] <= 0) {
        [_repsTextField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - TrainingListView Delegate

-(void)didMoveFromIndex:(NSUInteger)from toIndex:(NSUInteger)to{
    [self moveActionFromIndex:from toIndex:to];
}


#pragma mark - UIPopoverControllerDelegate

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}


@end

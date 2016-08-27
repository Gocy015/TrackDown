//
//  WorkoutPlanningViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/12.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "WorkoutPlanningViewController.h"
#import "Masonry.h"
#import "CYWorkoutManager.h"
#import "TargetMuscle.h"
#import "WorkoutAction.h"
#import "StoryboardManager.h"
#import "NSArray+Map.h"
#import "UIImage+Resize.h"
#import "PopTableViewController.h"
#import "PreDefines.h"
#import "ListCountButton.h"
#import "TimeBreakViewController.h"
#import "CYPresentationController.h"
#import "MBProgressHUD+DefaultHUD.h"
#import "CYGuidanceView.h"
#import "CYGuidanceManager.h"
#import "UILabel+ConstraintSize.h"

@interface WorkoutPlanningViewController ()<UIPickerViewDataSource ,UIPickerViewDelegate ,UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *actionPicker; 
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *timeBreakButton;

@property (nonatomic ,strong) NSArray *workouts;
@property (nonatomic ,strong) TargetMuscle *currentMuscle;
@property (nonatomic ,strong) TargetMuscle *workingMuscle;

@property (nonatomic ,strong) NSMutableArray <TargetMuscle *>*workoutPlan;

@end


static const CGFloat actPortion = 0.65;
static NSString *const popVCId = @"PopTableViewController";
static NSString *const tbVCId = @"TimeBreakViewController";

@implementation WorkoutPlanningViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    _actionPicker.delegate = self;
    _actionPicker.dataSource = self;
    
    self.workouts = [[CYWorkoutManager sharedManager] getCurrentWorkoutTypes];
    
    _currentMuscle = [self.workouts firstObject];
    [self resetWorkingMuscle:NO];
    
    [self installComponentHeader];
    [self installNaviTitleView];
    [self installNaviDetailView];
    [self decorateButton:self.addButton];
    [self decorateButton:self.timeBreakButton];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self showGuidance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
//    NSLog(@"%@",self.view.subviews);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions
- (IBAction)addAction:(id)sender {
    NSUInteger actIndex = [_actionPicker selectedRowInComponent:0];
    NSUInteger setIndex = [_actionPicker selectedRowInComponent:1];
    
    WorkoutAction *act = [WorkoutAction new];
    act.actionName = [_currentMuscle.actions objectAtIndex:actIndex].actionName;
    act.sets = setIndex + 1;
    
    [_workingMuscle.actions addObject:act];
    
    ListCountButton *btn = (ListCountButton *)self.navigationItem.rightBarButtonItem.customView;
    [btn showCounter:YES];
    [btn incrementBy:1 limit:99 animated:YES];
}
- (IBAction)setTimeBreak:(id)sender {
    TimeBreakViewController *tbvc = [[StoryboardManager storyboardWithIdentifier:@"Settings"] instantiateViewControllerWithIdentifier:tbVCId];
    [self.navigationController pushViewController:tbvc animated:YES];
}


- (IBAction)beginTrainning:(id)sender {
    if (_workingMuscle.actions.count == 0 && self.workoutPlan.count == 0) {
        
        [MBProgressHUD textHUDAddedTo:self.view text:@"还未添加任何训练!" animated:YES];
        return ;
    }
    
    if (![self.workoutPlan containsObject:_workingMuscle] && _workingMuscle.actions.count > 0) {
        [self.workoutPlan addObject:_workingMuscle];
    }
    
//    NSLog(@"workout plan today : %@",self.workoutPlan);
    
    
    if (self.workoutPlan.count == 0 ) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishPlanningWorkout:)]) {
        
        NSArray *arr = [NSArray arrayWithArray:self.workoutPlan];
        
        [self.delegate didFinishPlanningWorkout:arr];
    }
    
//    [[CYWorkoutManager sharedManager] didFinishWorkoutPlan:self.workoutPlan];
    
    // begin workout
}

-(void)tapNaviTitle{
    
    
    if ([self presentedViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    PopTableViewController *popVC = [[StoryboardManager mainStoryboard] instantiateViewControllerWithIdentifier:popVCId];
    popVC.checkIndex = [_workouts indexOfObject:_currentMuscle];
    popVC.dataArray = [NSMutableArray arrayWithArray:[_workouts map:^NSObject *(TargetMuscle *m) {
        return m.muscle;
        }]
    ];
    popVC.clickToDismiss = YES;
    
    CYPresentationController *present = [CYPresentationController new];

    present.trianglePosition = CGPointMake(0.5, 0.5);

//    if(_workouts.count <= 8){
    
//        popVC.modalPresentationStyle = UIModalPresentationPopover;
//        popVC.popoverPresentationController.sourceView = self.navigationItem.titleView;
//        popVC.popoverPresentationController.sourceRect = self.navigationItem.titleView.bounds;
//        popVC.popoverPresentationController.delegate = self;
        WeakSelf();
        
        CGFloat width = 200;
        CGFloat height = MIN(44 * 8,44 * _workouts.count);
        CGPoint point = self.navigationItem.titleView.center;
        
        CGPoint convert = [self.view convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
        
        popVC.view.frame = CGRectMake(0, 0, width, height);
        
        present.contentController = popVC;
        present.backgroundFillColor = [UIColor darkGrayColor];
        present.showPoint = convert;
        
        //        popVC.preferredContentSize = CGSizeMake(width, height);
        [present showFrom:self];
        
        __weak typeof(present) weakPresent = present;
//        popVC.preferredContentSize = CGSizeMake(width, height);
        popVC.clickblock = ^(NSUInteger index){
            [weakSelf changeCurrentWorkout:index];
            [weakPresent dismiss];
        };
        
//        [self presentViewController:popVC animated:YES completion:nil];
//    }
//    else{
//        [self.navigationController pushViewController:popVC animated:YES];
//        popVC.title = @"目标肌群";
//    }
}

-(void)tapNaviDetail{
    
    if ([self presentedViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    PopTableViewController *popVC = [[StoryboardManager mainStoryboard] instantiateViewControllerWithIdentifier:popVCId];
    popVC.checkIndex = -1;
    
    CYPresentationController *present = [CYPresentationController new];
    
    BOOL delete = YES;
    
    NSMutableArray *displayWorkouts = [NSMutableArray new];
    NSMutableArray *displayGroups = [NSMutableArray new];
    [self resetWorkingMuscle:YES];
    for (TargetMuscle *m in self.workoutPlan) {
        for (WorkoutAction *act in m.actions) {
            NSString *displayString = [NSString stringWithFormat:@"%@",act.actionName];
            NSString *displayGroup = [NSString stringWithFormat:@"x %li组",(unsigned long)act.sets];
            [displayWorkouts addObject:displayString];
            [displayGroups addObject:displayGroup];
        }
    }
    if (displayWorkouts.count == 0) {
        [displayWorkouts addObject:@"暂时未添加训练动作"];
        delete = NO;
    }
    
    popVC.clickToDismiss = NO;
    popVC.dataArray = [NSMutableArray arrayWithArray:displayWorkouts];
    popVC.subDataArray = [NSMutableArray arrayWithArray:displayGroups];
    popVC.allowsDeletion = delete;
    
    WeakSelf();
    popVC.deleteblock = ^(NSUInteger index){
        for (TargetMuscle *m in weakSelf.workoutPlan) {
            if (index > m.actions.count - 1) {
                index -= m.actions.count;
                continue;
            }
            [m.actions removeObjectAtIndex:index];
            if(m.actions.count == 0){
                [weakSelf.workoutPlan removeObject:m];
            }
            break;
        }
        
        ListCountButton *btn = (ListCountButton *)weakSelf.navigationItem.rightBarButtonItem.customView;
        [btn showCounter:YES];
        [btn decrementBy:1 limit:0 animated:YES];

        
    };
//    if (displayWorkouts.count <= 10) {
    
//        popVC.modalPresentationStyle = UIModalPresentationPopover;
//        popVC.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
//        popVC.popoverPresentationController.delegate = self;
//        popVC.popoverPresentationController.backgroundColor = [UIColor grayColor];
        
        CGPoint point = self.navigationItem.rightBarButtonItem.customView.center;
        
        CGPoint convert = [self.view convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
        
        
        CGFloat width = 230;
        CGFloat height = MIN(44 * 10,44 * displayWorkouts.count);
        popVC.view.frame = CGRectMake(0, 0, width, height);
        
        present.contentController = popVC;
        present.backgroundFillColor = [UIColor darkGrayColor];
        present.showPoint = convert;
        present.trianglePosition = CGPointMake(0.9, 0.5);
        
//        popVC.preferredContentSize = CGSizeMake(width, height);
        [present showFrom:self];
//        [self presentViewController:popVC animated:YES completion:nil];
//    }else{
//        [self.navigationController pushViewController:popVC animated:YES];
//        
//        popVC.title = @"训练计划";
//    }
    
}

#pragma mark - Helpers


-(void)showGuidance{
    if ([CYGuidanceManager shouldShowGuidance:GuideType_Planning]) {
        
        
        CYGuidanceView *guide = [CYGuidanceView new];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        CGRect titleRect = [window convertRect:self.navigationItem.titleView.frame toView:window];
        CGRect listRect =  [self.view convertRect:self.navigationItem.rightBarButtonItem.customView.frame toView:window];
        
        //status bar height
        titleRect = CGRectMake(titleRect.origin.x, titleRect.origin.y + 20, titleRect.size.width, titleRect.size.height);
        listRect = CGRectMake(listRect.origin.x, listRect.origin.y + 20, listRect.size.width, listRect.size.height);
        
//        GuideInfo *titleInfo = [GuideInfo new];
//        titleInfo.guideRect = CGRectInset(titleRect, -6, -4);
        UILabel *titleLabel = [self generateDefaultLabelWithText:@"点击可切换目标肌群" fontSize:16];
//        [titleLabel resizeWithConstraintSize:CGSizeMake(70, CGFLOAT_MAX)];
//        titleInfo.guideDescriptionView = titleLabel;
//        titleInfo.relativePosition = CGPointMake((self.navigationItem.titleView.frame.size.width - titleLabel.bounds.size.width) / 2 + 3, self.navigationItem.titleView.frame.size.height + 6);
//        titleInfo.cornerRadius = 6;
        
        GuideInfo *titleInfo = [[GuideInfo alloc] initWithGuideRect:CGRectInset(titleRect, -6, -4) descriptionView:titleLabel verticalPosition:VerticalPosition_Bottom horizontalPosition:HorizontalPosition_Middle cornerRadius:6];;
        
        GuideInfo *listInfo = [GuideInfo new];
        listInfo.guideRect = CGRectInset(listRect, -6, -2);
        UILabel *listLabel = [self generateDefaultLabelWithText:@"点击这里查看训练列表" fontSize:16];
//        [listLabel resizeWithConstraintSize:CGSizeMake(70, CGFLOAT_MAX)];
        listInfo.guideDescriptionView = listLabel;
        listInfo.relativePosition = CGPointMake(self.navigationItem.rightBarButtonItem.customView.frame.size.width - listLabel.bounds.size.width + 3, self.navigationItem.rightBarButtonItem.customView.frame.size.height + 6);
        listInfo.cornerRadius = 6;
        
//        GuideInfo *pickerInfo = [GuideInfo new];
//        pickerInfo.guideRect = [self.view convertRect:CGRectInset(self.actionPicker.frame, 0, 0) toView:window];
        UILabel *pickerLabel = [self generateDefaultLabelWithText:@"在这里选择训练动作" fontSize:16];
        
//        pickerInfo.guideDescriptionView = pickerLabel;
//        pickerInfo.relativePosition = CGPointMake(self.actionPicker.frame.size.width / 2 - pickerLabel.bounds.size.width / 2, self.actionPicker.frame.size.height+2);
//        pickerInfo.cornerRadius = 10;
        GuideInfo *pickerInfo = [[GuideInfo alloc] initWithGuideRect:[self.view convertRect:CGRectInset(self.actionPicker.frame, 0, 0) toView:window] descriptionView:pickerLabel verticalPosition:VerticalPosition_Bottom horizontalPosition:HorizontalPosition_Middle cornerRadius:10];
        
//        GuideInfo *addInfo = [GuideInfo new];
//        addInfo.guideRect = [self.view convertRect:CGRectInset(self.addButton.frame, -8 , -4) toView:window];
        UILabel *addLabel = [self generateDefaultLabelWithText:@"在这里添加训练动作" fontSize:16];
//        addInfo.guideDescriptionView = addLabel;
//        addInfo.relativePosition = CGPointMake(self.addButton.frame.size.width / 2 - addLabel.bounds.size.width / 2 + 4 , -(4 + addLabel.bounds.size.height));
//        addInfo.cornerRadius = 10;
        GuideInfo *addInfo = [[GuideInfo alloc] initWithGuideRect:[self.view convertRect:CGRectInset(self.addButton.frame, -8 , -4) toView:window] descriptionView:addLabel verticalPosition:VerticalPosition_Top horizontalPosition:HorizontalPosition_Middle cornerRadius:8];
        
        [guide addStep:@[titleInfo]];
        [guide addStep:@[listInfo]];
        [guide addStep:@[pickerInfo]];
        [guide addStep:@[addInfo]];
        
        guide.hintText = @"点击屏幕以继续";
        
        [guide showInView:window animated:YES];
        
        [CYGuidanceManager updateGuidance:GuideType_Planning withShowStatus:YES];
    }
}

-(UILabel *)generateDefaultLabelWithText:(NSString *)text fontSize:(CGFloat)size{
    UILabel *label = [UILabel mediumLabelWithSize:size];
    label.text = text;
    [label sizeToFit];
    return label;
}

-(void)installComponentHeader{
    UILabel *actHeader = [UILabel new];
    actHeader.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    actHeader.text = @"训练动作";
    actHeader.textAlignment = NSTextAlignmentCenter;
    
    
    UILabel *setHeader = [UILabel new];
    setHeader.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    setHeader.text = @"组数";
    setHeader.textAlignment = NSTextAlignmentCenter;

    
    [self.view addSubview:actHeader];
    [self.view addSubview:setHeader];
    
    __weak UIView *picker = _actionPicker;
    
    [actHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(picker.mas_width).multipliedBy(actPortion);
        make.leading.equalTo(picker.mas_leading);
        make.bottom.equalTo(picker.mas_top).offset(-2);
    }];
    
    [setHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(picker.mas_width).multipliedBy(1 - actPortion);
        make.leading.equalTo(actHeader.mas_trailing);
        make.bottom.equalTo(picker.mas_top).offset(-2);
    }];
}

-(void)installNaviTitleView{
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = _currentMuscle.muscle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16 weight:4];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    
    UIImageView *imgView = [UIImageView new];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame = CGRectMake(titleLabel.bounds.size.width + 6, 0, 16, 16);
    UIImage *spinArrow = [UIImage imageNamed:@"spinArrow"];
    imgView.image = spinArrow;
    
    UIView *titleView = [UIView new];
    titleView.frame = CGRectMake(0, 0, CGRectGetMaxX(imgView.frame), 16);
    
    [titleView addSubview:titleLabel];
    [titleView addSubview:imgView];
    
    titleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapNaviTitle)];
    
    [titleView addGestureRecognizer:tap];
    
    self.navigationItem.titleView = titleView;
}

-(void)installNaviDetailView{
    
//    UIImage *img = [UIImage imageNamed:@"list"];
//    
//    UIImage *resizedImg = [img resize:CGSizeMake(22, 22)];
    
    ListCountButton *btn = [[ListCountButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    
    [btn addTarget:self action:@selector(tapNaviDetail)];
    
    [btn setCount:0 animated:NO];
    
    [btn showCounter:NO];
    
    UIBarButtonItem *detail = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    //[[UIBarButtonItem alloc]initWithImage:resizedImg style:UIBarButtonItemStyleDone target:self action:@selector(tapNaviDetail)];
    
    self.navigationItem.rightBarButtonItem = detail;
    
}

-(void)decorateButton:(UIButton *)btn{
    NSString *content = btn.titleLabel.text;
    btn.titleLabel.text = @"";
    
    NSDictionary *attr = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSAttributedString *attrStr = [[NSAttributedString alloc]initWithString:content attributes:attr];
    btn.titleLabel.attributedText = attrStr;
}

-(void)changeCurrentWorkout:(NSUInteger)index{
    if (index < _workouts.count && index != [_workouts indexOfObject:_currentMuscle]) {
//        if(![self.workoutPlan containsObject:_workingMuscle]){
//            [self.workoutPlan addObject:_workingMuscle];
//        }
        _currentMuscle = _workouts[index];
        
        [self resetWorkingMuscle:YES];
//        _workingMuscle = [TargetMuscle new];
//        _workingMuscle.muscle = _currentMuscle.muscle;
        
        [self.actionPicker reloadComponent:0];
        [self.actionPicker selectRow:0 inComponent:0 animated:YES];
        
        ((UILabel *)self.navigationItem.titleView.subviews.firstObject).text = _currentMuscle.muscle;
    }
}


-(void)resetWorkingMuscle:(BOOL)tryToAdd{
    if(tryToAdd && ![self.workoutPlan containsObject:_workingMuscle] && _workingMuscle.actions.count > 0){
        [self.workoutPlan addObject:_workingMuscle];
    }
    _workingMuscle = [TargetMuscle new];
    _workingMuscle.muscle = _currentMuscle.muscle;

}

#pragma mark - UIPickerView DataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return component == 0 ? _currentMuscle.actions.count : 15;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component == 0) {
        return pickerView.frame.size.width * actPortion;
    }
    return pickerView.frame.size.width * (1 - actPortion);
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = nil;
    if (view && [view isKindOfClass:[UILabel class]]) {
        label = (UILabel *)view;
    }else{
        
        
        label = [UILabel new];
    }
    
    if(component == 0){
        
        label.text = [_currentMuscle.actions objectAtIndex:row].actionName;
    }else{
        
        label.text = [NSString stringWithFormat:@"%li",row + 1];
    }
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    
    [label sizeToFit];
    
    if (label.bounds.size.width > [pickerView rowSizeForComponent:component].width) {
        label.frame = CGRectMake(0, 0, [pickerView rowSizeForComponent:component].width, label.bounds.size.height);
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    else{
        label.frame = CGRectMake(([pickerView rowSizeForComponent:component].width - label.bounds.size.width) / 2, 0, label.bounds.size.width, label.bounds.size.height);
    }
    
    
    return label;
}
#pragma mark - UIPickerView Delegate
//-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
//    UILabel *label =[UILabel new];
//    
//    if(component == 0){
//        label.text = [_currentMuscle.actions objectAtIndex:row].actionName;
//    }else{
//        label.text = [NSString stringWithFormat:@"%li",row + 1];
//        
//    }
//    
//    [label sizeToFit];
//    return label;
//}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(component == 0){
        return [_currentMuscle.actions objectAtIndex:row].actionName;
    }else{
        return [NSString stringWithFormat:@"%li",row + 1];
    }
}


#pragma mark - getter

-(NSMutableArray *)workoutPlan{
    if (!_workoutPlan) {
        _workoutPlan = [NSMutableArray new];
    }
    return _workoutPlan;
}


#pragma mark - UIPopoverControllerDelegate

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}


@end

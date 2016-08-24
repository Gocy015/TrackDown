//
//  AddWorkoutViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/11.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "AddWorkoutViewController.h"
#import "TargetMuscle.h"
#import "WorkoutAction.h"
#import "Masonry.h"
#import "PreDefines.h"
#import "CYWorkoutManager.h"
#import "MBProgressHUD+DefaultHUD.h"

@interface AddWorkoutViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *muscleTextField;
@property (weak, nonatomic) IBOutlet UITextField *actionTextField;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

@end

@implementation AddWorkoutViewController

#pragma mark - Life Cycle

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _muscleTextField.delegate = self;
    _actionTextField.delegate = self;
    
    [self addGestures];
    
}

-(void)dealloc{
    NSLog(@"Add Workout VC Dealloc");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!_muscle) { //add muscle
        _actionTextField.hidden = YES;
        _actionLabel.hidden = YES;
    }else{
        _muscleTextField.text = _muscle.muscle;
        _muscleTextField.enabled = NO;
        
        WeakSelf();
        
        [_actionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(weakSelf.muscleTextField.mas_width);
        }];
    }
}

#pragma mark - UITextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Actions

- (IBAction)confirmAdd:(id)sender {
    
    [self resignKeyboards];
    //check first
    
    if ([self checkTextFields]){
        //save
        if (!_muscle) {
            _muscle = [TargetMuscle new];
            _muscle.muscle = _muscleTextField.text;
            _muscle.actions = [NSMutableArray new];
            [[CYWorkoutManager sharedManager] addTargetMuscle:_muscle writeToDiskImmediatly:YES completion:^(BOOL success) {
                if (success) {
                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }else{
                    
                    [MBProgressHUD textHUDAddedTo:self.view text:@"已存在重名肌群!" animated:YES];
                }
            }];
        }
        else{
            WorkoutAction *act = [WorkoutAction new];
            act.actionName = _actionTextField.text;
            [[CYWorkoutManager sharedManager] addAction:act toMuscle:_muscle writeToDiskImmediatly:YES completion:^(BOOL success) {
                if (success) {
                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [MBProgressHUD textHUDAddedTo:self.view text:@"已存在重名训练!" animated:YES];
                }
            }];
        }
        
    }
    else{
        NSLog(@"Text not pass checking");
    }
    
}

- (IBAction)cancelAdd:(id)sender {
    [self resignKeyboards];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Helpers

-(void)addGestures{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboards)];
    [self.view addGestureRecognizer:tap];
}

-(BOOL)checkTextFields{
    BOOL pass = YES;
    if (!_muscle) { //only check when self.muscle is nil
        
        pass = [self checkString:_muscleTextField.text];
    }else{ 
       
        pass = [self checkString:_actionTextField.text];
        for (WorkoutAction *action in _muscle.actions) {
            if ([action.actionName isEqualToString:_actionTextField.text]) {
                pass = NO;
                
                [MBProgressHUD textHUDAddedTo:self.view text:@"已存在重名训练!" animated:YES];
                break;
            }
        }
        
    }
    
    return pass;
}

-(BOOL)checkString:(NSString *)text{
    if(text == nil || [text isEqualToString: @""]){
        return NO;
    }
    // check if str only contains whitespace
    NSString *clippedText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (clippedText.length == 0) {
        return NO;
    }
    return YES;
}

-(void)resignKeyboards{
    
    [_muscleTextField resignFirstResponder];
    [_actionTextField resignFirstResponder];
    
}

@end

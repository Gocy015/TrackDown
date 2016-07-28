//
//  TimeBreakViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/28.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "TimeBreakViewController.h"
#import "CYWorkoutManager.h"

@interface TimeBreakViewController ()
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;

@end


static NSString * const kTimeTooShortTip = @"再怎么练也稍微要休息几秒啊~请重新设置间歇时间";
static NSString * const kTimeTooLongTip = @"过长的休息时间容易导致伤病产生!请重新设置间歇时间";
static NSString * const kInvalidInputTip = @"输入的内容不是有效的时间格式";

static const NSUInteger shortest = 2;
static const NSUInteger longest = 600;

@implementation TimeBreakViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"组间歇设置";
}

- (void)viewWillAppear:(BOOL)animated{
    self.warningLabel.alpha = 0;
    self.timeTextField.text = [NSString stringWithFormat:@"%lu",[[CYWorkoutManager sharedManager] getTimeBreak]];
    self.timeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.timeTextField becomeFirstResponder];
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

#pragma mark - Helpers

-(void)showWarningWithTips:(NSString *)tips{
    self.warningLabel.text = tips;
    [self.warningLabel sizeToFit];
    [UIView animateWithDuration:0.22 animations:^{
        self.warningLabel.alpha = 1;
    }];
}

#pragma mark - Actions
- (IBAction)setTimeBreak:(id)sender {
    NSNumberFormatter *f = [NSNumberFormatter new];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *num = [f numberFromString:self.timeTextField.text];
    if (num) {
        if ([num integerValue] < shortest) {
            [self showWarningWithTips:kTimeTooShortTip];
        }else if ([num integerValue] > longest){
            [self showWarningWithTips:kTimeTooLongTip];
        }else{
            [[CYWorkoutManager sharedManager] setTimeBreak:[num integerValue]];
            [self.timeTextField resignFirstResponder];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        [self showWarningWithTips:kInvalidInputTip];
    }
}

@end

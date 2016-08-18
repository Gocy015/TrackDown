//
//  SettingsListViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/28.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "SettingsListViewController.h"
#import "SettingsCell.h"
#import "SettingsInfo.h"
#import "SettingsManager.h"
#import "TimeBreakViewController.h"
#import "StoryboardManager.h"


@interface SettingsListViewController () <UITableViewDelegate ,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic ,strong) NSArray *settings;

@end


static NSString *const cellReuseId = @"settingsListCell";
static NSString *const headerReuseId = @"settingsListHeader";
static NSString *const footerReuseId = @"settingsListFooter";

@implementation SettingsListViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置";
    
    self.settings = [[SettingsManager sharedManager] getCurrentSettings];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsCell" bundle:nil] forCellReuseIdentifier:cellReuseId];

    self.tableView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.05f];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger sec = indexPath.section;
    NSInteger row = indexPath.row;
    SettingsInfo *info = [[self.settings objectAtIndex:sec] objectAtIndex:row];
    switch (info.type) {
        case SettingType_TimeBreak:
            
            [self jumpToTimeBreakVC];
            break;
            
        case SettingType_About:
            break;
        default:
            break;
    }
}

#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.settings ? self.settings.count : 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section < [self.settings count]) {
        return [self.settings[section] count];
    }
    return 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    NSInteger sec = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (sec < [self.settings count]) {
        if (row < [self.settings[sec] count]) {
            SettingsInfo *info = [[self.settings objectAtIndex:sec] objectAtIndex:row];
            [cell configCellContent:info.desc enterable:info.canEnter];
        }
    }
    
    return cell;
}

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    BlankFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseId];
//    [footer setBgColor:[[UIColor grayColor] colorWithAlphaComponent:0.2f]];
//    
//    return footer;
//}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    BlankFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseId];
//    [header setBgColor:[[UIColor grayColor] colorWithAlphaComponent:0.02f]];
//    
//    return header;
//}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 6;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}


#pragma mark - Jump

-(void)jumpToTimeBreakVC{
    TimeBreakViewController *tbvc = [[StoryboardManager storyboardWithIdentifier:@"Settings"] instantiateViewControllerWithIdentifier:@"TimeBreakViewController"];
    
    [self.navigationController pushViewController:tbvc animated:YES];
}

@end

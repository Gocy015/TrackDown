//
//  PopTableViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/12.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "PopTableViewController.h"
#import "CheckboxTableViewCell.h"

@interface PopTableViewController ()<UITableViewDataSource ,UITableViewDelegate >
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PopTableViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray ? self.dataArray.count : 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CheckboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckboxTableViewCell"];
    
    [cell showChecked:(self.checkIndex == indexPath.row)];
    
    [cell setText:self.dataArray[indexPath.row]];
    
    if ([self.subDataArray count] > indexPath.row) {
        [cell setGroup:self.subDataArray[indexPath.row]];
    }else{
        
        [cell setGroup:@""];
    }
    
    return cell;
}


#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_clickblock) {
        _clickblock(indexPath.row);
    }
    if (_clickToDismiss) {
        
//        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete && _allowsDeletion) {
        //remove
        [tableView beginUpdates];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
        if (_deleteblock) {
            _deleteblock(indexPath.row);
        }
    }
    
    
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return _allowsDeletion ;
}



#pragma mark - Helpers
 
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

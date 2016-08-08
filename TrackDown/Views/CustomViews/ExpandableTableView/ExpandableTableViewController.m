//
//  ExpandableTableViewController.m
//  TrackDown
//
//  Created by Gocy on 16/7/22.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "ExpandableTableViewController.h"
#import "ClickableHeaderView.h"
#import "BlankFooterView.h"

static NSString *const cellReuseId = @"secondaryCell";
static NSString *const headerReusedId = @"clickableHeader";
static NSString *const footerReusedId = @"blankFooter";
static CGFloat headerHeight = 40.0f;

@interface ExpandableTableViewController () <UITableViewDelegate ,UITableViewDataSource ,ClickableHeaderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ExpandableTableViewController



#pragma mark - Life Cycle

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    [self.tableView registerClass:[BlankFooterView class] forHeaderFooterViewReuseIdentifier:footerReusedId];
    
    self.tableView.tableFooterView = [UIView new];
    
    if (self.cellDataSource) {
        [self.cellDataSource registerCellReuseIdForTableView:self.tableView];
    }else{
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseId];
    }
    
    if (self.headerViewDataSource) {
        [self.headerViewDataSource registerHeaderReuseIdForTableView:self.tableView];
    }else{
        [self.tableView registerClass:[ClickableHeaderView class] forHeaderFooterViewReuseIdentifier:headerReusedId];
    }
}




#pragma mark - UITableView Deleagate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.data ? self.data.count : 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.data) {
        if ([self.data[section] opened]) {
            
            return [self.data[section] countOfSecondaryObjects];
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.headerViewDataSource) {
        return [self.headerViewDataSource heightForHeaderViewInSection:section];
    }
    return headerHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.cellDataSource) {
        return [self.cellDataSource heightForCellAtIndexPath:indexPath];
    }
    return 30;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (self.headerViewDataSource) {
        return [self.headerViewDataSource tableView:tableView viewForHeaderInSection:section];
    }
    
    ClickableHeaderView *header = (ClickableHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReusedId];
    
    header.headerText = [self.data[section] description];
    
    header.delegate = self;
    header.section = section;
    
    header.opened = [self.data[section] opened];
    
    return header;
//    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.cellDataSource) {
        return [self.cellDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    
    cell.textLabel.text = [self.data[indexPath.section] descriptionForSecondaryObjects][indexPath.row];
    
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
    
//    return nil;
}




#pragma mark - Clickable Header Delegate

-(void)didClickHeaderView:(ClickableHeaderView *)headerView{
    
    id <ExpandableObject> obj = self.data[headerView.section];
    
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (NSInteger i = 0; i < [obj countOfSecondaryObjects]; ++i) {
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:i inSection:headerView.section];
        [indexPaths addObject:idxPath];
    }
    if (![obj opened]) {
        [obj setOpened:YES];
        headerView.opened = YES;
        NSIndexPath *lastIndex = indexPaths.lastObject;
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        
        CGRect rect = [self.tableView rectForRowAtIndexPath:lastIndex];
        if (!CGRectContainsRect(self.tableView.bounds, rect)) {
            
            [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }else{
        [obj setOpened:NO];
        headerView.opened = NO;
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}



#pragma mark - Setters

-(void)setData:(NSArray<id<ExpandableObject>> *)data{
    _data = data;
    if (self.tableView) {
        [self.tableView reloadData];
    }
}

-(void)setCellDataSource:(id<CustomCellDataSource>)cellDataSource{
    _cellDataSource = cellDataSource;
    if (self.tableView && _cellDataSource) {
        [_cellDataSource registerCellReuseIdForTableView:self.tableView];
    }
}

-(void)setHeaderViewDataSource:(id<CustomHeaderViewDataSource>)headerViewDataSource{
    _headerViewDataSource = headerViewDataSource;
    if (self.tableView && _headerViewDataSource) {
        [_headerViewDataSource registerHeaderReuseIdForTableView:self.tableView];
    }
}


@end

//
//  CustomExpandableViewProtocol.h
//  TrackDown
//
//  Created by Gocy on 16/8/5.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#ifndef CustomExpandableViewProtocol_h
#define CustomExpandableViewProtocol_h


@protocol CustomHeaderViewDataSource <NSObject>

@required
-(CGFloat)heightForHeaderViewInSection:(NSUInteger)section;

-(UITableViewHeaderFooterView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSUInteger)section;

-(void)registerHeaderReuseIdForTableView:(UITableView *)tableView;

@end

@protocol CustomCellDataSource <NSObject>

@required
-(CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)registerCellReuseIdForTableView:(UITableView *)tableView;

@end


#endif /* CustomExpandableViewProtocol_h */

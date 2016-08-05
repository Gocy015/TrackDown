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

-(void)registerReuseIdForTableView:(UITableView *)tableView;

@end

@protocol CustomCellDataSource <NSObject>

@required
-(CGFloat)heigthForCellAtIndexPath:(NSIndexPath *)indexPath;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)registerReuseIdForTableView:(UITableView *)tableView;

@end


#endif /* CustomExpandableViewProtocol_h */

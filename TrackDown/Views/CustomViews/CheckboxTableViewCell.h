//
//  CheckboxTableViewCell.h
//  TrackDown
//
//  Created by Gocy on 16/7/12.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckboxTableViewCell : UITableViewCell



-(void)showChecked:(BOOL)show;
-(void)setText:(NSString *)text;
-(void)setGroup:(NSString *)group;

@end

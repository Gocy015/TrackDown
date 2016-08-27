//
//  CheckboxTableViewCell.m
//  TrackDown
//
//  Created by Gocy on 16/7/12.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "CheckboxTableViewCell.h"

@interface CheckboxTableViewCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hDistance;
@property (weak, nonatomic) IBOutlet UILabel *checkLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@end


@implementation CheckboxTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_contentLabel setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightLight]];
    [_groupLabel setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightLight]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)showChecked:(BOOL)show{
    _checkLabel.hidden = !show;
    if (show) {
        _hDistance.constant = 20;
    }
}

-(void)setText:(NSString *)text{
    _contentLabel.text = text;
}

-(void)setGroup:(NSString *)group{
    _groupLabel.text = group;
}

@end

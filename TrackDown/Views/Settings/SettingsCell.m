//
//  SettingsCell.m
//  TrackDown
//
//  Created by Gocy on 16/7/28.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "SettingsCell.h"

@interface SettingsCell ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *entryLabel;

@end

@implementation SettingsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)configCellContent:(NSString *)content enterable:(BOOL)enter{
    self.contentLabel.text = content;
    self.entryLabel.hidden = !enter;
}

@end

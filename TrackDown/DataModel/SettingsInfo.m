//
//  SettingsInfo.m
//  TrackDown
//
//  Created by Gocy on 16/7/28.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "SettingsInfo.h"

@implementation SettingsInfo

-(instancetype)initWithDescription:(NSString *)desc canEnter:(BOOL)canEnter settingType:(SettingType)t{
    if (self = [super init]) {
        _desc = desc;
        _canEnter = canEnter;
        _type = t;
    }
    return self;
}

@end

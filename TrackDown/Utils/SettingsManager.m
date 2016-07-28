//
//  SettingsManager.m
//  TrackDown
//
//  Created by Gocy on 16/7/28.
//  Copyright © 2016年 Gocy. All rights reserved.
//

#import "SettingsManager.h"
#import "SettingsInfo.h"

@interface SettingsManager ()
@property (nonatomic ,strong) NSArray *settings;
@end

@implementation SettingsManager

#pragma mark - Class Method
+(instancetype)sharedManager{
    
    static SettingsManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [SettingsManager new];
    });
    
    return s_manager;
}


-(NSArray *)getCurrentSettings{
    if (!_settings) {
        [self createSettings];
    }
    
    return _settings;
}


-(void)createSettings{
    SettingsInfo *breakTime = [[SettingsInfo alloc] initWithDescription:@"组间歇时间设置" canEnter:YES settingType:SettingType_TimeBreak];
    SettingsInfo *about = [[SettingsInfo alloc] initWithDescription:@"关于" canEnter:YES settingType:SettingType_About];
    
    _settings =  @[
                   @[breakTime
                       ],
                   @[about
                       ]
                   ];
    
}

@end
